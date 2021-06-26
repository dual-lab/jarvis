load("@rules_rust//rust:toolchain.bzl", "rust_toolchain")
load(":helpers.bzl", "DEFAULT_RUST_REPO_TRIPLES_MAPPER", "DEFAULT_SUPPORTED_TRIPLES", "compose_toolchain_name")

def setup_jarvis_toolchains():
    """Setup all supported jarvis toolchain"""

    for arch in DEFAULT_SUPPORTED_TRIPLES:
        declare_jarvis_toolchain(
            name = compose_toolchain_name(DEFAULT_RUST_REPO_TRIPLES_MAPPER[arch]),
            workspace = DEFAULT_RUST_REPO_TRIPLES_MAPPER[arch],
            arch = arch,
        )

def declare_jarvis_toolchain(
        name,
        workspace,
        arch):
    """ Initialize the jarvis toolchain

    N.B. after  call this function we need to register the toolchain name

    Args:
      - target_mapped(str): target for which initialize the toolchain

    Return:
      - the toolchain name
    """
    rust_toolchain(
        name = "{}_impl".format(name),
        rust_doc = "@{}//:rustdoc".format(workspace),
        rust_lib = ":rust_nostd",
        rustc = "@{}//:rustc".format(workspace),
        rustfmt = "@{}//:rustfmt_bin".format(workspace),
        cargo = "@{}//:cargo".format(workspace),
        clippy_driver = "@{}//:clippy_driver_bin".format(workspace),
        rustc_lib = "@{}//:rustc_lib".format(workspace),
        rustc_srcs = "@{}//lib/rustlib/src:rustc_srcs".format(workspace),
        binary_ext = "",
        staticlib_ext = ".a",
        dylib_ext = ".so",
        stdlib_linkflags = [],
        os = "none",
        target_triple = "/working_home/kbin/{}-jarvis.json".format(arch),
        visibility = ["//visibility:public"],
    )

    native.toolchain(
        name = name,
        exec_compatible_with = [
            "@platforms//cpu:{}".format(arch),
            "@platforms//os:linux",
        ],
        target_compatible_with = [
            "@platforms//cpu:{}".format(arch),
            "@platforms//os:none",
        ],
        toolchain = ":{}_impl".format(name),
        toolchain_type = "@rules_rust//rust:toolchain",
    )
