# dotfiles Environment Setup

This repository provides a `dotfiles` configuration designed to automate development environment setup for Linux systems.
It manages files like `.bashrc`, `.profile`, and `.gitconfig` using symbolic links, and supports flexible, category-based configuration loading.

---

## 📌 Design Philosophy

### ✅ Category-Based Modular Loading
- `.bashrc` automatically sources all `.sh` files under `aliases/`, `exports/`, and `functions/` directories:

```bash
for f in ~/dotfiles/aliases/*.sh; do [ -r "$f" ] && . "$f"; done
for f in ~/dotfiles/exports/*.sh; do [ -r "$f" ] && . "$f"; done
for f in ~/dotfiles/functions/*.sh; do [ -r "$f" ] && . "$f"; done
```

- This makes it easy to organize and track configuration changes with Git.

### ✅ Modular `.gitconfig`
- Git configuration is split into files under `gitconfig/` by category and included in `.gitconfig` using `[include]`:

```ini
[include]
    path = ~/dotfiles/gitconfig/alias
    path = ~/dotfiles/gitconfig/core
    path = ~/dotfiles/gitconfig/init
    path = ~/dotfiles/gitconfig/user
```

- This enables reusable, maintainable, and version-controlled Git configuration.

### ✅ Clear Separation of Functions and Scripts
- `functions/` defines lightweight helper functions that are auto-loaded in interactive shells.
  - Example: `open()`
- `scripts/` contains CLI tools or heavier logic intended to be executed directly.
  - These are linked into `~/.local/bin/` and can be run from anywhere.

This structure is designed to separate logic by **weight**, **reuse scope**, and **execution method**.

---

## 🚀 Setup Instructions

### ❗ Note: Full automation is not possible
GitHub authentication (`gh auth login`) requires **manual browser-based interaction**.
Please follow the steps below in order.

---

### 🧩 Step 1: Clone dotfiles

```bash
curl -L https://github.com/YOUR_USERNAME/dotfiles/archive/refs/heads/main.tar.gz \
  | tar -xz && cd dotfiles-main
```

---

### 🧩 Step 2: Install Required Packages

```bash
bash install/setup_apt.sh
```

This installs:

- `gh` (GitHub CLI)
- `git`, `curl`, `vim`, `tree`, `xdg-utils`, and other essential tools

---

### 🧩 Step 3: GitHub Authentication (Manual)

Before uploading your SSH key, authenticate with GitHub CLI:

```bash
gh auth login --web --git-protocol ssh
```

- Follow the browser instructions to complete login.
- Then proceed to the next step.

---

### 🧩 Step 4: Generate SSH Key

```bash
bash install/setup_ssh.sh
```

- Generates `~/.ssh/id_ed25519` and adds it to `ssh-agent`
- Retrieves email from `git config user.email` or `EMAIL_FOR_SSH` environment variable

---

### 🧩 Step 5: Upload SSH Key to GitHub

```bash
bash install/setup_gh.sh
```

- If authenticated, it registers your public key with GitHub
- May prompt to authorize `admin:public_key` scope

---

### 🧩 Step 6: Install dotfiles

```bash
bash install.sh
```

- Backs up `.bashrc`, `.profile`, and `.gitconfig` if they exist
- Creates symbolic links to versions in the `dotfiles` repo
- Ensures `.bashrc` loads category-based configs:

```bash
for f in ~/dotfiles/aliases/*.sh; do [ -r "$f" ] && . "$f"; done
for f in ~/dotfiles/exports/*.sh; do [ -r "$f" ] && . "$f"; done
for f in ~/dotfiles/functions/*.sh; do [ -r "$f" ] && . "$f"; done
```

---

### ✅ Final Step

Apply the configuration with:

```bash
source ~/.bashrc
```

During installation, you'll also be asked whether to delete `.bashrc.backup`, `.profile.backup`, and `.gitconfig.backup`. If you don't need them, they can be safely removed.

---

## 🧠 Additional Notes

- `.gitconfig` uses `[include]` to load categorized configs from `dotfiles/gitconfig/`
- `.sh` scripts in `scripts/linux/` can be linked to `~/.local/bin/` via `link_scripts.sh`
- Adding a `.sh` file to `aliases/`, `exports/`, or `functions/` will auto-load it on shell startup

---

This setup is simple, maintainable, and scalable across environments. Ideal for sharing and reusing across machines or teams.

