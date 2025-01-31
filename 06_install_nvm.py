#!/usr/bin/env python3

"""
NVM (Node Version Manager) Local Installation Script (Python Version)

1. Downloads & runs the official NVM installer script from GitHub.
2. Exports NVM_DIR in the current session and attempts to load NVM.
3. Appends NVM load commands to ~/.zshrc for future sessions.
4. Verifies the NVM installation by running 'zsh -ic "command -v nvm"'.
"""

import os
import sys
from pathlib import Path
from installer_utils import logger, run_command  # from your shared utilities

NVM_INSTALLER_URL = "https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh"
NVM_DIR = Path.home() / ".nvm"
ZSHRC = Path.home() / ".zshrc"


def update_zshrc_for_nvm():
    """
    Appends NVM initialization lines to ~/.zshrc if not already present.
    """
    lines_to_add = [
        f'export NVM_DIR="{NVM_DIR}"',
        '[ -s "$NVM_DIR/nvm.sh" ] && \\. "$NVM_DIR/nvm.sh"  # Load NVM'
    ]

    if not ZSHRC.exists():
        # If ~/.zshrc doesn't exist, create it with the needed lines
        logger.info(f"{ZSHRC} does not exist; creating it...")
        ZSHRC.write_text("\n".join(lines_to_add) + "\n", encoding="utf-8")
        return

    content = ZSHRC.read_text(encoding="utf-8")
    if "NVM_DIR" not in content:
        logger.info(f"Adding NVM lines to {ZSHRC}")
        with ZSHRC.open("a", encoding="utf-8") as f:
            f.write("\n" + "\n".join(lines_to_add) + "\n")
    else:
        logger.info(f"{ZSHRC} already contains NVM configuration. Skipping update.")


def main():
    # 1) Download & Run the official NVM installation script
    logger.info("Installing NVM locally...")
    cmd = f'curl -o- {NVM_INSTALLER_URL} | bash'
    run_command(cmd)

    # 2) Export NVM_DIR in this shell & try to load nvm.sh (optional immediate check)
    os.environ["NVM_DIR"] = str(NVM_DIR)
    nvm_sh = NVM_DIR / "nvm.sh"
    if nvm_sh.is_file():
        # This won't change your *interactive* Python environment,
        # but we can do a quick version check in a subshell:
        run_command(f'. {nvm_sh} && nvm --version')
    else:
        logger.warning(f"nvm.sh not found at {nvm_sh}, cannot source it in this session.")

    # 3) Update ~/.zshrc so future Zsh sessions load NVM automatically
    update_zshrc_for_nvm()

    # 4) Verify installation by spawning an interactive Zsh shell
    logger.info("Verifying NVM installation (this may require a new shell to see).")
    run_command('zsh -ic "command -v nvm"')  # loads ~/.zshrc

    logger.info("NVM installed successfully!")
    logger.info("Run 'nvm install node' (after opening a new shell) to install Node.js.")


if __name__ == "__main__":
    main()
