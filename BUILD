""" Workspace main build file """


load("//:defs.bzl", "WORKSPACE_VERSION")


genrule(
    name = "generate_rust_env_file",
    outs = ["rust_jarvis_env_file"],
    cmd = "echo CARGO_PKG_VERSION={} > $@".format(WORKSPACE_VERSION),
    visibility = ["//:__subpackages__"],
    )

