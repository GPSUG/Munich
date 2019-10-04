
$comments = ConvertFrom-Json $(Get-Content -Path ".\3_Start_JSON\5_comments.json" -Raw )

$comments

$comments.PsObject.Properties.Remove("__comment")

$comments