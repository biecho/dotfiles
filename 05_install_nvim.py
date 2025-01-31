#!/usr/bin/env python3

import logging
import shutil
import sys
import tarfile
import urllib.request
from pathlib import Path

# Set up logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.INFO)
formatter = logging.Formatter("[%(levelname)s] %(message)s")
console_handler.setFormatter(formatter)
logger.addHandler(console_handler)

STABLE_URL = "https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz"
TARBALL_NAME = "nvim-linux-x86_64.tar.gz"

def download_tarball(url: str, destination: Path) -> None:
    """
    Downloads a file from the given URL to the specified destination using urllib.
    """
    logger.info(f"Downloading Neovim from: {url}")
    try:
        urllib.request.urlretrieve(url, destination)
    except Exception as e:
        logger.error(f"Download failed: {e}")
        sys.exit(1)

def extract_tarball(tarball_path: Path, extract_destination: Path) -> str:
    """
    Extracts the tarball into the given directory.
    Returns the name of the top-level extracted folder (e.g., 'nvim-linux64').
    """
    logger.info(f"Extracting {tarball_path} to {extract_destination}")
    try:
        with tarfile.open(tarball_path, "r:gz") as tar:
            tar.extractall(path=extract_destination)

        # Find the top-level directory name from the tar archive
        with tarfile.open(tarball_path, "r:gz") as tar:
            top_level_entry = tar.getmembers()[0]
            top_level_dir = top_level_entry.name.split("/")[0]
        return top_level_dir
    except Exception as e:
        logger.error(f"Extraction failed: {e}")
        sys.exit(1)

def create_symlink(source: Path, symlink_path: Path) -> None:
    """
    Creates or updates a symlink from 'symlink_path' pointing to 'source'.
    """
    # Ensure the parent directory of the symlink exists
    symlink_path.parent.mkdir(parents=True, exist_ok=True)

    # If a symlink (or file) already exists, remove it
    if symlink_path.is_symlink() or symlink_path.exists():
        symlink_path.unlink()

    logger.info(f"Creating symlink: {symlink_path} -> {source}")
    symlink_path.symlink_to(source)

def cleanup_tarball(tarball_path: Path) -> None:
    """
    Removes the downloaded tarball.
    """
    if tarball_path.exists():
        try:
            logger.info(f"Removing tarball: {tarball_path}")
            tarball_path.unlink()
        except Exception as e:
            logger.warning(f"Could not remove tarball: {e}")

def main():
    home = Path.home()
    tarball_path = home / TARBALL_NAME

    local_nvim_dir = home / ".local" / "nvim"
    local_bin_dir = home / ".local" / "bin"
    nvim_symlink = local_bin_dir / "nvim"

    # 1. Download the stable tarball
    download_tarball(STABLE_URL, tarball_path)

    # 2. Clear old nvim directory if it exists (destructive!)
    if local_nvim_dir.exists():
        logger.info(f"Removing old directory: {local_nvim_dir}")
        shutil.rmtree(local_nvim_dir, ignore_errors=True)
    local_nvim_dir.mkdir(parents=True, exist_ok=True)

    # 3. Extract tarball
    top_level_dir = extract_tarball(tarball_path, local_nvim_dir)
    extracted_dir = local_nvim_dir / top_level_dir  # e.g. ~/.local/nvim/nvim-linux64

    # 4. Find the nvim binary
    nvim_binary = extracted_dir / "bin" / "nvim"
    if not nvim_binary.exists():
        logger.error(f"nvim binary not found at {nvim_binary}")
        sys.exit(1)

    # 5. Create symlink in ~/.local/bin
    create_symlink(nvim_binary, nvim_symlink)

    # 6. Clean up tarball
    cleanup_tarball(tarball_path)

    logger.info("Neovim has been installed locally!")
    logger.info("Ensure ~/.local/bin is in your PATH. For example, add:")
    logger.info('    export PATH="$HOME/.local/bin:$PATH"')
    logger.info("to your shell startup file (e.g., ~/.bashrc or ~/.zshrc).")

if __name__ == "__main__":
    main()
