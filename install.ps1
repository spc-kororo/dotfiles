function downloadFile {
    [OutputType([void])]
    param([string]$url, [string]$saveDir)
    $fileName = Split-Path $url -Leaf
    $downloadFilePath = Join-Path -Path $saveDir -ChildPath $fileName
    Invoke-WebRequest $url -OutFile $downloadFilePath
}

function loadInstalledFontNames {
    [OutputType([string])]
    param()

    Add-Type -AssemblyName System.Drawing
    $userFontsDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"

    $installedSystemFonts = (New-Object System.Drawing.Text.InstalledFontCollection)
    $installedUserFonts = New-Object System.Drawing.Text.PrivateFontCollection
    Get-ChildItem $userFontsDir | ForEach-Object {
        $installedUserFonts.AddFontFile($_.FullName)
    }

    return $installedSystemFonts.Families.Name + $installedUserFonts.Families.Name
}

### メイン処理 ###

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
    Remove-Item -Path $tempDir\* -Force -Recurse
}
else {
    mkdir $tempDir
}

# Font
## Nerd Fontのダウンロード
downloadFile "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Inconsolata.zip" $tempDir

## プログラミングフォントのダウンロード
downloadFile "https://github.com/tomokuni/Myrica/raw/master/product/Myrica.zip" $tempDir

## プログラミングフォントインストール前の準備
$systemFontsDir = "$env:windir\Fonts"
$fonts = (New-Object -ComObject Shell.Application).Namespace($systemFontsDir)
$installedFontNames = loadInstalledFontNames

## プログラミングフォントのインストール
Get-ChildItem -Path $tempDir\* -Include *.zip | ForEach-Object {
    $destDir = $_.FullName.Substring(0, $_.FullName.LastIndexOf('.'))
    Expand-Archive -Path $_.FullName -DestinationPath $destDir
    Get-ChildItem -Path $destDir\* -Include *.tt? | ForEach-Object {
        # フォントファイルからフォント名を取得する
        $pfc = New-Object System.Drawing.Text.PrivateFontCollection
        $pfc.AddFontFile($_.FullName)
        $fontName = $pfc.Families[0].Name

        # 未インストールの場合のみ実行
        if (!($installedFontNames | Where-Object { $_ -eq $fontName })) {
            $fonts.CopyHere($_.fullname)
        }
    }
}

# PowerShell
## 高速化
## 参考：https://秀丸マクロ.net/?page=nobu_tool_hm_powershell_ngen
Set-Alias ngen @(
    Get-ChildItem (join-path ${env:\windir} "Microsoft.NET\Framework") ngen.exe -recurse |
    Sort-Object -descending lastwritetime
)[0].fullName
Set-Alias ngen64 @(
    Get-ChildItem (join-path ${env:\windir} "Microsoft.NET\Framework64") ngen.exe -recurse |
    Sort-Object -descending lastwritetime
)[0].fullName
[appdomain]::currentdomain.getassemblies() | ForEach-Object {
    if ($_.location -match $(‘\\assembly\\GAC_64’)) {
        ngen64 install $_.location
    }
    else {
        ngen install $_.location
    }
}

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

# clink
# ※パスが通らないフォルダにインストールされるため、一時的にパスを通しておく
$env:Path += ";C:\Program Files (x86)\clink";
if (!(Get-Command clink | Where-object { $_.Name -match $cmd })) {
    winget install clink
    [System.Environment]::SetEnvironmentVariable("CLINK_PROFILE", "$HOME/.config/clink", [System.EnvironmentVariableTarget]::User)
}

# WindowsTerminal
if (!(Get-Command wt | Where-object { $_.Name -match $cmd })) {
    winget install Microsoft.WindowsTerminal -s winget
}
New-Item -ItemType SymbolicLink -Force -Path $env:LOCALAPPDATA/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json -Target $REPO_HOME/config/WindowsTerminal/settings.json

# 各種config
$excludedList = @(
    "bash"
    , "PowerShell"
    , "WindowsTerminal"
)
New-Item -ItemType Directory -Force -Path $HOME/.config
Get-ChildItem -Path $REPO_HOME/config/* | Where-Object { $excludedList -notcontains $_.Name } | ForEach-Object {
    New-Item -ItemType SymbolicLink -Force -Path "$HOME/.config/$($_.Name)" -Target $_.FullName
}
New-Item -ItemType SymbolicLink -Force -Path "$HOME/.bashrc" -Target "$REPO_HOME/config/bash/.bashrc"
New-Item -ItemType SymbolicLink -Force -Path "$HOME/.bash_aliases" -Target "$REPO_HOME/config/bash/.bash_aliases"

Pause
