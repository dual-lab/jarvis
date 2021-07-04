load("@rules_rust//rust:repositories.bzl", "produce_tool_path", "produce_tool_suburl")
load("@rules_rust//rust:known_shas.bzl", "FILE_KEY_TO_SHA")
load("//kbin/private:version.bzl", "DEFAULT_VERSION", "check_version_for_repo")
load(
    "//kbin/private:helpers.bzl",
    "DEFAULT_REPO_NAME",
    "DEFAULT_RUST_COMPILER_BUILTIN_VERSION_MAPPER",
    "DEFAULT_RUST_REPO_TRIPLES_MAPPER",
    "DEFAULT_SUPPORTED_TRIPLES",
    "DUMMY_CC_TOOLCHAIN_NAME",
    "compose_toolchain_name",
    "join",
)

def _load_rust_srcs(ctx):
    """Load rust source code into the repository
    Args:
      - ctx(repository_ctx): the repository context
    """

    tool_suburl = produce_tool_suburl("rust", ctx.attr.version, "src", ctx.attr.iso_date)
    static_rust = ctx.os.environ.get("STATIC_RUST_URL", "https://static.rust-lang.org")
    url = "{}/dist/{}.tar.gz".format(static_rust, tool_suburl)

    tool_path = produce_tool_path("rust", ctx.attr.version, "src")
    archive_path = tool_path + ".tar.gz"

    ctx.download(
        url,
        output = archive_path,
        sha256 = FILE_KEY_TO_SHA.get(tool_suburl) or "",
    )
    ctx.extract(
        archive_path,
        output = "lib/rustlib/src",
        stripPrefix = tool_path + "/rust-src/lib/rustlib/src/rust",
    )
    ctx.template(
        "lib/rustlib/src/library/core/BUILD",
        ctx.attr._core_template,
        substitutions = {
            "workapsce_key": ctx.name,
            "edition_key": ctx.attr.edition,
        },
        executable = False,
    )
    ctx.template(
        "lib/rustlib/src/library/stdarch/crates/core_arch/BUILD",
        ctx.attr._core_arch_template,
        executable = False,
    )

def _load_compiler_builtin(ctx):
    compiler_builtin_version = DEFAULT_RUST_COMPILER_BUILTIN_VERSION_MAPPER[ctx.attr.version]

    if not compiler_builtin_version:
        fail("No  compiler builtin version for rust v{}".format(ctx.attr.version))

    static_rust_compiler_builtin = ctx.os.environ.get("STATIC_COMPILER_BUILTIN", "https://github.com/rust-lang/compiler-builtins/archive/refs/tags")
    url = "{}/{}.tar.gz".format(static_rust_compiler_builtin, compiler_builtin_version)

    archive_path = produce_tool_path("compiler_builtins", compiler_builtin_version, "src") + ".tar.gz"
    ctx.download(
        url,
        output = archive_path,
    )

    ctx.extract(
        archive_path,
        output = "lib/rustlib/compiler_builtins",
        stripPrefix = "compiler-builtins-" + compiler_builtin_version,
    )

    ctx.template(
        "lib/rustlib/compiler_builtins/BUILD",
        ctx.attr._compiler_builtins_template,
        executable = False,
        substitutions = {
            "edition_key": "2015",
            "workapsce_key": ctx.name,
        },
    )

def _jarvis_build_std_repository_impl(ctx):
    print("WIP: JARVIS repo implementation")
    check_version_for_repo(ctx.attr.version, ctx.attr.iso_date)

    _load_rust_srcs(ctx)

    _load_compiler_builtin(ctx)

    ctx.file("WORKSPACE.bazel", "")
    ctx.file("BUILD.bazel", "")

jarvis_build_std_repository = repository_rule(
    doc = join([
        "Build std core + compiler built-in repository",
    ]),
    attrs = {
        "iso_date": attr.string(
            doc = "The date of the source to download",
        ),
        "version": attr.string(
            doc = "The version of the source to download",
            default = DEFAULT_VERSION,
        ),
        "edition": attr.string(
            doc = "The rust edition to compile with",
            default = "2018",
        ),
        "_core_template": attr.label(
            doc = "Core BUILD bazel file",
            default = "//kbin/private/template:_BUILD_CORE",
        ),
        "_core_arch_template": attr.label(
            doc = "Core arch bazel file",
            default = "//kbin/private/template:_BUILD_CORE_ARCH",
        ),
        "_compiler_builtins_template": attr.label(
            doc = "Compiler builtins bazel file",
            default = "//kbin/private/template:_BUILD_COMPILER_BUILTINS",
        ),
    },
    implementation = _jarvis_build_std_repository_impl,
)

def _jarvis_repo_initialize(name, iso_date, version):
    """ Initialize jarvis repository

    Args:
      - name(str): repo name
      - iso_date(str): date of the source code to download
      - version(str): version of source code to download

    Return:
      - the repository label
    """
    repo_name = name + "_rust_buildstd"

    jarvis_build_std_repository(
        name = repo_name,
        iso_date = iso_date,
        version = version,
    )

    return repo_name

def jarvis_repository_set(
        name = DEFAULT_REPO_NAME,
        version = DEFAULT_VERSION,
        iso_date = None):
    """Assemble a remote repository for building jarvis kernel and setup custom toolchains.
    We will download only ther rust soruce and compiler_builtin sources, and create bazel
    rule to re-build this target for jarvis architecture.

    All other tools like rustc, rust_fmt ... will be taken from rust_bazel repository setup, so
    for their configuration see rust_baze repository docs [https://bazelbuild.github.io/rules_rust/flatten.html#rust_repositories]

    N.B. Maybe in future all tools will be downloded.

    N.B. Til now the only target suppoted is x86_64

    Args:
      name (str, optional): the name of repository. The name will be suffixed with the target. Default to "jarvis_x86_64"
      version (str, optional): the rust version (till now only nigthly is suported). Default to nightly
      exec_triple (list, optional): list of triple supported. Default to x86_64-jarvis
      iso_date(str): required for the nightly version. Put equal to the one passed to rust_repositories
    """
    print("WIP: Jarvis repository not completed...!!!")

    check_version_for_repo(version, iso_date)

    _jarvis_repo_initialize(
        name = name,
        iso_date = iso_date,
        version = version,
    )

    all_toolchains = ["//kbin/private:{}".format(DUMMY_CC_TOOLCHAIN_NAME)]

    for arch in DEFAULT_SUPPORTED_TRIPLES:
        all_toolchains.append("//kbin/private:{}".format(compose_toolchain_name(DEFAULT_RUST_REPO_TRIPLES_MAPPER[arch])))

    native.register_toolchains(*all_toolchains)
