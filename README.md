# 🚀 dotfiles Setup Guide

[🇯🇵 日本語版はこちら](./README.ja.md)

---

## 💡 Philosophy

- Quickly reproduce a Linux/WSL development environment
- Manage only the minimum necessary configuration files (.bashrc, .profile, .gitconfig) via symbolic links
- Automatically apply environment settings on bash startup
- Automate everything that can be automated
- GitHub authentication (login) must be done manually
- `.gitconfig` only contains [include] directives; configurations are managed under `dotfiles/gitconfig/`
- `aliases/`, `exports/`, and `functions/` are modularly organized and automatically sourced at bash startup

---

## 📂 Directory Structure

```plaintext
dotfiles/
├── install/           # Setup scripts (e.g., setup_apt.sh)
├── scripts/linux/     # Linux scripts (create_series.sh, link_scripts.sh, pushit.sh)
├── aliases/           # Bash aliases management
├── exports/           # Environment variables management
├── functions/         # Bash functions management
├── gitconfig/         # Git configuration modules
├── .bashrc, .profile, .gitconfig
├── README.ja.md       # Japanese version
└── README.md          # This guide

```

---

## 🛠️ Setup Instructions

### 1. Install GitHub CLI and Authenticate

```bash
sudo apt update && sudo apt install gh && gh auth login --web --git-protocol ssh
```

- Install GitHub CLI (gh)
- Complete GitHub authentication using your web browser

---

### 2. Clone the repository

```bash
git clone --branch merge-setup git@github.com:YOSHIHIDEShimoji/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

---

### 3. Run install.sh

```bash
bash install.sh
```

- At the beginning, your current Git user.name and user.email will be displayed
- If they are incorrect, you will be prompted to input your correct information, and `dotfiles/gitconfig/user` will be automatically updated

---

### 4. Reload bash settings

```bash
source ~/.bashrc
```

---

## 📜 What install.sh does

- Runs `install/setup_apt.sh` to install necessary packages such as git, curl, and gh
- Checks your Git user information and updates `dotfiles/gitconfig/user` if needed
- Creates symbolic links for `.bashrc`, `.profile`, and `.gitconfig` in the home directory
- Backs up existing files by renaming them to `.backup` if they exist

---

## 📖 Operational Policy

- Do not place unnecessary files outside of the dotfiles repository
- Always reflect any changes back into the dotfiles repository
- Manage backup files (*.backup) manually
- Manage `.gitconfig` modularly using [include] directives
- Simply adding scripts to `aliases/`, `exports/`, or `functions/` directories will automatically apply them at bash startup
- GitHub authentication (`gh auth login`) must be manually executed

---

## 🛠️ .bashrc Loading Mechanism

The following code is written in `.bashrc` to automatically load scripts:

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

This allows you to simply add new files and have them automatically sourced at bash startup.

---

## ⚠️ Notes

- Use `reset.sh` only when needed.

---

*Designed to streamline, modularize, and simplify environment setup across machines ✨*

