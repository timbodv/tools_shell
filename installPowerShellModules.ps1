$ProgressPreference = 'SilentlyContinue'

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

"Az",
"AWSPowerShell.NetCore",
"ImportExcel",
"Join-Object",
"Microsoft.PowerShell.Crescendo",
"powershell-yaml",
"dbatools" | % { Install-Module $_ -Scope AllUsers; Write-Host "." -NoNewline }

$null = Update-Help -Scope AllUsers -Force -ErrorAction Ignore
