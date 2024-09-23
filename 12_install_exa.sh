#!/bin/bash

# Check if cargo is installed
if ! command -v cargo &> /dev/null; then
  echo "Cargo is not installed. Please install Rust (which includes cargo) first."
  exit 1
fi

# Install exa using cargo
cargo install exa

if ! grep -q 'alias l=' ~/.zshrc; then
  echo 'Adding alias l to ~/.zshrc to use exa'
  echo "alias ll='exa -la'" >> ~/.zshrc

if ! grep -q 'alias ll=' ~/.zshrc; then
  echo 'Adding alias ll to ~/.zshrc to use exa'
  echo "alias ll='exa -l'" >> ~/.zshrc

# Notify the user
echo "exa has been installed! Please restart your terminal to apply the alias changes."

