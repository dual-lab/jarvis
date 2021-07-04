load("@rules_rust//rust/private:common.bzl", "rust_common")
load(
    "@rules_rust//rust/private:rustc.bzl",
    "AliasableDepInfo",
    "BuildInfo",
    "ErrorFormatInfo",
    "get_compilation_mode_opts",
)
load(
    "@rules_rust//rust/private:utils.bzl",
    "crate_name_from_attr",
    "expand_locations",
    "find_cc_toolchain",
    "get_lib_name",
    "get_preferred_artifact",
)

def expand_list_element_locations(ctx, args, data):
    """ Forked from https://github.com/bazelbuild/rules_rust/blob/main/rust/private/rustc.bzl

    """
    return [expand_locations(ctx, arg, data) for arg in args]

def expand_dict_value_locations(ctx, env, data):
    """ Forked from https://github.com/bazelbuild/rules_rust/blob/main/rust/private/rustc.bzl

    """
    return dict([(k, expand_locations(ctx, v, data)) for (k, v) in env.items()])

def collect_deps(label, deps, proc_macro_deps, aliases):
    """ Forked from https://github.com/bazelbuild/rules_rust/blob/main/rust/private/rustc.bzl

    """
    direct_crates = []
    transitive_crates = []
    transitive_noncrates = []
    transitive_noncrate_libs = []
    transitive_build_infos = []
    build_info = None

    aliases = {k.label: v for k, v in aliases.items()}
    for dep in depset(transitive = [deps, proc_macro_deps]).to_list():
        if rust_common.crate_info in dep:
            # This dependency is a rust_library
            direct_dep = dep[rust_common.crate_info]
            direct_crates.append(AliasableDepInfo(
                name = aliases.get(dep.label, direct_dep.name),
                dep = direct_dep,
            ))

            transitive_crates.append(depset([dep[rust_common.crate_info]], transitive = [dep[rust_common.dep_info].transitive_crates]))
            transitive_noncrates.append(dep[rust_common.dep_info].transitive_noncrates)
            transitive_noncrate_libs.append(dep[rust_common.dep_info].transitive_libs)
            transitive_build_infos.append(dep[rust_common.dep_info].transitive_build_infos)
        elif CcInfo in dep:
            # This dependency is a cc_library

            # TODO: We could let the user choose how to link, instead of always preferring to link static libraries.
            linker_inputs = dep[CcInfo].linking_context.linker_inputs.to_list()
            libs = [get_preferred_artifact(lib) for li in linker_inputs for lib in li.libraries]
            transitive_noncrate_libs.append(depset(libs))
            transitive_noncrates.append(dep[CcInfo].linking_context.linker_inputs)
        elif BuildInfo in dep:
            if build_info:
                fail("Several deps are providing build information, only one is allowed in the dependencies", "deps")
            build_info = dep[BuildInfo]
            transitive_build_infos.append(depset([build_info]))
        else:
            fail("rust targets can only depend on rust_library, rust_*_library or cc_library targets." + str(dep), "deps")

    transitive_crates_depset = depset(transitive = transitive_crates)
    transitive_libs = depset(
        [c.output for c in transitive_crates_depset.to_list()],
        transitive = transitive_noncrate_libs,
    )

    return (
        rust_common.dep_info(
            direct_crates = depset(direct_crates),
            transitive_crates = transitive_crates_depset,
            transitive_noncrates = depset(
                transitive = transitive_noncrates,
                order = "topological",  # dylib link flag ordering matters.
            ),
            transitive_libs = transitive_libs,
            transitive_build_infos = depset(transitive = transitive_build_infos),
            dep_env = build_info.dep_env if build_info else None,
        ),
        build_info,
    )

