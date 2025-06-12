# 管理者権限へ昇格
# 参考：https://qiita.com/sakekasunuts/items/63a4023887348722b416#ps1実行時に自動的に昇格させたい
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
    if (!(Get-Command pwsh | Where-object { $_.Name -match $cmd })) {
        winget install Microsoft.PowerShell -s winget
    }

    Start-Process pwsh.exe "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$REPO_HOME = $PSScriptRoot

# 作業ディレクトリの作成
$tempDir = $env:TEMP | Join-Path -ChildPath "dotfiles"
if (Test-Path $tempDir) {
    Remove-Item -Path $tempDir\* -Force
}
else {
    mkdir $tempDir
}

# Font
## Nerd Fontのダウンロード
downloadFile("https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Inconsolata.zip", $tempDir)

## プログラミングフォントのダウンロード
downloadFile("https://github.com/tomokuni/Myrica/raw/master/product/Myrica.zip", $tempDir)

## インストール
$fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
Get-ChildItem -Path $tempDir\* -Include *.zip | ForEach-Object {
    $destDir = $_.FullName.Substring(0, $_.FullName.LastIndexOf('.'))
    Expand-Archive -Path $_.FullName -DestinationPath $destDir
    Get-ChildItem -Path $destDir\* -Include *.tt? | ForEach-Object {
        $fonts.CopyHere($_.fullname)
    }
}

# PowerShell
## 高速化
## 参考：https://bitto.jp/powershell-startup-fast/
Set-Alias ngen @(
    Get-ChildItem (join-path ${env:\windir} "Microsoft.NET\Framework") ngen.exe -recurse |
    Sort-Object -descending lastwritetime
)[0].fullName
[appdomain]::currentdomain.getassemblies() | ForEach-Object { ngen $_.location }

## config
New-Item -ItemType SymbolicLink -Path $HOME/Documents/PowerShell -Target $REPO_HOME/config/powershell

# Git
if (!(Get-Command git | Where-object { $_.Name -match $cmd })) {
    winget install Git.Git -s winget
}

# Startship
if (!(Get-Command starship | Where-object { $_.Name -match $cmd })) {
    winget install --id Starship.Starship
}

# WindowsTerminal
if (!(Get-Command wt | Where-object { $_.Name -match $cmd })) {
    winget install Microsoft.WindowsTerminal -s winget
}
New-Item -ItemType SymbolicLink -Force -Path $env:LOCALAPPDATA/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json -Target $REPO_HOME/config/WindowsTerminal/settings.json

# config
New-Item -ItemType Directory -Force -Path $HOME/.config
Get-ChildItem -Path $REPO_HOME/config/* | ForEach-Object {
    New-Item -ItemType SymbolicLink -Path "$HOME/.config/$($_.Name)" -Target $_.FullName
}

Pause

##########################################################
function downloadFile([string]$url, [string]$saveDir) {
    $fileName = Split-Path $url -Leaf
    $downloadFilePath = $saveDir | Join-Path -ChildPath $fileName
    Invoke-WebRequest $url -OutFile $downloadFilePath
}
