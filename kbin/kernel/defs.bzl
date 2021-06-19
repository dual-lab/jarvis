load("@kbuild_deps//:defs.bzl", "crate")

deps = [
    "//kbin/asm:asm",
    "@rust_linux_x86_64//lib/rustlib/src/library/core:core",
]
