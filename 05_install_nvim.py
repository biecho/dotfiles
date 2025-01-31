#!/usr/bin/env python3

import os
import sys
import tarfile
import urllib.request
from pathlib import Path

STABLE_URL = "https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz"

def main():
    home = Path.home()
    tarball_name = "nvim-linux-x86_64.tar.gz"
    tarball_path = home / tarball_name

    local_nvim_dir = home / ".local" / "nvim"
    local_bin_dir = home / ".local" / "bin"
    nvim_symlink = local_bin_dir / "nvim"

    print(f"[INFO] Downloading Neovim from: {STABLE_URL}")
    try:
        urllib.request.urlretrieve(STABLE_URL, tarball_path)
    except Exception as e:
        print(f"[ERROR] Download failed: {e}")
        sys.exit(1)

    # Create ~/.local/nvim if it doesn't exist (or clear it if you wish).
    # Here, we remove it if it already exists to ensure a fresh install.
    if local_nvim_dir.exists():
        print(f"[INFO] Removing old directory: {local_nvim_dir}")
        # Be careful with this in a real script—this is a destructive operation.
        import shutil
        shutil.rmtree(local_nvim_dir, ignore_errors=True)
    local_nvim_dir.mkdir(parents=True, exist_ok=True)

    print(f"[INFO] Extracting {tarball_path} to {local_nvim_dir}")
    try:
        with tarfile.open(tarball_path, "r:gz") as tar:
            tar.extractall(path=local_nvim_dir)
    except Exception as e:
        print(f"[ERROR] Extraction failed: {e}")
        sys.exit(1)

    # The tarball will typically extract into a subfolder like ~/.local/nvim/nvim-linux64 or nvim-linux-x86_64
    # Let's find that subfolder dynamically:
    extracted_root = None
    with tarfile.open(tarball_path, "r:gz") as tar:
        top_level = tar.getmembers()[0]
        extracted_root = top_level.name.split("/")[0]

    if not extracted_root:
        print("[ERROR] Could not determine extracted folder name.")
        sys.exit(1)

    # Path to the actual nvim binary
    nvim_binary_path = local_nvim_dir / extracted_root / "bin" / "nvim"

    if not nvim_binary_path.exists():
        print(f"[ERROR] nvim binary not found at {nvim_binary_path}")
        sys.exit(1)

    # Ensure ~/.local/bin exists and remove old symlink if needed
    local_bin_dir.mkdir(parents=True, exist_ok=True)
    if nvim_symlink.is_symlink() or nvim_symlink.exists():
        nvim_symlink.unlink()

    print(f"[INFO] Creating symlink: {nvim_symlink} -> {nvim_binary_path}")
    nvim_symlink.symlink_to(nvim_binary_path)

    # Remove the downloaded tarball
    print(f"[INFO] Removing tarball: {tarball_path}")
    try:
        tarball_path.unlink()
    except Exception as e:
        print(f"[WARN] Could not remove tarball: {e}")

    print("[INFO] Neovim installed locally!")
    print("[INFO] Make sure ~/.local/bin is in your PATH.")
    print('       e.g. add `export PATH="$HOME/.local/bin:$PATH"` to your shell rc file.')

if __name__ == "__main__":
    main()
