#!/bin/bash

# TODO: 見直しする
REPO_HOME="${INSTALL_DIR:-$HOME/repos/dotfiles}"

# bash
ln -sfv "$REPO_HOME/config/bash/.bashrc" "$HOME/.bashrc"
ln -sfv "$REPO_HOME/config/bash/.bash_aliases" "$HOME/.bash_aliases"

# Git
ln -sfv "$REPO_HOME/config/git/.gitconfig" "$HOME/.gitconfig"
mkdir -p "$HOME/.config/git"
ln -sfv "$REPO_HOME/config/git/.gitignore" "$HOME/.config/git/ignore"

# Font
# 参考：https://qiita.com/query1000/items/6ea7665529b022eb5f45
FONT_CONF_PATH=/etc/fonts/local.conf
if [ ! -f $FONT_CONF_PATH ]; then
    cat > $FONT_CONF_PATH <<EOS
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <dir>/mnt/c/Windows/Fonts</dir>
</fontconfig>
EOS
fi
fc-cache -fv
