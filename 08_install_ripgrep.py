#!/usr/bin/env python3

"""
Ripgrep Local Installation Script (Python Version)
1. Downloads the specified version of ripgrep (musl build).
2. Extracts the binary to ~/.local/bin.
3. Ensures ~/.local/bin is in the user's PATH (via ~/.zshrc).
4. Verifies the installation.
"""

import sys
from pathlib import Path
import shutil

from installer_utils import logger, run_command

RG_VERSION = "14.1.1"
RG_FILENAME = f"ripgrep-{RG_VERSION}-x86_64-unknown-linux-musl"
TARBALL_NAME = f"{RG_FILENAME}.tar.gz"
DOWNLOAD_URL = f"https://github.com/BurntSushi/ripgrep/releases/download/{RG_VERSION}/{TARBALL_NAME}"

INSTALL_DIR = Path.home() / ".local"
BIN_DIR = INSTALL_DIR / "bin"
ZSHRC = Path.home() / ".zshrc"


def ensure_local_bin_in_zshrc():
    """
    Ensures that ~/.local/bin is in the user's PATH by adding to ~/.zshrc if not already present.
    """
    export_line = 'export PATH="$HOME/.local/bin:$PATH"'
    if not ZSHRC.exists():
        logger.info(f"{ZSHRC} does not exist; creating and adding ~/.local/bin to PATH.")
        ZSHRC.write_text(export_line + "\n", encoding="utf-8")
        return

    content = ZSHRC.read_text(encoding="utf-8")
    if export_line not in content and ".local/bin" not in content:
        logger.info("Adding ~/.local/bin to PATH in ~/.zshrc")
        with ZSHRC.open("a", encoding="utf-8") as f:
            f.write("\n" + export_line + "\n")
    else:
        logger.info("~/.local/bin is already in PATH in ~/.zshrc; skipping update.")


def main():
    logger.info(f"Downloading ripgrep version {RG_VERSION}...")
    # 1) Download the ripgrep tarball
    cmd_download = f'curl -LO {DOWNLOAD_URL}'
    run_command(cmd_download)

    # 2) Extract the tarball
    logger.info("Extracting ripgrep...")
    cmd_extract = f'tar -xzf {TARBALL_NAME}'
    run_command(cmd_extract)

    # 3) Create ~/.local/bin if it doesn't exist
    BIN_DIR.mkdir(parents=True, exist_ok=True)

    # 4) Move the rg binary to ~/.local/bin
    rg_source = Path.cwd() / RG_FILENAME / "rg"
    rg_dest = BIN_DIR / "rg"
    if rg_source.is_file():
        logger.info(f"Moving {rg_source} to {rg_dest}")
        shutil.move(str(rg_source), str(rg_dest))
    else:
        logger.error(f"Could not find rg binary at {rg_source}")
        sys.exit(1)

    # 5) Ensure ~/.local/bin is in PATH (via ~/.zshrc)
    ensure_local_bin_in_zshrc()

    # 6) Clean up downloaded and extracted files
    logger.info("Cleaning up downloaded files...")
    shutil.rmtree(Path.cwd() / RG_FILENAME, ignore_errors=True)
    tarball_path = Path.cwd() / TARBALL_NAME
    if tarball_path.exists():
        tarball_path.unlink()

    # 7) Verify the installation
    logger.info("Verifying ripgrep installation...")
    run_command('command -v rg && rg --version')

    logger.info("ripgrep installation complete!")
    logger.info("Please restart your terminal or run 'source ~/.zshrc' to apply changes.")


if __name__ == "__main__":
    main()
