#!/usr/bin/env python3

"""
YQ Installation Script (Python version, using shared utilities).

1. Downloads a specified version of yq (for Linux x86_64 by default).
2. Saves it into ~/.local/bin/yq and makes it executable.
3. Ensures ~/.local/bin is in the user's PATH by updating ~/.zshrc if needed.
4. Logs steps with a shared logger from installer_utils.
"""

import stat

from installer_utils import (
    logger,
    download_file,
    ensure_dir_in_path,
    ZSHRC_PATH,
    LOCAL_BIN, ensure_dir_exists
)

# -------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------
VERSION = "v4.30.1"  # Adjust version as needed
BINARY = "yq_linux_amd64"  # For Linux x86_64
DOWNLOAD_URL = f"https://github.com/mikefarah/yq/releases/download/{VERSION}/{BINARY}"


def main():
    ensure_dir_exists(LOCAL_BIN)

    yq_path = LOCAL_BIN / "yq"
    logger.info(f"Downloading yq {VERSION} for Linux x86_64")
    download_file(DOWNLOAD_URL, yq_path)

    logger.info(f"Making {yq_path} executable")
    yq_path.chmod(yq_path.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)

    ensure_dir_in_path(ZSHRC_PATH, LOCAL_BIN)

    logger.info(f"yq {VERSION} installed successfully in {LOCAL_BIN}!")
    logger.info("Open a new terminal or run 'source ~/.zshrc' if needed to update your PATH.")


if __name__ == "__main__":
    main()
