DUMMY_CC_TOOLCHAIN_NAME = "dummy_cc_none_toolchain"
DEFAULT_REPO_NAME = "jarvis"
DEFAULT_SUPPORTED_TRIPLES = ["x86_64"]
DEFAULT_RUST_REPO_TRIPLES_MAPPER = {
    "x86_64": "rust_linux_x86_64",
}
DEFAULT_RUST_COMPILER_BUILTIN_VERSION_MAPPER = {
    "nightly": "0.1.46",
}

def join(
        seq,
        sep = " "):
    """Join a sequence with a specific separator

    Args:
      - seq(list): list of values to join
      - sep(str, optional): separator to join with. Default to one space

    Return:
      - A new string
    """

    if not seq:
        fail("The seq to join is required")

    return sep.join(seq)

def compose_toolchain_name(target_mapped):
    """Compose common toolchains name based on target mapped input

    Args:
      - target_mapped(str): target mapped name.

    Return:
      - the custom toolchain name for the target specified in input
    """
    return "{}_{}_toolchain".format(DEFAULT_REPO_NAME, target_mapped)
