# This script is for custom OSD Cloud

Write-Host -ForegroundColor Cyan "Starting Ingram Micro OSD Custom OSDCloud ..."
Start-Sleep -Seconds 5

# Make sure I have the latest OSD Content
Write-Host -ForegroundColor Cyan "Updating the awesome OSD PowerShell Module"
Install-Module OSD -Force

Write-Host -ForegroundColor Cyan "Importing the sweet OSD PowerShell Module"
Import-Module OSD -Force

# Start OSDCloud ZTI the RIGHT way
Write-Host -ForegroundColor Cyan "Start OSDCloud with MY Parameters"
Start-OSDCloud -OSName 'Windows 11 24H2 x64' -OSEdition Pro -OSLanguage en-us -Verbose

# Restart from WinPE
Write-Host -ForegroundColor Cyan "Restarting in 20 seconds!"
Start-Sleep -Seconds 20
wpeutil reboot
