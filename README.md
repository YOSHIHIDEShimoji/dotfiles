# 🚀 dotfiles Setup Guide

---

## 💡 Philosophy

- Quickly restore a Linux/WSL development environment
- Manage only the minimum necessary config files (.bashrc, .profile, .gitconfig) with symbolic links
- Automatically apply environment settings on bash startup
- Automate everything that can be automated
- GitHub authentication (login) must be performed manually
- `.gitconfig` only contains [include] directives and is modularly managed under `dotfiles/gitconfig/`
- `aliases/`, `exports/`, and `functions/` directories are modularly organized and automatically sourced on bash startup

---

## 📂 Directory Structure

```plaintext
dotfiles/
├── install/           # Setup scripts (e.g., setup_apt.sh)
├── scripts/linux/     # Linux scripts (create_series.sh, link_scripts.sh, pushit.sh)
├── aliases/           # Bash alias management
├── exports/           # Environment variable management
├── functions/         # Bash function management
├── gitconfig/         # Git configuration modules
├── .bashrc, .profile, .gitconfig
└── README.md          # This guide
```

---

## 🛠️ Setup Instructions

### 1. Install GitHub CLI and Authenticate

```bash
sudo apt update && sudo apt install gh && gh auth login --web --git-protocol ssh
```

- Install GitHub CLI (gh)
- Complete authentication using your web browser

---

### 2. Clone the Repository

```bash
git clone --branch merge-setup git@github.com:YOSHIHIDEShimoji/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

---

### 3. Run install.sh

```bash
bash install.sh
```

---

### 4. Reload bash Configuration

```bash
source ~/.bashrc
```

---

### 5. 📌 Link Scripts to ~/.local/bin

```bash
bash ~/dotfiles/scripts/linux/link_scripts.sh
```

*Assumes `~/.local/bin` is already included in your PATH.*

---

## 📜 What install.sh Does

- Executes `install/setup_apt.sh` to install required packages (git, curl, gh, etc.)
- Creates symbolic links for `.bashrc`, `.profile`, and `.gitconfig` in your home directory
- Backs up existing files as `.backup` if necessary

---

## 📖 Operational Policy

- Do not place unnecessary files outside of the dotfiles directory
- Always reflect changes back into the dotfiles repository
- Manage backup files (*.backup) manually (they are not auto-deleted)
- Manage `.gitconfig` modularly through include
- Automatically load scripts placed under `aliases/`, `exports/`, and `functions/`
- GitHub authentication (`gh auth login`) must be done manually

---

## 🛠️ .bashrc Loading Mechanism

The following code is written in `.bashrc` to automatically load scripts from respective directories:

```bash
# Aliases definitions.
for f in ~/dotfiles/aliases/*.sh; do
  [ -r "$f" ] && . "$f"
done

# Function definitions.
for f in ~/dotfiles/functions/*.sh; do
  [ -r "$f" ] && . "$f"
done

# Exports definitions.
for f in ~/dotfiles/exports/*.sh; do
  [ -r "$f" ] && . "$f"
done
```

Just by adding a file, it will be automatically loaded at bash startup.

---

## ⚠️ Notes

- You can return to the original environment by running reset.sh.

---

*Designed to streamline, modularize, and simplify environment setup across machines ✨*