#!/usr/bin/env python3

"""
Rust Local Installation Script (Python Version)

1. Installs Rust locally using the rustup script.
2. Adds ~/.cargo/bin to PATH in ~/.zshrc (if not already present).
3. Sources the ~/.cargo/env in the current shell (subprocess) to verify installation.
4. Prints final instructions for the user to restart or source their shell.
"""

from pathlib import Path

from installer_utils import logger, run_command

RUST_INSTALL_URL = "https://sh.rustup.rs"
ZSHRC = Path.home() / ".zshrc"
CARGO_ENV = Path.home() / ".cargo" / "env"


def update_zshrc_for_rust():
    """
    Appends the Rust cargo/bin PATH export to ~/.zshrc if it's not already present.
    """
    cargo_bin_str = 'export PATH="$HOME/.cargo/bin:$PATH"'

    # If the zshrc file doesn't exist, we'll create it
    if not ZSHRC.exists():
        logger.info(f"{ZSHRC} does not exist; creating it to add cargo/bin.")
        ZSHRC.write_text(cargo_bin_str + "\n", encoding="utf-8")
        return

    content = ZSHRC.read_text(encoding="utf-8")
    if ".cargo/bin" not in content:
        logger.info("Adding Rust cargo/bin to PATH in ~/.zshrc")
        with ZSHRC.open("a", encoding="utf-8") as f:
            f.write("\n" + cargo_bin_str + "\n")
    else:
        logger.info("Rust cargo/bin is already in the PATH in ~/.zshrc; skipping update.")


def main():
    # 1) Install Rust using rustup (non-interactive, `-y`)
    logger.info("Installing Rust locally using rustup...")
    install_cmd = f'curl --proto "=https" --tlsv1.2 -sSf {RUST_INSTALL_URL} | sh -s -- -y'
    run_command(install_cmd)

    # 2) Append cargo/bin to PATH in ~/.zshrc
    update_zshrc_for_rust()

    # 3) Source Rust environment in a subshell to verify installation
    # If the user is in zsh, they'd typically do: `source ~/.zshrc` or `source ~/.cargo/env`
    # We'll replicate that in a subprocess to check that rustc and cargo exist.
    if not CARGO_ENV.exists():
        logger.warning(f"{CARGO_ENV} not found; cannot source cargo environment for verification.")
    else:
        logger.info("Sourcing Rust environment and verifying installation...")
        verify_cmd = f'. {CARGO_ENV} && command -v rustc && rustc --version && command -v cargo && cargo --version'
        run_command(verify_cmd)

    logger.info("Rust installation complete!")
    logger.info("Please restart your terminal or run 'source ~/.zshrc' to update your environment.")
    logger.info("Then you can run 'rustc --version' and 'cargo --version' to verify.")


if __name__ == "__main__":
    main()
