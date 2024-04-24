# 管理者権限へ昇格
# 参考：https://qiita.com/sakekasunuts/items/63a4023887348722b416#ps1実行時に自動的に昇格させたい
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$REPO_HOME = $PSScriptRoot

# PowerShell
if (!(Get-Command oh-my-posh | Where-object { $_.Name -match $cmd })) {
    winget install JanDeDobbeleer.OhMyPosh -s winget
}
New-Item -ItemType SymbolicLink -Path $HOME/Documents/PowerShell -Target $REPO_HOME/config/PowerShell

# Git-bash
New-Item -ItemType SymbolicLink -Path $HOME/.minttyrc -Target $REPO_HOME/config/git-bash-windows/.minttyrc
New-Item -ItemType Directory -Force -Path $HOME/.config/git
New-Item -ItemType SymbolicLink -Path $HOME/.config/git/git-prompt.sh -Target $REPO_HOME/config/git-bash-windows/git-prompt.sh

Pause
