# dotfiles Setup for Development Environments

> 🇯🇵 [日本語はこちら](./README.ja.md)

This repository is a structured and automated `dotfiles` setup for Linux and WSL-based development environments. It manages `.bashrc`, `.profile`, `.gitconfig`, etc., using symbolic links and modular configuration loading.

---

## 📌 Design Philosophy

### ✅ Modular loading via categorized directories
- `.bashrc` automatically loads all `.sh` files in the following directories:

```bash
for f in ~/dotfiles/aliases/*.sh; do [ -r "$f" ] && . "$f"; done
for f in ~/dotfiles/exports/*.sh; do [ -r "$f" ] && . "$f"; done
for f in ~/dotfiles/functions/*.sh; do [ -r "$f" ] && . "$f"; done
```

- This allows configuration to be split by purpose, making it easier to maintain and track with Git.
- Files like `.bash_aliases`, `.bash_exports`, or `.bash_functions` are no longer necessary.

### ✅ Git configuration modularization
- Git settings are broken into modules under `gitconfig/`, and `.gitconfig` includes them via:

```ini
[include]
    path = ~/dotfiles/gitconfig/alias
    path = ~/dotfiles/gitconfig/core
    path = ~/dotfiles/gitconfig/init
    path = ~/dotfiles/gitconfig/user
```

- Each category of configuration is maintainable and version-controllable.

### ✅ Clear separation between shell functions and CLI tools
- Place lightweight shell functions in `functions/` to be auto-loaded on shell startup.
  - e.g., `open()` for WSL path conversion
- Put heavier CLI scripts into `scripts/` and link them to `.local/bin/` for global use

This design allows clear separation depending on **weight, purpose, and execution method**.

---

## 🚀 Installation

### What `install.sh` does

- Backs up any existing `.bashrc`, `.profile`, or `.gitconfig` in your `$HOME` directory (as `.backup`)
- Creates symbolic links from `dotfiles/` to your home directory
- Executes `install/setup_*.sh` scripts for further setup

Run this single-line command to set up everything:

```bash
curl -L https://github.com/YOSHIHIDEShimoji/dotfiles/archive/refs/heads/merge-setup.tar.gz \
  | tar -xz && cd dotfiles-merge-setup && bash install.sh

```

This performs:
- Symbolic linking of core config files
- Installation of required CLI tools (`apt`, `dnf`, `pacman`, etc.)
- SSH key creation and GitHub CLI authentication with automatic key upload

---

## 🛠 About the `scripts/` Directory

All utility scripts for Linux and Windows are organized under `scripts/`. Please refer to comments and script names directly:

- `scripts/linux/`: for CLI tools (e.g., symlink creation, bulk file generation)
- `scripts/windows/`: AutoHotkey, PowerShell, or batch scripts for Windows environments

> See `scripts/README.md` for script-specific usage.

---

## 🔧 How to Add New Settings

This repository has a clearly defined structure. You can expand it by adding files to the appropriate directory:

```
.
├── aliases/         # shell aliases (e.g., ll='ls -la')
├── exports/         # environment variables (e.g., export PATH)
├── functions/       # shell functions auto-loaded by .bashrc
├── gitconfig/       # modular git config (alias, core, user, etc.)
└── scripts/
    ├── linux/       # CLI utilities (linked to ~/.local/bin/)
    └── windows/     # Windows-only scripts (AHK, PowerShell, etc.)
```

- To add a new **alias** → add `.sh` to `aliases/`
- To define a new **function** → add `.sh` to `functions/`
- To create an executable **CLI tool** → put a `.sh` in `scripts/linux/` and run `link_scripts.sh`

The clear role of each directory helps you easily expand your setup.

---

## 🧠 Additional Notes

- Run `source ~/.bashrc` after installation to apply changes
- All scripts are written in Bash and use `set -e` for safety
- If `xdg-open` fails during GitHub CLI authentication, WSL will fall back to using `explorer.exe` to launch the browser

---

This structure is simple, maintainable, and scalable — a solid foundation for automating your environment setup.

