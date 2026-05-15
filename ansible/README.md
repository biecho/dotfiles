# Dotfiles Ansible Provisioning

This is the Ansible entry point for provisioning this dotfiles repo on the
current machine or on an SSH-accessible host.

The playbook is intentionally conservative by default: it creates symlinks and
backs up existing non-symlink files, but package installation and heavier app
setup are opt-in.

## Local Install

```sh
ansible-playbook ansible/playbook.yml
```

Install packages as well:

```sh
ansible-playbook ansible/playbook.yml -e dotfiles_install_packages=true
```

Enable optional setup:

```sh
ansible-playbook ansible/playbook.yml \
  -e dotfiles_install_packages=true \
  -e dotfiles_install_nvim_deps=true \
  -e dotfiles_install_vscode=true \
  -e dotfiles_install_vscode_extensions=true \
  -e dotfiles_install_termusic=true
```

## Remote Install

Add a host under `workstations` in `ansible/inventory/hosts.yml`, or pass a
separate inventory file. For SSH targets, the role copies this checkout to
`~/.dotfiles` on the target and symlinks from there.

Ansible also includes `ansible/inventory/ssh_config.py`, a dynamic inventory
that reads concrete `Host` aliases from your local `~/.ssh/config`. OpenSSH
still handles `HostName`, `User`, `Port`, `IdentityFile`, `ProxyJump`, and the
rest of your SSH settings.

List SSH config aliases visible to Ansible:

```sh
ansible-inventory -i ansible/inventory/ssh_config.py --list
```

Run against an SSH config alias:

```sh
ansible-playbook -i ansible/inventory/ssh_config.py ansible/playbook.yml -l my-ssh-alias
```

Example one-off inventory:

```yaml
all:
  hosts:
    my-host:
      ansible_host: 192.0.2.10
      ansible_user: dmeyer
```

Run against that host:

```sh
ansible-playbook -i inventory.yml ansible/playbook.yml -l my-host
```

With package installation:

```sh
ansible-playbook -i inventory.yml ansible/playbook.yml -l my-host \
  -e dotfiles_install_packages=true --ask-become-pass
```

## Useful Variables

- `dotfiles_sync_to_remote`: copy the controller checkout to the target first.
  Defaults to true for SSH targets and false for local runs.
- `dotfiles_remote_dir`: remote checkout path, default `~/.dotfiles`.
- `dotfiles_install_packages`: install platform packages, default false.
- `dotfiles_install_vscode`: link VSCode settings and keybindings, default false.
- `dotfiles_install_vscode_extensions`: install VSCode extensions, default false.
- `dotfiles_install_nvim_deps`: install Neovim Python/plugin dependencies,
  default false.
- `dotfiles_install_termusic`: install Termusic config, default false.
- `dotfiles_install_claude`: run the existing Claude Code installer, default false.
