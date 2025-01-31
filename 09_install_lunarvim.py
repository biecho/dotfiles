#!/usr/bin/env python3

"""
LunarVim Local Installation Script (Python Version)
1. Checks for required dependencies (nvim>=0.9, git, make, pip, python, npm, node, cargo, rg).
2. Installs LunarVim using the official script (LV_BRANCH='release-1.4/neovim-0.9').
3. Ensures ~/.local/bin is in the PATH (via ~/.zshrc) using ensure_dir_in_path().
4. Adds/overwrites an alias: vi -> lvim in ~/.zshrc.
5. Prompts user to restart or source their shell.
"""

import re
import subprocess
import sys
from pathlib import Path
from shutil import which

# Import logger, run_command, and the new generic function
from installer_utils import logger, run_command, ensure_dir_in_path

DEPENDENCIES = [
    "nvim",
    "git",
    "make",
    "pip",
    "python",
    "npm",
    "node",
    "cargo",
    "rg"
]

MIN_NVIM_VERSION = "0.9.0"
ZSHRC = Path.home() / ".zshrc"


def parse_version(version_str: str):
    """
    Parse a version string (e.g., '0.9.1') into a list of integers [0, 9, 1].
    Non-numeric parts are ignored (e.g., '0.9.1-dev' -> [0, 9, 1]).
    """
    import re
    numeric_parts = re.findall(r"\d+", version_str)
    return [int(x) for x in numeric_parts]


def is_nvim_version_ok() -> bool:
    """
    Checks if 'nvim' is at least MIN_NVIM_VERSION.
    Returns True if OK, False otherwise.
    """
    try:
        output = subprocess.check_output(["nvim", "--version"], text=True)
        first_line = output.splitlines()[0]
        # Typically: 'NVIM v0.9.1'
        match = re.search(r"NVIM v?([\d.]+[0-9A-Za-z-]*)", first_line)
        if not match:
            return False
        installed_str = match.group(1)
        installed_version = parse_version(installed_str)
        required_version = parse_version(MIN_NVIM_VERSION)
        return installed_version >= required_version
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False


def check_dependencies():
    """
    Ensures all dependencies in DEPENDENCIES are installed.
    Exits if any are missing or if Neovim is not >= 0.9.
    """
    for dep in DEPENDENCIES:
        if which(dep) is None:
            logger.error(f"Error: {dep} is not installed. Aborting.")
            sys.exit(1)

    if not is_nvim_version_ok():
        logger.error(
            f"Error: Neovim version must be >= {MIN_NVIM_VERSION}. Aborting."
        )
        sys.exit(1)


def set_vi_alias_to_lvim():
    """
    Overwrite or add 'alias vi=lvim' in ~/.zshrc.
    """
    if not ZSHRC.exists():
        logger.info(f"{ZSHRC} does not exist; creating it and adding alias vi='lvim'.")
        ZSHRC.write_text("alias vi='lvim'\n", encoding="utf-8")
        return

    content = ZSHRC.read_text(encoding="utf-8")
    if "alias vi=" in content:
        updated = re.sub(r"alias vi=.*", "alias vi='lvim'", content)
        ZSHRC.write_text(updated, encoding="utf-8")
        logger.info("Overwritten existing 'vi' alias to point to 'lvim'.")
    else:
        with ZSHRC.open("a", encoding="utf-8") as f:
            f.write("\nalias vi='lvim'\n")
        logger.info("Alias 'vi' to 'lvim' added in .zshrc")


def main():
    # 1) Check dependencies
    check_dependencies()

    # 2) Install LunarVim
    logger.info("All dependencies are met. Installing LunarVim...")
    install_cmd = (
        "LV_BRANCH='release-1.4/neovim-0.9' "
        "curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh "
        "| bash"
    )
    run_command(install_cmd)

    ensure_dir_in_path(ZSHRC, Path.home() / ".local" / "bin")
    set_vi_alias_to_lvim()

    logger.info("LunarVim installation complete!")
    logger.info("You can start it by running: $HOME/.local/bin/lvim")
    logger.info("Remember to use a Nerd Font or glyph-supported font.")
    logger.info("To apply the 'vi' alias, restart your shell or run: source ~/.zshrc")


if __name__ == "__main__":
    main()
