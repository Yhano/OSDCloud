Write-Host -ForegroundColor Cyan "Starting OSDCloud Custom Deployment..."

# Ensure OSD Module is Up-to-Date
Write-Host -ForegroundColor Cyan "Updating OSD Module..."
Install-Module OSD -Force -ErrorAction SilentlyContinue
Import-Module OSD -Force -ErrorAction SilentlyContinue

# Prompt the user for the OS language
$osLanguage = Read-Host -Prompt "Please enter the OS language (e.g., en-US, de-DE)"

$OSDCloud.ClearDiskConfirm = $false

# Start OSDCloud Deployment with Custom OS Settings
Write-Host "Starting OSDCloud deployment..."
Start-OSDCloud -OSName 'Windows 11 24H2 x64' -OSEdition Pro -OSLanguage $osLanguage -OSActivation Volume

# Wait for OSDCloud to finish
Write-Host "Waiting for OSDCloud deployment to complete..."
Start-Sleep -Seconds 10

$NewComputerName = Read-Host "Enter new computer name"

# Validate Hostname
if ($NewComputerName -match "^[A-Z]{4}(M|W|L)(LAP|WKS|VDI)\d{6}$") {
    Write-Host "Saving new computer name: $NewComputerName"
    Set-Content -Path "C:\Windows\Setup\Scripts\NewComputerName.txt" -Value $NewComputerName
} else {
    Write-Host "Invalid name. Skipping rename."
    Exit 1
}

Start-Sleep -Seconds 30

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

Start-Sleep -Seconds 30

# Ensure $RenameCmd and $SetupCompleteCmdPath are initialized
$RenameCmd = "`r`n%windir%\system32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -file C:\Windows\Setup\Scripts\Rename.ps1"
$SetupCompleteCmdPath = "C:\Windows\Setup\Scripts\SetupComplete.cmd"

# Ensure SetupComplete.cmd exists and contains @echo off
if (Test-Path -Path $SetupCompleteCmdPath) {
    $content = Get-Content -Path $SetupCompleteCmdPath -Raw

    # Ensure @echo off is at the top
    if ($content -notmatch "@echo off") {
        $content = "@echo off`r`n" + $content
    }

    if ($content -notmatch "Rename.ps1") {
        # Ensure Rename.ps1 runs before exit
        if ($content -match "exit") {
            $content = $content -replace "exit", "$RenameCmd`r`nexit"
        } else {
            $content += "`r`n$RenameCmd`r`nexit"
        }

        try {
            Set-Content -Path $SetupCompleteCmdPath -Value $content -Encoding ASCII
            Write-Host "Updated SetupComplete.cmd to execute Rename.ps1"
        } catch {
            Write-Host "Failed to update SetupComplete.cmd: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "Rename.ps1 execution already exists in SetupComplete.cmd, no changes made."
    }
} else {
    # If SetupComplete.cmd doesn't exist, create it with @echo off
    @"
@echo off
echo [%DATE% %TIME%] SetupComplete.cmd started >> C:\Windows\Setup\Scripts\SetupComplete.log
%windir%\system32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -file C:\Windows\Setup\Scripts\SetupComplete.ps1 >> C:\Windows\Setup\Scripts\SetupComplete.log 2>&1
echo [%DATE% %TIME%] SetupComplete.ps1 executed >> C:\Windows\Setup\Scripts\SetupComplete.log

timeout /t 10 /nobreak
echo [%DATE% %TIME%] Waiting before executing Rename.ps1 >> C:\Windows\Setup\Scripts\SetupComplete.log

%windir%\system32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -file C:\Windows\Setup\Scripts\Rename.ps1 >> C:\Windows\Setup\Scripts\SetupComplete.log 2>&1
echo [%DATE% %TIME%] Rename.ps1 executed >> C:\Windows\Setup\Scripts\SetupComplete.log
exit
"@ | Set-Content -Path $SetupCompleteCmdPath -Encoding ASCII

    Write-Host "Created new SetupComplete.cmd successfully with @echo off." | Tee-Object -FilePath C:\Windows\Setup\Scripts\OSDCloud.log -Append
}

Start-Sleep -Seconds 60

# Pause before restart for verification (uncomment if needed)
# Write-Host "Waiting for 10 seconds before rebooting..."
# Start-Sleep -Seconds 10

# Restart After OS Deployment (uncomment if needed)
# Write-Host "Restarting system..."
# wpeutil reboot
