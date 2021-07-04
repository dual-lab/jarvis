load("@kbuild_deps//:defs.bzl", "crate")

deps = [
    "@jarvis_rust_buildstd//lib/rustlib/src/library/core:core",
    "@jarvis_rust_buildstd//lib/rustlib/compiler_builtins:compiler_builtins",
    "//kbin/kernel:kernel",
]
