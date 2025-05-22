$batUrl = "https://raw.githubusercontent.com/NammIsADev/OptimizedToolsPlusPlus/main-development/invoke-script/stable.bat"
$batPath = "$env:TEMP\stable.bat"

Invoke-WebRequest -Uri $batUrl -OutFile $batPath
Start-Process -FilePath $batPath -Wait
