#!/usr/bin/env python3

"""
FZF Installation Script (Python version).

1. Clones the fzf repository to ~/.fzf
2. Runs the install script (~/.fzf/install) with key bindings & completion (no auto rc updates).
3. Adds a line to source ~/.fzf.zsh in ~/.zshrc if missing.
4. Adds an alias fkill for multi-selection kill if missing in ~/.zshrc.
"""

import sys
from pathlib import Path
from shutil import which

from installer_utils import logger, run_command, ensure_line_in_file

# -------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------
FZF_REPO_URL = "https://github.com/junegunn/fzf.git"
FZF_DIR = Path.home() / ".fzf"
ZSHRC_PATH = Path.home() / ".zshrc"
FZF_INSTALL_SCRIPT = FZF_DIR / "install"
SOURCE_FZF_LINE = "[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh"
FKILL_ALIAS_LINE = r"alias fkill="
FKILL_ALIAS_BLOCK = (
    "# fzf smart alias for killing multiple processes\n"
    "alias fkill='ps -ef | fzf --multi | awk \"{print \\$2}\" | xargs kill'  # Fuzzy multi-selection kill\n"
)


def main():
    # 1) Check if git is installed
    if which("git") is None:
        logger.error("Git is not installed or not found in PATH. Aborting.")
        sys.exit(1)

    # 2) Clone the fzf repo (shallow clone)
    if FZF_DIR.exists():
        logger.info(f"{FZF_DIR} already exists. Skipping clone.")
    else:
        run_command(f"git clone --depth 1 {FZF_REPO_URL} {FZF_DIR}")

    # 3) Run the fzf install script with flags
    #    ~/.fzf/install --key-bindings --completion --no-update-rc
    if not FZF_INSTALL_SCRIPT.exists():
        logger.error(f"FZF install script not found at {FZF_INSTALL_SCRIPT}. Aborting.")
        sys.exit(1)

    run_command(f"{FZF_INSTALL_SCRIPT} --key-bindings --completion --no-update-rc")

    ensure_line_in_file(ZSHRC_PATH, r"source\s+\~/.fzf.zsh", SOURCE_FZF_LINE)
    ensure_line_in_file(ZSHRC_PATH, FKILL_ALIAS_LINE, FKILL_ALIAS_BLOCK)

    logger.info("fzf installation complete!")
    logger.info("Configuration and aliases have been added to your ~/.zshrc.")
    logger.info("Please restart your terminal or run 'source ~/.zshrc' to apply changes.")


if __name__ == "__main__":
    main()
