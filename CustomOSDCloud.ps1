# This script is for custom OSD Cloud
Write-Host -ForegroundColor Cyan "Starting Ingram Micro OSD Custom OSDCloud ..."
Start-Sleep -Seconds 5

# Make sure I have the latest OSD Content
Write-Host -ForegroundColor Cyan "Updating the awesome OSD PowerShell Module"
Install-Module OSD -Force

Write-Host -ForegroundColor Cyan "Importing the sweet OSD PowerShell Module"
Import-Module OSD -Force

# TODO: Spend the time to write a function to do this and put it here
Write-Host -ForegroundColor Cyan "Ejecting ISO"
Write-Warning "That didn't work because I haven't coded it yet!"
# Start-Sleep -Seconds 5

# Set OSDCloud parameters to skip disk clearing confirmation
$OSDCloud.SkipClearDisk = $false
$OSDCloud.ClearDiskConfirm = $false

# Start OSDCloud ZTI the RIGHT way
Write-Host -ForegroundColor Cyan "Start OSDCloud with MY Parameters"
Start-OSDCloud -OSName 'Windows 11 24H2 x64' -OSEdition Pro -OSLanguage en-US -OSActivation Volume -ErrorAction Stop

# Anything I want can go right here and I can change it at any time since it is in the Cloud!!!!!
Write-Host -ForegroundColor Cyan "Starting OSDCloud PostAction ..."

# Restart from WinPE
Write-Host -ForegroundColor Cyan "Restarting in 20 seconds!"
Start-Sleep -Seconds 20
wpeutil reboot
