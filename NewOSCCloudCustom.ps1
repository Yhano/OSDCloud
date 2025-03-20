Clear-Host
Write-Host -ForegroundColor Cyan "Starting OSDCloud Custom Deployment..."

# Ensure OSD Module is Up-to-Date
Write-Host -ForegroundColor Cyan "Updating OSD Module..."
try {
    Install-Module OSD -Force -ErrorAction SilentlyContinue | Out-Null
    Import-Module OSD -Force -ErrorAction SilentlyContinue | Out-Null
} catch {
    Write-Host -ForegroundColor Yellow "Warning: Failed to install or import OSD module. Continuing..."
}

# Prompt for Computer Name
do {
    Clear-Host
    $ComputerName = (Read-Host "Enter computer name").ToUpper()

    if ($ComputerName -match "^[A-Z]{4}(M|W|L)(LAP|WKS|VDI)\d{6}$") {
        break  # Exit loop if valid
    } else {
        Write-Host -ForegroundColor Red "Invalid name format. Please try again."
        Start-Sleep -Seconds 2
    }
} until ($false)

# Prompt for OS Language
do {
    Clear-Host
    $osLanguage = Read-Host -Prompt "Please enter the OS language (e.g., en-US, de-DE)"

    Write-Host "Starting OSDCloud deployment with language: $osLanguage..."
    
    # Run OSDCloud Silently
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"Start-OSDCloud -OSName 'Windows 11 24H2 x64' -OSEdition Pro -OSLanguage $osLanguage -OSActivation Volume -ZTI *> `$null`"" -WindowStyle Hidden -Wait

    if ($LASTEXITCODE -eq 0) {
        break  # Exit loop if successful
    } else {
        Write-Host -ForegroundColor Red "OSDCloud process failed. Please try again."
        Start-Sleep -Seconds 2
    }
} until ($false)

# Define and save Unattend.xml silently
$UnattendXML = @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <ComputerName>$ComputerName</ComputerName>
        </component>
    </settings>
</unattend>
"@

$UnattendPath = "C:\Windows\Panther\Unattend.xml"
$UnattendXML | Out-File -Encoding utf8 -FilePath $UnattendPath -Force

Write-Host -ForegroundColor Green "Deployment completed. Restarting system..."
Start-Sleep -Seconds 5
wpeutil reboot
