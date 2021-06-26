load("//kbin/private:version.bzl", "DEFAULT_VERSION", "check_version_for_repo")
load(
    "//kbin/private:helpers.bzl",
    "DEFAULT_REPO_NAME",
    "DEFAULT_RUST_REPO_TRIPLES_MAPPER",
    "DEFAULT_SUPPORTED_TRIPLES",
    "DUMMY_CC_TOOLCHAIN_NAME",
    "compose_toolchain_name",
    "join",
)

def _jarvis_repo_initialize(target_mapped):
    """ Initialize jarvis repository

    Args:
      - target_mapped(str): target for which initilize the repository

    Return:
      - the repository label
    """
    repo_name = DEFAULT_REPO_NAME + "_" + target_mapped

    return repo_name

def jarvis_repository_set(
        name = DEFAULT_REPO_NAME,
        version = DEFAULT_VERSION,
        iso_date = None):
    """Assemble a remote repository for building jarvis kernel and setup custom toolchains.
    We will download only ther rust soruce and compiler_builtin sources, and create bazel
    rule to re-build this target for jarvis architecture.

    All other tools like rustc, rust_fmt ... will be taken from rust_bazel repository setup, so
    for their configuration see rust_baze repository docs [https://bazelbuild.github.io/rules_rust/flatten.html#rust_repositories]

    N.B. Maybe in future all tools will be downloded.

    N.B. Til now the only target suppoted is x86_64

    Args:
      name (str, optional): the name of repository. The name will be suffixed with the target. Default to "jarvis_x86_64"
      version (str, optional): the rust version (till now only nigthly is suported). Default to nightly
      exec_triple (list, optional): list of triple supported. Default to x86_64-jarvis
      iso_date(str): required for the nightly version. Put equal to the one passed to rust_repositories
    """
    print("WIP: Jarvis repository not completed...!!!")

    check_version_for_repo(version, iso_date)

    all_toolchains = ["//kbin/private:{}".format(DUMMY_CC_TOOLCHAIN_NAME)]

    for arch in DEFAULT_SUPPORTED_TRIPLES:
        _jarvis_repo_initialize(
            target_mapped = DEFAULT_RUST_REPO_TRIPLES_MAPPER[arch],
        )
        all_toolchains.append("//kbin/private:{}".format(compose_toolchain_name(DEFAULT_RUST_REPO_TRIPLES_MAPPER[arch])))

    native.register_toolchains(*all_toolchains)
