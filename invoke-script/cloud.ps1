Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "         Please wait, preparing...   " -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Cyan

# Define URL and output path
$batUrl = "https://raw.githubusercontent.com/NammIsADev/OptimizedToolsPlusPlus/main-development/invoke-script/stable.bat"
$batPath = Join-Path -Path (Get-Location) -ChildPath "stable.bat"

Write-Host "`nDownloading essential files..." -ForegroundColor Green
Invoke-WebRequest -Uri $batUrl -OutFile $batPath -UseBasicParsing

Write-Host "Download complete. Launching tool..." -ForegroundColor Green

# Execute the .bat file
Start-Process -FilePath $batPath -Wait
