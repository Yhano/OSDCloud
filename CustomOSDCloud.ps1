Write-Host -ForegroundColor Cyan "Starting OSDCloud Custom Deployment..."

# Ensure OSD Module is Up-to-Date
Write-Host -ForegroundColor Cyan "Updating OSD Module..."
Install-Module OSD -Force -ErrorAction SilentlyContinue
Import-Module OSD -Force -ErrorAction SilentlyContinue

# Prompt the user for the OS language
$osLanguage = Read-Host -Prompt "Please enter the OS language (e.g., en-US, de-DE)"

# Start OSDCloud Deployment with Custom OS Settings
Write-Host "Starting OSDCloud deployment..."
Start-OSDCloud -OSName 'Windows 11 24H2 x64' -OSEdition Pro -OSLanguage $osLanguage -OSActivation Volume

# Wait for OSDCloud to finish
Write-Host "Waiting for OSDCloud deployment to complete..."
Start-Sleep -Seconds 10  # Adjust if necessary

$NewComputerName = Read-Host "Enter new computer name"

# Validate Hostname
if ($NewComputerName -match "^[A-Z]{4}(M|W|L)(LAP|WKS|VDI)\d{6}$") {
    Write-Host "Saving new computer name: $NewComputerName"
    Set-Content -Path "C:\Windows\Setup\Scripts\NewComputerName.txt" -Value $NewComputerName
} else {
    Write-Host "Invalid name. Skipping rename."
    Exit 1
}

# Define SetupComplete path
$SetupCompletePath = "C:\Windows\Setup\Scripts\SetupComplete.cmd"

Write-Host "`n🟢 [DEBUG] Modifying SetupComplete.cmd..." -ForegroundColor Green

# Ensure the Scripts folder exists
if (!(Test-Path "C:\Windows\Setup\Scripts")) {
    Write-Host "⚠️ [WARNING] Scripts folder does not exist. Creating it..."
    New-Item -Path "C:\Windows\Setup\Scripts" -ItemType Directory -Force
}

# Check if SetupComplete.cmd exists
if (Test-Path $SetupCompletePath) {
    Write-Host "🟢 [DEBUG] SetupComplete.cmd found. Backing up..."
    Copy-Item -Path $SetupCompletePath -Destination "$SetupCompletePath.bak" -Force
} else {
    Write-Host "🟠 [INFO] SetupComplete.cmd not found. Creating a new one..."
    New-Item -Path $SetupCompletePath -ItemType File -Force
}

# Show existing content (before modification)
Write-Host "`n🔍 [DEBUG] Current SetupComplete.cmd Content:"
Get-Content -Path $SetupCompletePath

# Append custom rename logic
$CustomRenameScript = @"
:: Custom Rename Computer Script
echo Running Custom Rename

if exist C:\Windows\Setup\Scripts\NewComputerName.txt (
    set /p NEWNAME=<C:\Windows\Setup\Scripts\NewComputerName.txt
    echo Found NewComputerName.txt, setting computer name: %NEWNAME%
    echo Renaming %COMPUTERNAME% to %NEWNAME%
    wmic computersystem where name='%COMPUTERNAME%' call rename name='%NEWNAME%'
    del C:\Windows\Setup\Scripts\NewComputerName.txt
    shutdown /r /t 10
) else (
    echo No NewComputerName.txt found. Skipping rename.
)
"@

# Append the script to SetupComplete.cmd
Add-Content -Path $SetupCompletePath -Value "`r`n$CustomRenameScript"

# Show updated content (after modification)
Write-Host "`n🔍 [DEBUG] Updated SetupComplete.cmd Content:"
Get-Content -Path $SetupCompletePath

Write-Host "`n✅ [SUCCESS] SetupComplete.cmd modification completed."

# Pause before restart for verification
##Write-Host "Waiting for 10 seconds before rebooting..."
##Start-Sleep -Seconds 10

# Restart After OS Deployment
##Write-Host "Restarting system..."
##wpeutil reboot
