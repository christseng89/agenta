$filePath = "D:\development\PromptEngineering\agenta\web\entrypoint.sh"
$content = Get-Content $filePath -Raw
$content = $content -replace "`r`n", "`n"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($filePath, $content, $utf8NoBom)
Write-Host "Line endings converted to LF"
