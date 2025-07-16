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
  GIT_PS1_SHOWDIRTYSTATE=true     # ファイル変更の有無
  GIT_PS1_SHOWUNTRACKEDFILES=true # 新規ファイルの有無
  GIT_PS1_SHOWUPSTREAM=true       # HEADとそのアップストリームの違い
  GIT_PS1_SHOWSTASHSTATE=true     # スタッシュの有無

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
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# エイリアス設定を読み込む
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# bashの補完機能を有効化する
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
