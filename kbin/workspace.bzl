"""Macro to load crate universe dependecies  """

load("@rules_rust//crate_universe:defs.bzl", "crate_universe")

def deps():
    crate_universe(
        name = "kbin_deps",
        cargo_toml_files = [
            "//kbin/asm:Cargo.toml",
            "//kbin/boot:Cargo.toml",
            "//kbin/kernel:Cargo.toml",
        ],
        lockfile = "//kbin:bazel.lock",
    )
