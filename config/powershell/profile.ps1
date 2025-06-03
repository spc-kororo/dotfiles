# 参考
# https://sheepla.github.io/sheepla-note/posts/powershell-customization/
# https://zenn.dev/doremire/articles/8e5ae4d0235db4
# https://qiita.com/FKbelm/items/2edb23d4f57e8c0d4fb4

# 実行ポリシーの変更
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# 予測インテリセンスを有効化
# ※適用は「→」キー
Set-PSReadLineOption -PredictionSource History

# 重複した履歴を保存しないように
Set-PSReadLineOption -HistoryNoDuplicates

# 予測インテリセンスをbash風に
Set-PSReadLineKeyHandler -Key Tab -Function Complete

# ベル音の無効化
Set-PSReadlineOption -BellStyle None

# プロンプトカスタマイズモジュールの初期設定
oh-my-posh init pwsh --config "$HOME\Documents\PowerShell\stelbent-compact.minimal.omp.custom.json" | Invoke-Expression

# 文字コード変更
[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding('utf-8')
