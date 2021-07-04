# jarvis

Example of building an OS with Rust + assenbly. Following the blog posts of [phill-opp](https://os.phil-opp.com/).

## Build with bazel

From the workapsce root run

```shell

export RULES_RUST_CRATE_UNIVERSE_BOOTSTRAP=true

export RULES_RUST_REPIN=true

bazel build //kbuild:kbuild

```
