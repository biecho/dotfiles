#!/usr/bin/env python3

"""
Nerd Fonts Installation Script (Python version with logging).

1. Creates ~/.local/share/fonts (if it doesn't exist).
2. Downloads selected Nerd Fonts from GitHub (raw links).
3. Places them in ~/.local/share/fonts/<Name>NerdFont-Regular.otf.
4. Refreshes the font cache with fc-cache (if available on the system).
"""

import sys
import shutil
import subprocess
import logging
from pathlib import Path

import requests

from installer_utils import logger

# -------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------
FONT_DIR = Path.home() / ".local" / "share" / "fonts"
FONTS = {
    "DroidSansMono": "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/DroidSansMono/DroidSansMNerdFont-Regular.otf",
    "FiraCode": "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.otf",
    "JetBrainsMono": "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/JetBrainsMono/Regular/JetBrainsMonoNerdFont-Regular.otf",
    "Hack": "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Hack/Regular/HackNerdFont-Regular.otf",
    "MesloLGS": "https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/L/Regular/MesloLGSNerdFont-Regular.otf"
}


# -------------------------------------------------------------------
# Functions
# -------------------------------------------------------------------
def download_font(font_name: str, url: str, dest_dir: Path) -> None:
    """
    Downloads the given font URL and saves it as <font_name>NerdFont-Regular.otf
    in the 'dest_dir' directory.
    """
    logger.info(f"Downloading {font_name} Nerd Font...")
    destination_file = dest_dir / f"{font_name}NerdFont-Regular.otf"

    try:
        response = requests.get(url, stream=True, timeout=60)
        response.raise_for_status()  # raise HTTPError if status != 200
        with open(destination_file, "wb") as f:
            shutil.copyfileobj(response.raw, f)
    except Exception as e:
        logger.error(f"Failed to download {font_name} from {url}: {e}")


def refresh_font_cache() -> None:
    """
    Checks if fc-cache is available and runs it to refresh the font cache.
    Otherwise, logs a warning to refresh manually.
    """
    from shutil import which
    if which("fc-cache") is not None:
        logger.info("Refreshing font cache with fc-cache -fv...")
        try:
            subprocess.run(["fc-cache", "-fv"], check=True)
        except subprocess.CalledProcessError as e:
            logger.error(f"'fc-cache' failed with exit code {e.returncode}")
    else:
        logger.warning("Font cache utility (fc-cache) not found; please refresh fonts manually.")


def main():
    # 1) Ensure the font directory exists
    FONT_DIR.mkdir(parents=True, exist_ok=True)

    # 2) Download each Nerd Font in the FONTS dict
    for font_name, url in FONTS.items():
        download_font(font_name, url, FONT_DIR)

    # 3) Refresh font cache
    refresh_font_cache()

    logger.info("Nerd Fonts installation complete!")


if __name__ == "__main__":
    main()
