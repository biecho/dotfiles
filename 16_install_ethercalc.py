#!/usr/bin/env python3

"""
EtherCalc Installation Script (Python version)

1. Checks if node and npm are installed.
2. Installs EtherCalc globally with 'npm install -g ethercalc'.
3. Verifies that 'ethercalc' is in PATH.
4. Logs next steps for running EtherCalc and SSH tunneling.
"""

import sys
from shutil import which

from installer_utils import logger, run_command


def main():
    # 1) Check if node and npm are installed
    if which("node") is None:
        logger.error("Node.js is not installed or not in your PATH. Please install Node.js first.")
        sys.exit(1)

    if which("npm") is None:
        logger.error("npm is not installed or not in your PATH. Please install Node.js (which includes npm) first.")
        sys.exit(1)

    # 2) Install EtherCalc globally
    logger.info("Installing EtherCalc globally with npm...")
    run_command("npm install -g ethercalc")

    # 3) Verify installation
    ethercalc_path = which("ethercalc")
    if not ethercalc_path:
        logger.error("EtherCalc command ('ethercalc') not found in PATH after installation.")
        logger.error("Please check your npm global bin path or re-open your shell.")
        sys.exit(1)
    else:
        logger.info(f"EtherCalc is installed at: {ethercalc_path}")

    # 4) Instructions
    logger.info("EtherCalc installation complete!")
    logger.info("To run EtherCalc on port 8000, you can do:")
    logger.info("    ethercalc --port 8000")
    logger.info("")
    logger.info("Then, on your local machine, use SSH tunneling to access it:")
    logger.info("    ssh -L 8000:localhost:8000 <user>@<server>")
    logger.info("Afterward, open http://localhost:8000 in your browser to use EtherCalc.")

if __name__ == "__main__":
    main()
