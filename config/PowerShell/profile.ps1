# 参考
# https://sheepla.github.io/sheepla-note/posts/powershell-customization/
# https://zenn.dev/doremire/articles/8e5ae4d0235db4
# https://qiita.com/FKbelm/items/2edb23d4f57e8c0d4fb4

# 実行ポリシーの変更
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# PSFzfの読み込みとAlias有効化
Import-Module PSFzf
Enable-PsFzfAliases

# 予測インテリセンスを有効化
# ※適用は「→」キー
Set-PSReadLineOption -PredictionSource History

# 重複した履歴を保存しないように
Set-PSReadLineOption -HistoryNoDuplicates

# ベル音の無効化
Set-PSReadlineOption -BellStyle None

# 予測インテリセンスをbash風に
Set-PSReadLineKeyHandler -Key Tab -Function Complete

# 一部コマンドのタブ補完機能を有効化
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }

# プロンプトカスタマイズモジュールの初期設定
Invoke-Expression (&starship init powershell)

# 文字コード変更
[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding('utf-8')
