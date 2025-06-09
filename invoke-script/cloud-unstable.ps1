Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "    This is a unstable build. you have been warned!   " -ForegroundColor Yellow
Write-Host "    Please wait...   " -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Cyan

# Define URL and output path
$batUrl = "https://raw.githubusercontent.com/NammIsADev/OptimizedToolsPlusPlus/main-development/version/unstable.bat"
$batPath = Join-Path -Path (Get-Location) -ChildPath "unstable.bat"

Write-Host "`nDownloading essential files..." -ForegroundColor Green
Invoke-WebRequest -Uri $batUrl -OutFile $batPath -UseBasicParsing

Write-Host "Download complete. Launching tool..." -ForegroundColor Green

# Execute the .bat file
Start-Process -FilePath $batPath -Wait
