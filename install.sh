#!/usr/bin/env bash
set -x

# TODO: 見直しする
REPO_HOME="${INSTALL_DIR:-$HOME/repos/dotfiles}"
. "$REPO_HOME/config/.bash_profile"

# bash
ln -sfv "$REPO_HOME/config/bash/.bash_profile" "$HOME/.bash_profile"
ln -sfv "$REPO_HOME/config/bash/.bashrc" "$HOME/.bashrc"
ln -sfv "$REPO_HOME/config/bash/.bash_aliases" "$HOME/.bash_aliases"

# XDG
mkdir -p \
    "$XDG_CONFIG_HOME" \
    "$XDG_CACHE_HOME" \
    "$XDG_DATA_HOME" \
    "$XDG_STATE_HOME"
excludeList=(
    "bash"
    "clink"
    "mintty"
    "PowerShell"
    "WindowsTerminal"
)
excludePattern="$(IFS="|"; echo "${excludeList[*]}")"
find "$REPO_HOME/config" -maxdepth 1 -mindepth 1 |
    grep -E -v "^$REPO_HOME/config/($excludePattern)" |

# Shell関連
## shellcheck
sudo apt install shellcheck

## shfmt
sudo apt install shfmt

# starship
curl -sS https://starship.rs/install.sh | sh

# fzf
sudo apt install fzf

# zoxide
sudo apt install zoxide

# bat
sudo apt install bat
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat

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
