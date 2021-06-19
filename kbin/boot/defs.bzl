load("@kbuild_deps//:defs.bzl", "crate")

deps = [
    "@rust_linux_x86_64//lib/rustlib/src/library/core:core",
    "//kbin/kernel:kernel",
]
