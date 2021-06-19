load("@rules_rust//rust:toolchain.bzl", "rust_toolchain")

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
