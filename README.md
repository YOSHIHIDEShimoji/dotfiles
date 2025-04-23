# dotfiles

This repository contains configuration files and scripts to set up a consistent development environment across systems using Bash and Git.

## 🔧 What it includes

- `.bashrc`, `.profile`, `.gitconfig` with modular includes and symbolic links from `~`
- Modular shell components:
  - `aliases/`: Bash aliases grouped by function, sourced by `.bashrc`
  - `functions/`: Shell utility functions, sourced by `.bashrc`
  - `exports/`: Environment variable exports (e.g., PATH), sourced by `.bashrc`
- `gitconfig/`: Git configuration split by section (`alias`, `core`, `init`, `user`) and included from `.gitconfig` using `[include]`
- `scripts/`: Useful cross-platform scripts
  - `scripts/linux/`:
    - `check_git.sh`: Check Git repository status across directories
    - `create_series.sh`: Generate numbered file/directory series
    - `install.sh`: Install required packages or tools for Linux
    - `link_scripts.sh`: Link executable scripts to `~/.local/bin`
    - `pushit.sh`: Push all changes across multiple Git repositories
  - `scripts/windows/`:
    - `.ahk`: AutoHotkey scripts for Windows hotkeys and automation
    - `.ps1`: PowerShell scripts for Windows setup and utilities
    - `.bat`: Batch file to launch predefined automation tasks
- `install/`: Automated setup scripts
  - `setup_apt.sh`: Install essential Linux packages (apt, dnf, etc.)
  - `setup_ssh.sh`: Generate SSH key and add to `ssh-agent`
  - `setup_gh.sh`: Authenticate GitHub and upload SSH public key
  - `packages-common.txt`: List of packages used in setup

## 📦 What `install.sh` does

When run, `install.sh` performs the following:

1. **Backs up and links key dotfiles**:
   - `.bashrc`, `.profile`, `.gitconfig`
   - Symbolic links are created from `~/dotfiles` to `~`
2. **Installs essential packages** using your system's package manager
3. **Generates an SSH key** (`id_ed25519`) if one does not exist
4. **Authenticates with GitHub** (via CLI) and uploads your public SSH key

To get started:

```bash
cd ~/dotfiles
./install.sh
```

Or run everything in one command:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/install.sh)
```

(Replace `YOUR_USERNAME` with your GitHub username)

After installation, make sure to reload your shell:

```bash
source ~/.bashrc
```

## 📁 Directory structure

```
.
├── aliases/               # Bash alias files (sourced by .bashrc)
├── exports/               # PATH and environment exports (sourced by .bashrc)
├── functions/             # Shell utility functions (sourced by .bashrc)
├── gitconfig/             # Git modular config (included from .gitconfig)
├── install/               # Setup scripts (apt, SSH, GitHub)
├── install.sh             # Main setup script (creates symlinks, runs setup)
├── scripts/               # Platform-specific tools (Linux & Windows)
└── README.md
```

## 🗒 Notes

- This repository assumes you are using a Bash-compatible shell
- `.bashrc` automatically sources scripts from `aliases/`, `functions/`, and `exports/`
- `.gitconfig` includes settings from modular files under `gitconfig/`
- Symbolic links from dotfiles are created to `~` for consistent usage
- SSH key upload via GitHub CLI requires authentication
- Windows automation relies on [AutoHotkey](https://www.autohotkey.com/) for `.ahk` scripts

Feel free to fork and adapt for your own workflow.
