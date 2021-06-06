"""Macro to load crate universe dependecies  """

load("@rules_rust//crate_universe:defs.bzl", "crate_universe")

def deps():
  crate_universe(
      name = "kbuild_deps",
      cargo_toml_files = ["//kbuild:Cargo.toml"],
      lockfile = "//kbuild:bazel.lock",
      )
