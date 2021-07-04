load(":helpers.bzl", "join")

def _dummy_cc_toolchain_impl(ctx):
    """Dummy cc toolchain implementation function."""
    return [platform_common.ToolchainInfo(all_files = depset([]))]

dummy_cc_toolchain = rule(
    doc = join([
        "Dummy toolchain rule needed by the rust compiler rule.",
    ]),
    implementation = _dummy_cc_toolchain_impl,
    attrs = {},
)

def _dummy_deps_impl(ctx):
    """Dummy deps set implementation function"""
    return [DefaultInfo(files = depset([]))]

dummy_deps = rule(
    doc = join([
        "Dummy deps rule to generate empty dependencies.",
    ]),
    implementation = _dummy_deps_impl,
    attrs = {},
)
