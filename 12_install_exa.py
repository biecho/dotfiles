import sys
from shutil import which

from installer_utils import logger, run_command, ensure_alias_in_zshrc

ALIAS_L = "alias l='exa -la'"
ALIAS_LL = "alias ll='exa -l'"


def main():
    if which("cargo") is None:
        logger.error("Cargo is not installed. Please install Rust (which includes cargo) first.")
        sys.exit(1)

    run_command("cargo install exa")

    ensure_alias_in_zshrc(ALIAS_L)
    ensure_alias_in_zshrc(ALIAS_LL)

    logger.info("exa has been installed!")
    logger.info("Aliases 'l' and 'll' have been added to your ~/.zshrc (if they were missing).")
    logger.info("Please restart your terminal or run 'source ~/.zshrc' to apply the changes.")


if __name__ == "__main__":
    main()
