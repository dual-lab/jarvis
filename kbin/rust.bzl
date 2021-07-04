load("@rules_rust//rust/private:common.bzl", "rust_common")
load(
    "@rules_rust//rust/private:utils.bzl",
    "crate_name_from_attr",
    "determine_output_hash",
    "find_toolchain",
)
load(":rustc.bzl", "rustc_compile_action")

_common_providers = [
    rust_common.crate_info,
    rust_common.dep_info,
    DefaultInfo,
]

def _shortest_src_with_basename(srcs, basename):
    shortest = None
    for f in srcs:
        if f.basename == basename:
            if not shortest or len(f.dirname) < len(shortest.dirname):
                shortest = f
    return shortest

def get_edition(attr, toolchain):
    if getattr(attr, "edition"):
        return attr.edition
    else:
        return toolchain.default_edition

def crate_root_src(attr, srcs, crate_type):
    default_crate_root_filename = "main.rs" if crate_type == "bin" else "lib.rs"

    crate_root = None
    if hasattr(attr, "crate_root"):
        if attr.crate_root:
            crate_root = attr.crate_root.files.to_list()[0]

    if not crate_root:
        crate_root = (
            (srcs[0] if len(srcs) == 1 else None) or
            _shortest_src_with_basename(srcs, default_crate_root_filename) or
            _shortest_src_with_basename(srcs, attr.name + ".rs")
        )
    if not crate_root:
        file_names = [default_crate_root_filename, attr.name + ".rs"]
        fail("No {} source file found.".format(" or ".join(file_names)), "srcs")
    return crate_root

def _rust_binary_impl(ctx):
    toolchain = find_toolchain(ctx)
    crate_name = crate_name_from_attr(ctx.attr)

    
    name_suffix = toolchain.target_arch.split("/")
    name_suffix = name_suffix[len(name_suffix) - 1]

    output = ctx.actions.declare_file(ctx.label.name + name_suffix + toolchain.binary_ext)
    
    return rustc_compile_action(
        ctx = ctx,
        toolchain = toolchain,
        crate_type = ctx.attr.crate_type,
        crate_info = rust_common.crate_info(
            name = crate_name, 
            type = ctx.attr.crate_type,
            root = crate_root_src(ctx.attr, ctx.files.srcs, ctx.attr.crate_type),
            srcs = depset(ctx.files.srcs),
            deps = depset(ctx.attr.deps),
            proc_macro_deps = depset(ctx.attr.proc_macro_deps),
            aliases = ctx.attr.aliases,
            output = output,
            edition = get_edition(ctx.attr, toolchain),
            rustc_env = ctx.attr.rustc_env,
            is_test = False,
        ),
    )

rust_binary = rule(
    implementation = _rust_binary_impl,
    provides = _common_providers,
    attrs = {
        "aliases": attr.label_keyed_string_dict(
        ),
        "compile_data": attr.label_list(
            allow_files = True,
        ),
        "crate_features": attr.string_list(
        ),
        "crate_name": attr.string(
        ),
        "crate_root": attr.label(
            allow_single_file = [".rs"],
        ),
        "data": attr.label_list(
            allow_files = True,
        ),
        "deps": attr.label_list(
        ),
        "edition": attr.string(
        ),
        "proc_macro_deps": attr.label_list(
            cfg = "exec",
            providers = [rust_common.crate_info],
        ),
        "rustc_env": attr.string_dict(
        ),
        "rustc_env_files": attr.label_list(
        ),
        "rustc_flags": attr.string_list(
        ),
        "srcs": attr.label_list(
            allow_files = [".rs"],
        ),
        "version": attr.string(
            default = "0.0.0",
        ),
        "_cc_toolchain": attr.label(
            default = "@bazel_tools//tools/cpp:current_cc_toolchain",
        ),
        "_process_wrapper": attr.label(
            default = Label("@rules_rust//util/process_wrapper"),
            executable = True,
            allow_single_file = True,
            cfg = "exec",
        ),
        "crate_type": attr.string(
            default = "bin",
        ),
        "linker_script": attr.label(
            cfg = "exec",
            allow_single_file = True,
        ),
        "custom_target": attr.label(
            allow_single_file = [".json"],
        ),
        "out_binary": attr.bool(),
    },
    executable = True,
    fragments = ["cpp"],
    host_fragments = ["cpp"],
    toolchains = [
        str(Label("@rules_rust//rust:toolchain")),
        "@bazel_tools//tools/cpp:toolchain_type",
    ],
    incompatible_use_toolchain_transition = True,
)
