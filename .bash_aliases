# Auto-loading all aliases
for f in ~/dotfiles/aliases/*.sh; do
  [ -e "\$f" ] && source "$f"
done
