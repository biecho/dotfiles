#!/usr/bin/env python3

"""
xsv Local Installation Script (Python version):

1. Ensures cargo is installed.
2. Creates ~/.local/bin if it doesn't exist.
3. Installs xsv into ~/.local/bin (via cargo install --root ~/.local xsv).
4. Verifies that xsv is installed correctly.
5. If ~/.local/bin is not in PATH, appends export to ~/.zshrc.
6. Logs progress and instructions.
"""

import os
import sys
from pathlib import Path
from shutil import which

from installer_utils import logger, LOCAL_BIN, run_command, ZSHRC_PATH


def main():
    if which("cargo") is None:
        logger.error("Cargo is not installed. Please install Rust (which includes cargo) first.")
        sys.exit(1)

    if not LOCAL_BIN.exists():
        logger.info(f"Creating local bin directory at {LOCAL_BIN}")
        LOCAL_BIN.mkdir(parents=True, exist_ok=True)

    logger.info("Installing xsv using cargo...")
    run_command(f'cargo install --root "{Path.home() / ".local"}" xsv')

    xsv_path = LOCAL_BIN / "xsv"
    if xsv_path.is_file():
        logger.info(f"xsv successfully installed to {xsv_path}.")
    else:
        logger.error("Installation failed. Please check the output for any errors.")
        sys.exit(1)

    # Check if ~/.local/bin is in PATH
    #    - For the current process, we check os.environ["PATH"], or just check sys.path-like approach:
    #    - But to persist for future sessions, we add to ~/.zshrc if missing.
    path_env = os.environ.get("PATH", "")
    if str(LOCAL_BIN) not in path_env.split(":"):
        logger.info(f"Adding {LOCAL_BIN} to PATH in {ZSHRC_PATH}...")
        line_to_add = f'export PATH="{LOCAL_BIN}:$PATH"'

        if not ZSHRC_PATH.exists():
            logger.info(f"{ZSHRC_PATH} does not exist; creating it and adding PATH.")
            ZSHRC_PATH.write_text(line_to_add + "\n", encoding="utf-8")
        else:
            zshrc_content = ZSHRC_PATH.read_text(encoding="utf-8")
            if line_to_add not in zshrc_content and str(LOCAL_BIN) not in zshrc_content:
                logger.info(f"Appending '{line_to_add}' to {ZSHRC_PATH}")
                with ZSHRC_PATH.open("a", encoding="utf-8") as f:
                    f.write("\n" + line_to_add + "\n")
            else:
                logger.info(f"{LOCAL_BIN} is already in the PATH in {ZSHRC_PATH}; skipping update.")

        # Update PATH for current session too
        os.environ["PATH"] = f"{LOCAL_BIN}:{path_env}"

    logger.info("xsv installation complete! If needed, please restart your terminal or 'source ~/.zshrc'.")


if __name__ == "__main__":
    main()
