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

Start-Sleep -Seconds 10

# Define source and destination paths
$RenameScriptSource = "X:\OSDCloud\Config\Scripts\SetupComplete\Rename.ps1"
$RenameScriptDestination = "C:\Windows\Setup\Scripts\Rename.ps1"

# Ensure the Windows setup scripts folder exists
if (!(Test-Path "C:\Windows\Setup\Scripts\")) {
    New-Item -ItemType Directory -Path "C:\Windows\Setup\Scripts\" -Force
}

# Copy Rename.ps1 from WinPE (X:\) to the Windows drive (C:\)
if (Test-Path $RenameScriptSource) {
    Copy-Item -Path $RenameScriptSource -Destination $RenameScriptDestination -Force
    Write-Host "Copied Rename.ps1 to C:\Windows\Setup\Scripts\"
} else {
    Write-Host "Rename.ps1 not found in X:\OSDCloud\Config\Scripts\SetupComplete\"
}

$SetupCompleteCmdPath = "C:\Windows\Setup\Scripts\SetupComplete.cmd"
$RenameCmd = "`r`n%windir%\system32\windowspowershell\v1.0\powershell.exe -executionpolicy bypass -file C:\Windows\Setup\Scripts\Rename.ps1"

# Check if SetupComplete.cmd exists
if (Test-Path $SetupCompleteCmdPath) {
    # Read the existing content
    $content = Get-Content -Path $SetupCompleteCmdPath

    # Check if Rename.ps1 is already added
    if ($content -notmatch "Rename.ps1") {
        # Ensure we add Rename.ps1 before any 'exit' command
        if ($content -match "exit") {
            $content = $content -replace "exit", "$RenameCmd`r`nexit"
        } else {
            $content += $RenameCmd
        }

        # Write back the updated content
        Set-Content -Path $SetupCompleteCmdPath -Value $content -Encoding UTF8
        Write-Host "Updated SetupComplete.cmd to execute Rename.ps1"
    } else {
        Write-Host "Rename.ps1 execution already exists in SetupComplete.cmd, no changes made."
    }
} else {
    Write-Host "SetupComplete.cmd not found, skipping modification."
}

# Pause before restart for verification
##Write-Host "Waiting for 10 seconds before rebooting..."
##Start-Sleep -Seconds 10

# Restart After OS Deployment
##Write-Host "Restarting system..."
##wpeutil reboot
