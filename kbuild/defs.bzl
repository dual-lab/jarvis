load("@kbuild_deps//:defs.bzl", "crate")

_commons_deps = [
    crate("structopt"),
    crate("anyhow"),
    crate("log"),
    crate("env_logger"),
    crate("exitcode"),
    crate("confy"),
]

def lib_deps():
    _deps = [crate("serde")]
    return _deps + _commons_deps

def bin_deps():
    _deps = [":kbuild_lib"]
    return _deps + _commons_deps