def collect_inputs(
        ctx,
        file,
        files,
        toolchain,
        cc_toolchain,
        crate_info,
        dep_info,
        build_info):
    """ Forked from https://github.com/bazelbuild/rules_rust/blob/main/rust/private/rustc.bzl
    """
    linker_script = getattr(file, "linker_script") if hasattr(file, "linker_script") else None

    linker_depset = cc_toolchain.all_files

    compile_inputs = depset(
        getattr(files, "data", []) +
        getattr(files, "compile_data", []) +
        [toolchain.rustc] +
        toolchain.crosstool_files +
        ([build_info.rustc_env, build_info.flags] if build_info else []) +
        ([] if linker_script == None else [linker_script]),
        transitive = [
            toolchain.rustc_lib.files,
            toolchain.rust_lib.files,
            linker_depset,
            crate_info.srcs,
            dep_info.transitive_libs,
        ],
    )
    build_env_files = getattr(files, "rustc_env_files", [])
    compile_inputs, out_dir, build_env_file, build_flags_files = _process_build_scripts(ctx, file, crate_info, build_info, dep_info, compile_inputs)
    if build_env_file:
        build_env_files = [f for f in build_env_files] + [build_env_file]
    compile_inputs = depset(build_env_files, transitive = [compile_inputs])
    return compile_inputs, out_dir, build_env_files, build_flags_files

def _process_build_scripts(
        ctx,
        file,
        crate_info,
        build_info,
        dep_info,
        compile_inputs):
    """ Forked from https://github.com/bazelbuild/rules_rust/blob/main/rust/private/rustc.bzl

    """
    extra_inputs, out_dir, build_env_file, build_flags_files = _create_extra_input_args(ctx, file, build_info, dep_info)
    if extra_inputs:
        compile_inputs = depset(extra_inputs, transitive = [compile_inputs])
    return compile_inputs, out_dir, build_env_file, build_flags_files

def _create_extra_input_args(ctx, file, build_info, dep_info):
    """Forked from https://github.com/bazelbuild/rules_rust/blob/main/rust/private/rustc.bzl

    """
    input_files = []

    # Arguments to the commandline line wrapper that are going to be used
    # to create the final command line
    out_dir = None
    build_env_file = None
    build_flags_files = []

    if build_info:
        out_dir = build_info.out_dir.path
        build_env_file = build_info.rustc_env
        build_flags_files.append(build_info.flags.path)
        build_flags_files.append(build_info.link_flags.path)
        input_files.append(build_info.out_dir)
        input_files.append(build_info.link_flags)

    return input_files, out_dir, build_env_file, build_flags_files

def _get_rustc_env(attr, toolchain):
    """Forked from https://github.com/bazelbuild/rules_rust/blob/main/rust/private/rustc.bzl

    """
    version = attr.version if hasattr(attr, "version") else "0.0.0"
    major, minor, patch = version.split(".", 2)
    if "-" in patch:
        patch, pre = patch.split("-", 1)
    else:
        pre = ""
    return {
        "CARGO_CFG_TARGET_ARCH": toolchain.target_arch,
        "CARGO_CFG_TARGET_OS": toolchain.os,
        "CARGO_CRATE_NAME": crate_name_from_attr(attr),
        "CARGO_PKG_AUTHORS": "",
        "CARGO_PKG_DESCRIPTION": "",
        "CARGO_PKG_HOMEPAGE": "",
        "CARGO_PKG_NAME": attr.name,
        "CARGO_PKG_VERSION": version,
        "CARGO_PKG_VERSION_MAJOR": major,
        "CARGO_PKG_VERSION_MINOR": minor,
        "CARGO_PKG_VERSION_PATCH": patch,
        "CARGO_PKG_VERSION_PRE": pre,
    }

def _make_link_flags_default(linker_input):
    ret = []
    for lib in linker_input.libraries:
        if lib.alwayslink:
            ret.extend([
                "-C",
                "link-arg=-Wl,--whole-archive",
                "-C",
                ("link-arg=%s" % get_preferred_artifact(lib).path),
                "-C",
                "link-arg=-Wl,--no-whole-archive",
            ])
        else:
            ret.extend(_portable_link_flags(lib))
    return ret

