#!/bin/bash

# Function to check if cargo is installed
check_cargo() {
  if ! command -v cargo &> /dev/null
  then
    echo "cargo could not be found. Please install Rust and Cargo first."
    exit 1
  fi
}

# Function to install procs locally
install_procs() {
  echo "Installing procs locally..."
  cargo install procs
}

# Main script execution
echo "Checking for cargo installation..."
check_cargo

echo "cargo found. Proceeding with procs installation..."
install_procs

echo "procs has been installed successfully."

