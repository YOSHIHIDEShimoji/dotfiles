# dotfiles

> Personal dotfiles for managing bash and git configuration across multiple environments, with modular install scripts.

---

## ✨ Usage

1. **Clone this repository:**

    ```bash
    git clone git@github.com:YOSHIHIDEShimoji/dotfiles.git dotfiles_clone
    ```

2. **Move into the directory:**

    ```bash
    cd dotfiles_clone
    ```

3. **Run the installer:**

    ```bash
    bash install/install_main.sh
    ```

4. **Apply the changes:**

    ```bash
    source ~/.bashrc
    ```

---

## 💡 Requirements

- Bash shell
- Git installed
- Linux or WSL environment (tested)

---

## 📂 Directory Structure

```plaintext
dotfiles/
├── aliases/         # Bash aliases
├── exports/         # Environment variables
├── functions/       # Bash functions
├── gitconfig/       # Git configuration fragments
├── install/         # Modular install scripts
├── install_main.sh  # Main installer
└── README.md        # This file
```

---

## 📜 Managed Files

During installation, the following files will be created or updated:

- `.bashrc`（you need to manually source it）
- `.bash_aliases`
- `.bash_exports`
- `.bash_functions`
- `.gitconfig`
- `.profile`（※manual management, not auto-installed）

Each file is modularly constructed by sourcing scripts from the corresponding subdirectories.

---

## ⚠️ Notes

- `.ssh/` and private keys are **NOT** managed by this repository.
- Always run `source ~/.bashrc` after installation to apply changes.
- Existing config files will be compared and **only updated if different**.
- If differences are found, you can review and approve overwriting.

---

## 🚀 Future Plans

- Manage additional configurations under `.config/` (e.g., `nvim`, `starship`, `bat`)
- Add dry-run and verbose modes to install scripts
- Support for MacOS setup (optional)

---

*Made with care to streamline and modularize environment setup across multiple machines.*

