# 参考サイト
# https://qiita.com/magicant/items/d3bb7ea1192e63fba850

# 言語/文字コードの設定
export LANG=ja_JP.UTF8

# XDG Base Directory関連のパス設定
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export XDG_STATE_HOME=$HOME/.local/state

test -f "~/.bashrc" && . "~/.bashrc"
