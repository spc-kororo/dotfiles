#!/bin/bash

# TODO: 見直しする
REPO_HOME="${INSTALL_DIR:-$HOME/repos/dotfiles}"

ln -sfv "$REPO_HOME/config/bash/.bashrc" "$HOME/.bashrc"
ln -sfv "$REPO_HOME/config/bash/.bash_aliases" "$HOME/.bash_aliases"
