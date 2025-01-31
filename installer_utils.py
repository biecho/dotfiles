import logging
import subprocess
import sys
import tarfile
import urllib.request
from pathlib import Path

# -------------------------------------------------------------------
# Set up a module-level logger (so logs go to stdout by default):
# -------------------------------------------------------------------
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

console_handler = logging.StreamHandler()
console_handler.setLevel(logging.INFO)

formatter = logging.Formatter("[%(levelname)s] %(message)s")
console_handler.setFormatter(formatter)

# Avoid adding multiple handlers if reimported in the same session:
if not logger.hasHandlers():
    logger.addHandler(console_handler)


# -------------------------------------------------------------------
# Reusable Utility Functions
# -------------------------------------------------------------------
# -------------------------------------------------------------------
# Reusable Utility Functions
# -------------------------------------------------------------------
def run_command(command: str, shell: bool = True, check: bool = True) -> None:
    """
    Runs the given command string using subprocess.
    By default, runs in shell mode (like 'bash -c "command"').
    Raises a CalledProcessError if 'check' is True and the command fails.
    """
    logger.info(f"Running command: {command}")
    try:
        subprocess.run(command, shell=shell, check=check)
    except subprocess.CalledProcessError as e:
        logger.error(f"Command failed with exit code {e.returncode}: {command}")
        sys.exit(e.returncode)


def download_file(url: str, destination: Path) -> None:
    """
    Downloads a file from the given URL to the specified destination using urllib.
    """
    logger.info(f"Downloading from: {url}")
    try:
        urllib.request.urlretrieve(url, destination)
    except Exception as e:
        logger.error(f"Download failed: {e}")
        sys.exit(1)


def extract_tarball(tarball_path: Path, extract_destination: Path) -> str:
    """
    Extracts the tarball into the given directory.
    Returns the name of the top-level extracted folder (e.g. 'nvim-linux64').
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
    Removes the downloaded tarball, if it exists.
    """
    if tarball_path.exists():
        try:
            logger.info(f"Removing tarball: {tarball_path}")
            tarball_path.unlink()
        except Exception as e:
            logger.warning(f"Could not remove tarball: {e}")


def ensure_dir_in_path(
        shell_rc_path: Path,
        directory: Path,
) -> None:
    """
    Ensures that 'directory' is in the PATH within 'shell_rc_path'.
    If not found, appends:
        export PATH="<directory>:$PATH"

    :param shell_rc_path: Path to the shell config file (e.g., ~/.zshrc).
    :param directory: The directory to add to the PATH (e.g., ~/.local/bin).
    """
    export_line = f'export PATH="{directory}:$PATH"'

    if not shell_rc_path.exists():
        logger.info(f"{shell_rc_path} does not exist; creating it and adding {directory} to PATH.")
        shell_rc_path.write_text(export_line + "\n", encoding="utf-8")

    content = shell_rc_path.read_text(encoding="utf-8")

    if export_line in content or str(directory) in content:
        logger.info(f"{directory} is already in PATH in {shell_rc_path}; skipping update.")
    else:
        logger.info(f"Adding {directory} to PATH in {shell_rc_path}")
        with shell_rc_path.open("a", encoding="utf-8") as f:
            f.write("\n" + export_line + "\n")
