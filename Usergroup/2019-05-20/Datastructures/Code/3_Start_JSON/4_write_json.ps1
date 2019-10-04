

$services = Get-Service

New-Item -ItemType File -Path ".\3_Start_JSON\services.json" -Value $(ConvertTo-Json $services) -Force

$servicesJson = ConvertFrom-Json $(Get-Content -Path ".\3_Start_JSON\services.json" -Raw )

$servicesJson

$servicesJson[1]