def _is_dylib(dep):
    return not bool(dep.static_library or dep.pic_static_library)

def _portable_link_flags(lib):
    if lib.static_library or lib.pic_static_library:
        return ["-lstatic=%s" % get_lib_name(get_preferred_artifact(lib))]
    elif _is_dylib(lib):
        return ["-ldylib=%s" % get_lib_name(get_preferred_artifact(lib))]
    return []

def _libraries_dirnames(linker_input):
    return [get_preferred_artifact(lib).dirname for lib in linker_input.libraries]

def _add_native_link_flags(args, dep_info, crate_type, toolchain, cc_toolchain, feature_configuration):
    """Forked from https://github.com/bazelbuild/rules_rust/blob/main/rust/private/rustc.bzl

    """
    args.add_all(dep_info.transitive_noncrates, map_each = _libraries_dirnames, uniquify = True, format_each = "-Lnative=%s")

    if crate_type in ["lib", "rlib"]:
        return

    make_link_flags = _make_link_flags_default

    args.add_all(dep_info.transitive_noncrates, map_each = make_link_flags)

    if crate_type in ["dylib", "cdylib"]:
        # For shared libraries we want to link C++ runtime library dynamically
        # (for example libstdc++.so or libc++.so).
        args.add_all(
            cc_toolchain.dynamic_runtime_lib(feature_configuration = feature_configuration),
            map_each = _get_dirname,
            format_each = "-Lnative=%s",
        )
        args.add_all(
            cc_toolchain.dynamic_runtime_lib(feature_configuration = feature_configuration),
            map_each = get_lib_name,
            format_each = "-ldylib=%s",
        )
    else:
        # For all other crate types we want to link C++ runtime library statically
        # (for example libstdc++.a or libc++.a).
        args.add_all(
            cc_toolchain.static_runtime_lib(feature_configuration = feature_configuration),
            map_each = _get_dirname,
            format_each = "-Lnative=%s",
        )
        args.add_all(
            cc_toolchain.static_runtime_lib(feature_configuration = feature_configuration),
            map_each = get_lib_name,
            format_each = "-lstatic=%s",
        )

def _get_dirname(file):
    return file.dirname

def _crate_to_link_flag(crate_info):
    return ["--extern", "{}={}".format(crate_info.name, crate_info.dep.output.path)]

def _get_crate_dirname(crate):
    return crate.output.dirname

def add_crate_link_flags(args, dep_info):
    """Forked from https://github.com/bazelbuild/rules_rust/blob/main/rust/private/rustc.bzl

    """

    # nb. Crates are linked via --extern regardless of their crate_type
    args.add_all(dep_info.direct_crates, map_each = _crate_to_link_flag)
    args.add_all(
        dep_info.transitive_crates,
        map_each = _get_crate_dirname,
        uniquify = True,
        format_each = "-Ldependency=%s",
    )

