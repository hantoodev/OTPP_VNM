# Define URL and output path
$batUrl = "https://raw.githubusercontent.com/NammIsADev/OptimizedToolsPlusPlus/main-development/invoke-script/stable.bat"
$batPath = Join-Path -Path (Get-Location) -ChildPath "stable.bat"

# Download the .bat file
Invoke-WebRequest -Uri $batUrl -OutFile $batPath -UseBasicParsing

# Execute the .bat file
Start-Process -FilePath $batPath -Wait
