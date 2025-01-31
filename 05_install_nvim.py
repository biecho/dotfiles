#!/usr/bin/env python3

import sys
from pathlib import Path

from installer_utils import (
    logger,
    download_file,
    extract_tarball,
    create_symlink,
    cleanup_tarball,
)

# -------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------
STABLE_URL = "https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz"
TARBALL_NAME = "nvim-linux-x86_64.tar.gz"


def main():
    home = Path.home()
    tarball_path = home / TARBALL_NAME

    local_nvim_dir = home / ".local" / "nvim"
    local_bin_dir = home / ".local" / "bin"

    download_file(STABLE_URL, tarball_path)

    # Clear old nvim directory if it exists (destructive!)
    if local_nvim_dir.exists():
        logger.info(f"Removing old directory: {local_nvim_dir}")
        # Use caution here if you have other data in ~/.local/nvim
        import shutil
        shutil.rmtree(local_nvim_dir, ignore_errors=True)
    local_nvim_dir.mkdir(parents=True, exist_ok=True)

    top_level_dir = extract_tarball(tarball_path, local_nvim_dir)
    extracted_dir = local_nvim_dir / top_level_dir  # e.g. ~/.local/nvim/nvim-linux64

    nvim_binary = extracted_dir / "bin" / "nvim"
    if not nvim_binary.exists():
        logger.error(f"nvim binary not found at {nvim_binary}")
        sys.exit(1)

    # Create symlink in ~/.local/bin
    nvim_symlink = local_bin_dir / "nvim"
    create_symlink(nvim_binary, nvim_symlink)

    cleanup_tarball(tarball_path)

    logger.info("Neovim has been installed locally!")
    logger.info("Ensure ~/.local/bin is in your PATH. For example, add:")
    logger.info('    export PATH="$HOME/.local/bin:$PATH"')
    logger.info("to your shell startup file (e.g., ~/.bashrc or ~/.zshrc).")


if __name__ == "__main__":
    main()
