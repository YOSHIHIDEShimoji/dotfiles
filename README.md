# dotfiles

> Personal dotfiles for managing bash and git configuration across multiple environments.

---

## ✨ Usage

1. **Clone this repository:**

    ```bash
    git clone git@github.com:YOSHIHIDEShimoji/dotfiles.git
    ```

2. **Move into the directory:**

    ```bash
    cd dotfiles
    ```

3. **Run the installer:**

    ```bash
    bash install.sh
    ```

4. **Apply the changes:**

    ```bash
    source ~/.bashrc
    ```

---

## 💡 Requirements

- Bash shell
- Git installed
- Linux / WSL environment (tested)

---

## 📂 Managed Files

- `.bashrc`
- `.bash_aliases`
- `.bash_exports`
- `.bash_functions`
- `.gitconfig`
- `.profile`

---

## ⚠️ Notes

- `.ssh/` and private keys are **NOT** managed by this repository.
- You **must** run `source ~/.bashrc` after installation to apply the new settings.

---

## 🚀 Future Plans

- Manage additional configurations under `.config/` (e.g., `nvim`, `starship`, `bat`)
- Add dry-run and verbose modes to `install.sh`
- MacOS compatibility support (optional)

---

*Made with care to streamline setup across machines.*

