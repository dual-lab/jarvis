DEFAULT_VERSION = "nightly"

def check_version_for_repo(version, iso_date):
    """Verifiy that combination of version and iso_date ara valid"""

    if not version or not iso_date:
        fail("iso_date and version are required")

    if version != "nightly":
        fail("The version must be nigthly")
