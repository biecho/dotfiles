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
ansible-playbook ansible/playbook.yml -e dotfiles_target=my-ssh-alias
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
ansible-playbook -i inventory.yml ansible/playbook.yml -e dotfiles_target=my-host
```

With package installation:

```sh
ansible-playbook -i inventory.yml ansible/playbook.yml -e dotfiles_target=my-host \
  -e dotfiles_install_packages=true --ask-become-pass
```

### Remote Git Checkout

The default remote mode copies the controller checkout. For trusted machines
that should own their checkout and run future `git pull` commands themselves,
use the Git strategy:

```sh
ansible-playbook ansible/playbook.yml \
  -e dotfiles_target=my-ssh-alias \
  -e dotfiles_repo_strategy=git \
  -e dotfiles_repo_url=https://github.com/biecho/dotfiles.git \
  -e dotfiles_repo_auth=remote_gh \
  -e dotfiles_install_packages=true
```

`dotfiles_repo_auth=remote_gh` reads `gh auth token` on the controller, uses it
for the HTTPS clone/update, then logs the remote `gh` CLI in and runs
`gh auth setup-git`. After that, the remote can update itself:

```sh
cd ~/.dotfiles
git pull
ansible-playbook ansible/playbook.yml
```

Only use `remote_gh` on machines you trust, because it stores GitHub
credentials on the target. For one-off machines, keep the default copy mode.

## Useful Variables

- `dotfiles_sync_to_remote`: copy the controller checkout to the target first.
  Defaults to true for SSH targets and false for local runs.
- `dotfiles_repo_strategy`: prepare the checkout with `local`, `copy`, or `git`.
  Defaults to `copy` for SSH targets and `local` for local runs.
- `dotfiles_repo_url`: HTTPS repository URL for `dotfiles_repo_strategy=git`.
- `dotfiles_repo_version`: Git branch, tag, or commit to check out, default
  `main`.
- `dotfiles_repo_auth`: repository auth mode, `none`, `local_gh_token`, or
  `remote_gh`. `remote_gh` persists GitHub CLI auth on the target.
- `dotfiles_target`: inventory group or host pattern to provision, default
  `local`.
- `dotfiles_remote_dir`: remote checkout path, default `~/.dotfiles`.
- `dotfiles_install_github_cli`: install GitHub CLI when using `remote_gh`,
  default true for that auth mode.
- `dotfiles_install_packages`: install platform packages, default false.
- `dotfiles_install_vscode`: link VSCode settings and keybindings, default false.
- `dotfiles_install_vscode_extensions`: install VSCode extensions, default false.
- `dotfiles_install_nvim_deps`: install Neovim Python/plugin dependencies,
  default false.
- `dotfiles_install_termusic`: install Termusic config, default false.
- `dotfiles_install_claude`: install fnm, Node.js LTS, and Claude Code, default false.