def construct_arguments(
        ctx,
        attr,
        file,
        toolchain,
        tool_path,
        cc_toolchain,
        feature_configuration,
        crate_type,
        crate_info,
        dep_info,
        output_hash,
        rust_flags,
        out_dir,
        build_env_files,
        build_flags_files,
        maker_path = None,
        emit = ["dep-info", "link"]):
    """Forked from https://github.com/bazelbuild/rules_rust/blob/main/rust/private/rustc.bzl

    """
    output_dir = getattr(crate_info.output, "dirname") if hasattr(crate_info.output, "dirname") else None

    linker_script = getattr(file, "linker_script") if hasattr(file, "linker_script") else None

    env = _get_rustc_env(attr, toolchain)

    # Wrapper args first
    args = ctx.actions.args()

    for build_env_file in build_env_files:
        args.add("--env-file", build_env_file)

    args.add_all(build_flags_files, before_each = "--arg-file")

    # Certain rust build processes expect to find files from the environment
    # variable `$CARGO_MANIFEST_DIR`. Examples of this include pest, tera,
    # asakuma.
    #
    # The compiler and by extension proc-macros see the current working
    # directory as the Bazel exec root. This is what `$CARGO_MANIFEST_DIR`
    # would default to but is often the wrong value (e.g. if the source is in a
    # sub-package or if we are building something in an external repository).
    # Hence, we need to set `CARGO_MANIFEST_DIR` explicitly.
    #
    # Since we cannot get the `exec_root` from starlark, we cheat a little and
    # use `${pwd}` which resolves the `exec_root` at action execution time.
    args.add("--subst", "pwd=${pwd}")

    # Both ctx.label.workspace_root and ctx.label.package are relative paths
    # and either can be empty strings. Avoid trailing/double slashes in the path.
    components = "${{pwd}}/{}/{}".format(ctx.label.workspace_root, ctx.label.package).split("/")
    env["CARGO_MANIFEST_DIR"] = "/".join([c for c in components if c])

    if out_dir != None:
        env["OUT_DIR"] = "${pwd}/" + out_dir

    # Handle that the binary name and crate name may be different.
    #
    # If a target name contains a - then cargo (and rules_rust) will generate a
    # crate name with _ instead.  Accordingly, rustc will generate a output
    # file (executable, or rlib, or whatever) with _ not -.  But when cargo
    # puts a binary in the target/${config} directory, and sets environment
    # variables like `CARGO_BIN_EXE_${binary_name}` it will use the - version
    # not the _ version.  So we rename the rustc-generated file (with _s) to
    # have -s if needed.
    emit_with_paths = emit
    if crate_info.type == "bin" and crate_info.output != None:
        generated_file = crate_info.name + toolchain.binary_ext
        src = "/".join([crate_info.output.dirname, generated_file])
        dst = crate_info.output.path
        if src != dst:
            emit_with_paths = [("link=" + dst if val == "link" else val) for val in emit]

    if maker_path != None:
        args.add("--touch-file", maker_path)

    args.add("--")
    args.add(tool_path)

    # Rustc arguments
    args.add(crate_info.root)
    args.add("--crate-name=" + crate_info.name)
    args.add("--crate-type=" + crate_info.type)
    if hasattr(attr, "_error_format"):
        args.add("--error-format=" + attr._error_format[ErrorFormatInfo].error_format)

    # Mangle symbols to disambiguate crates with the same name
    extra_filename = "-" + output_hash if output_hash else ""
    args.add("--codegen=metadata=" + extra_filename)
    if output_dir:
        args.add("--out-dir=" + output_dir)
    args.add("--codegen=extra-filename=" + extra_filename)

    compilation_mode = get_compilation_mode_opts(ctx, toolchain)
    args.add("--codegen=opt-level=" + compilation_mode.opt_level)
    args.add("--codegen=debuginfo=" + compilation_mode.debug_info)

    # For determinism to help with build distribution and such
    args.add("--remap-path-prefix=${pwd}=.")

    args.add("--emit=" + ",".join(emit_with_paths))
    args.add("--color=always")
    target = toolchain.target_triple

    args.add("--target=" + target)
    if hasattr(attr, "crate_features"):
        args.add_all(getattr(attr, "crate_features"), before_each = "--cfg", format_each = 'feature="%s"')
    if linker_script:
        args.add(linker_script.path, format = "--codegen=link-arg=-T%s")

    # Gets the paths to the folders containing the standard library (or libcore)
    rust_lib_paths = depset([file.dirname for file in toolchain.rust_lib.files.to_list()]).to_list()

    # Tell Rustc where to find the standard library
    args.add_all(rust_lib_paths, before_each = "-L", format_each = "%s")
    args.add_all(rust_flags)

    data_paths = getattr(attr, "data", []) + getattr(attr, "compile_data", [])
    args.add_all(
        expand_list_element_locations(
            ctx,
            getattr(attr, "rustc_flags", []),
            data_paths,
        ),
    )
    if crate_info.edition != "2015":
        args.add("--edition={}".format(crate_info.edition))

    # Link!
    if "link" in emit:
        # Rust's built-in linker can handle linking wasm files. We don't want to attempt to use the cc
        # linker since it won't understand.
        args.add("--codegen=linker=/usr/bin/ld")
        args.add("--codegen=link-arg=-n")
        _add_native_link_flags(args, dep_info, crate_type, toolchain, cc_toolchain, feature_configuration)

    # These always need to be added, even if not linking this crate.
    add_crate_link_flags(args, dep_info)

    needs_extern_proc_macro_flag = "proc-macro" in [crate_info.type] and \
                                   crate_info.edition != "2015"
    if needs_extern_proc_macro_flag:
        args.add("--extern")
        args.add("proc_macro")

    # Make bin crate data deps available to tests.
    for data in getattr(attr, "data", []):
        if rust_common.crate_info in data:
            dep_crate_info = data[rust_common.crate_info]
            if dep_crate_info.type == "bin":
                env["CARGO_BIN_EXE_" + dep_crate_info.output.basename] = dep_crate_info.output.short_path

    # Update environment with user provided variables.
    env.update(expand_dict_value_locations(
        ctx,
        crate_info.rustc_env,
        data_paths,
    ))

    # This empty value satisfies Clippy, which otherwise complains about the
    # sysroot being undefined.
    env["SYSROOT"] = ""

    return args, env

