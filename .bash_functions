# Auto-loading all functions
for f in ~/dotfiles/functions/*.sh; do
  [ -e "\$f" ] && source "\$f"
done
