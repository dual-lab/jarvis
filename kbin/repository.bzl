load("@rules_rust//rust:toolchain.bzl", "rust_toolchain")
load("//kbin/private:version.bzl", "DEFAULT_VERSION", "check_version_for_repo")

_DEFAULT_REPO_NAME = "jarvis"

def _dummy_cc_toolchain_impl(ctx):
    return [platform_common.ToolchainInfo(all_files = depset([]))]

dummy_cc_toolchain = rule(
    implementation = _dummy_cc_toolchain_impl,
    attrs = {},
)

def _dummy_deps_impl(ctx):
    return [DefaultInfo(files = depset([]))]

dummy_deps = rule(
    implementation = _dummy_deps_impl,
    attrs = {},
)

def declare_jarvis_toolchain():
    dummy_deps(name = "rust_nostd")

    rust_toolchain(
        name = "rust_jarvis_impl",
        rust_doc = "@rust_linux_x86_64//:rustdoc",
        rust_lib = ":rust_nostd",
        rustc = "@rust_linux_x86_64//:rustc",
        rustfmt = "@rust_linux_x86_64//:rustfmt_bin",
        cargo = "@rust_linux_x86_64//:cargo",
        clippy_driver = "@rust_linux_x86_64//:clippy_driver_bin",
        rustc_lib = "@rust_linux_x86_64//:rustc_lib",
        rustc_srcs = "@rust_linux_x86_64//lib/rustlib/src:rustc_srcs",
        binary_ext = "",
        staticlib_ext = ".a",
        dylib_ext = ".so",
        stdlib_linkflags = [],
        os = "none",
        target_triple = "/working_home/kbin/x86_64-jarvis.json",
        visibility = ["//visibility:public"],
    )

    dummy_cc_toolchain(name = "dummy_cc_none")

    native.toolchain(
        name = "dummy_cc_none_toolchain",
        target_compatible_with = [
            "@platforms//os:none",
        ],
        toolchain = ":dummy_cc_none",
        toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
    )

    native.toolchain(
        name = "rust_jarvis",
        exec_compatible_with = [
            "@platforms//cpu:x86_64",
            "@platforms//os:linux",
        ],
        target_compatible_with = [
            "@platforms//cpu:x86_64",
            "@platforms//os:none",
        ],
        toolchain = ":rust_jarvis_impl",
        toolchain_type = "@rules_rust//rust:toolchain",
    )

def jarvis_repository_set(
        name = _DEFAULT_REPO_NAME,
        version = DEFAULT_VERSION,
        exec_triple = [""],
        iso_date = None):
    """Assemble a remote repository for building jarvis kernel, and setup custom toolchains
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
    pass

    # TODO: replace with correct name
    all_toolchains = []
    #native.register_toolchains(*all_toolchains)
    #native.register_toolchains("//kbin:dummy_cc_none_toolchain")
