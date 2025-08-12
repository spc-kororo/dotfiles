# 対話的に実行されていない場合は何もしない
case $- in
*i*) ;;
*) return ;;
esac

# 重複行やスペースで始まる行を履歴に残さない
HISTCONTROL=ignoreboth

# コマンド実行前に、追記モードで履歴を記録する
shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

# 保存する履歴の件数を設定する
HISTSIZE=1000     # メモリ
HISTFILESIZE=2000 # 履歴ファイル

# 履歴に日時を追加する
HISTTIMEFORMAT="%Y/%m/%d %H:%M:%S "

# コマンド実行時、ウィンドウサイズを確認して必要に応じて$LINESと$COLUMNSの値を更新する
shopt -s checkwinsize

# lessの入力プリプロセッサを有効化する
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# プロンプト表示をカスタマイズする
if type starship >/dev/null 2>&1; then
  # starshipを有効化する
  eval "$(starship init bash)"
else
  # starshipがインストールされていない環境（.devcontainer等）を考慮したカスタマイズ設定を行う

  # 作業中の chroot を識別する変数を設定する
  if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
  fi

  # 色付きプロンプト機能を有効化する
  case "$TERM" in
  xterm-color | *-256color)
    color_prompt=yes
    ;;
  esac
  case $(uname -a) in
  MINGW*)
    force_color_prompt=yes
    ;;
  esac
  if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
      color_prompt=yes
    else
      color_prompt=
    fi
  fi

  # Gitのプロンプト表示機能を有効化する
  export GIT_PS1_SHOWDIRTYSTATE=true     # ファイル変更の有無
  export GIT_PS1_SHOWUNTRACKEDFILES=true # 新規ファイルの有無
  export GIT_PS1_SHOWUPSTREAM=true       # HEADとそのアップストリームの違い
  export GIT_PS1_SHOWSTASHSTATE=true     # スタッシュの有無

  # プロンプト表示のカスタマイズ
  if [ "$color_prompt" = yes ]; then
    # NOTE: https://qiita.com/hmmrjn/items/60d2a64c9e5bf7c0fe60
    PS1='\n\[\e[33m\]\D{%F %T}\[\e[0m\] \[\e[01;35m\]\w\[\e[0m\]\[\e[01;32m\]`__git_ps1`\[\e[0m\]\n\$ '
  else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
  fi
  unset color_prompt force_color_prompt
fi

# lsのカラーサポートを有効にし、便利なエイリアスも追加する
if [ -x /usr/bin/dircolors ]; then
  (test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)") || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# エイリアス設定を読み込む
if [ -f "$HOME/.bash_aliases" ]; then
  . "$HOME/.bash_aliases"
fi

# bashの補完機能を有効化する
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    # shellcheck disable=SC1091
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    # shellcheck disable=SC1091
    . /etc/bash_completion
  fi
fi

# fzfを有効化する
if type fzf >/dev/null 2>&1; then
  # fzfの表示・動作をカスタマイズ
  FZF_THEME_DRACULA="--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4"
  FZF_PREVIEW_TREE_COMMAND="tree -CN {} | head -200"
  FZF_PREVIEW_BAT_COMMAND="bat --plain --color=always --line-range=:200"
  case $(uname -a) in
  MINGW*)
    # NOTE: Git Bashで利用するtreeコマンドはSJIS出力するため、文字化け回避のため文字コード変換を行う
    FZF_PREVIEW_TREE_COMMAND=$(echo "$FZF_PREVIEW_TREE_COMMAND" | sed 's/head/iconv -f SJIS -t UTF-8 | head/g')
    ;;
  esac

  export FZF_DEFAULT_OPTS="--height=90% --reverse $FZF_THEME_DRACULA"
  export FZF_CTRL_R_OPTS="--preview-window=down,40%,wrap --preview='((type bat > /dev/null) && echo {} | $FZF_PREVIEW_BAT_COMMAND --language=sh) || echo {}'"
  export FZF_CTRL_T_OPTS="--preview-window=down,40%,wrap --preview='((type bat > /dev/null) && $FZF_PREVIEW_BAT_COMMAND {}) || head -200 {}'"
  export FZF_ALT_C_OPTS="--preview-window=right --preview='$FZF_PREVIEW_TREE_COMMAND'"

  _fzf_comprun() {
    local command=$1
    shift

    case "$command" in
    cd) fzf --preview="$FZF_PREVIEW_TREE_COMMAND" "$@" ;;
    export | unset) fzf --preview="eval 'echo \$'{}" "$@" ;;
    # ssh) fzf --preview='dig {}' "$@" ;;
    *) fzf --preview="((type bat > /dev/null) && $FZF_PREVIEW_BAT_COMMAND {}) || head -200" "$@" ;;
    esac
  }

  # fzfのシェル統合を有効化
  case $(uname -a) in
  Linux*)
    # NOTE: FZFのバージョンによって有効化方法が異なるため、バージョンをチェックして分岐する
    # 参考：https://qiita.com/akegashi/items/35bde2af80682ca77a70
    fzf_version=$(fzf --version | awk -F. '{printf "%2d%02d%02d", $1,$2,$3}')
    if [ 04800 -le "$fzf_version" ]; then
      eval "$(fzf --bash)"
    else
      if [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
        # shellcheck disable=SC1091
        . /usr/share/doc/fzf/examples/key-bindings.bash
      fi
      if [ -f /usr/share/bash-completion/completions/fzf ]; then
        # shellcheck disable=SC1091
        . /usr/share/bash-completion/completions/fzf
      fi
    fi
    unset fzf_version
    ;;
  MINGW*)
    # NOTE: Git Bashの場合に「stdout is not a tty」と表示されてしまうため、抑止するためにコマンドを分ける
    # 参考: https://qiita.com/kimisyo/items/e6b9c453d5bb002f1486
    fzf() { fzf.exe "$@"; }
    eval "$(fzf --bash)"
    ;;
  esac

  # fzf-tab-completionを有効化
  fzf_tab_comp_shell="$MY_BIN_PATH/fzf-bash-completion_bash.sh"
  if [ -f "$fzf_tab_comp_shell" ]; then
    # shellcheck disable=SC1090
    . "$fzf_tab_comp_shell"
    bind -x '"\t": fzf_bash_completion'
  fi
  unset fzf_tab_comp_shell
fi

# zoxideを有効化する
if type zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi

# batのオプションを有効化する
if type bat >/dev/null 2>&1; then
  export BAT_THEME=Dracula
fi
