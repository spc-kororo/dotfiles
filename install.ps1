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

    # 高速化
    # 参考：https://bitto.jp/powershell-startup-fast/
    Set-Alias ngen @(
        Get-ChildItem (join-path ${env:\windir} "Microsoft.NET\Framework") ngen.exe -recurse |
        Sort-Object -descending lastwritetime
    )[0].fullName
    [appdomain]::currentdomain.getassemblies() | ForEach-Object{ngen $_.location}
}
New-Item -ItemType SymbolicLink -Path $HOME/Documents/PowerShell -Target $REPO_HOME/config/PowerShell

# Git
if (!(Get-Command git | Where-object { $_.Name -match $cmd })) {
    winget install Git.Git -s winget
}
New-Item -ItemType Directory -Force -Path $HOME/.config/git
New-Item -ItemType SymbolicLink -Path $HOME/.gitconfig -Target $REPO_HOME/config/git/.gitconfig
New-Item -ItemType SymbolicLink -Path $HOME/.config/git/ignore -Target $REPO_HOME/config/git/.gitignore
New-Item -ItemType SymbolicLink -Path $HOME/.minttyrc -Target $REPO_HOME/config/git-bash-windows/.minttyrc
New-Item -ItemType SymbolicLink -Path $HOME/.config/git/git-prompt.sh -Target $REPO_HOME/config/git-bash-windows/git-prompt.sh

# WindowsTerminal
if (!(Get-Command wt | Where-object { $_.Name -match $cmd })) {
    winget install Microsoft.WindowsTerminal -s winget
}
New-Item -ItemType SymbolicLink -Path $env:LOCALAPPDATA/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json -Target $REPO_HOME/config/WindowsTerminal/settings.json

Pause
