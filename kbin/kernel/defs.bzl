load("@kbuild_deps//:defs.bzl", "crate")

deps = [
    "//kbin/asm:asm",
    "@jarvis_rust_buildstd//lib/rustlib/src/library/core:core",
]