def rustc_compile_action(
        ctx,
        toolchain,
        crate_type,
        crate_info,
        output_hash = None,
        rust_flags = [],
        environ = {}):
    """Forked from https://github.com/bazelbuild/rules_rust/blob/main/rust/private/rustc.bzl
    """
    cc_toolchain, feature_configuration = find_cc_toolchain(ctx)

    dep_info, build_info = collect_deps(
        label = ctx.label,
        deps = crate_info.deps,
        proc_macro_deps = crate_info.proc_macro_deps,
        aliases = crate_info.aliases,
    )

    compile_inputs, out_dir, build_env_files, build_flags_files = collect_inputs(
        ctx,
        ctx.file,
        ctx.files,
        toolchain,
        cc_toolchain,
        crate_info,
        dep_info,
        build_info,
    )

    args, env = construct_arguments(
        ctx,
        ctx.attr,
        ctx.file,
        toolchain,
        toolchain.rustc.path,
        cc_toolchain,
        feature_configuration,
        crate_type,
        crate_info,
        dep_info,
        output_hash,
        rust_flags,
        out_dir,
        build_env_files,
        build_flags_files,
    )

    if hasattr(ctx.attr, "version") and ctx.attr.version != "0.0.0":
        formatted_version = " v{}".format(ctx.attr.version)
    else:
        formatted_version = ""

    ctx.actions.run(
        executable = ctx.executable._process_wrapper,
        inputs = compile_inputs,
        outputs = [crate_info.output],
        env = env,
        arguments = [args],
        mnemonic = "Rustc",
        progress_message = "Compiling Rust {} {}{} ({} files)".format(
            crate_info.type,
            ctx.label.name,
            formatted_version,
            len(crate_info.srcs.to_list()),
        ),
    )

    dylibs = [get_preferred_artifact(lib) for linker_input in dep_info.transitive_noncrates.to_list() for lib in linker_input.libraries if _is_dylib(lib)]

    runfiles = ctx.runfiles(
        files = dylibs + getattr(ctx.files, "data", []),
        collect_data = True,
    )

    out_binary = False
    if hasattr(ctx.attr, "out_binary"):
        out_binary = getattr(ctx.attr, "out_binary")

    providers = [
        crate_info,
        dep_info,
        DefaultInfo(
            # nb. This field is required for cc_library to depend on our output.
            files = depset([crate_info.output]),
            runfiles = runfiles,
            executable = crate_info.output if crate_info.type == "bin" or crate_info.is_test or out_binary else None,
        ),
    ]

    return providers
