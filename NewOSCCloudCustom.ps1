

Write-Log "Starting OSDCloud Custom Deployment..." -Color Cyan

# Ensure OSD Module is Up-to-Date (Silent)
try {
    Install-Module OSD -Force -ErrorAction Stop
    Import-Module OSD -Force -ErrorAction Stop
    Write-Log "OSD module installed and imported successfully."
} catch {
    Write-Log "Warning: OSD module installation/import failed. Proceeding..." -Color Yellow
}

# Prompt for Computer Name
do {
    $ComputerName = (Read-Host "Enter computer name").ToUpper()
    if ($ComputerName -match "^[A-Z]{4}(M|W|L)(LAP|WKS|VDI)\d{6}$") {
        $Valid = $true
        Write-Log "Valid computer name entered: $ComputerName"
    } else {
        Write-Log "Invalid name format. Please try again." -Color Red
        $Valid = $false
    }
} until ($Valid)

# Prompt for OS Language
do {
    $osLanguage = Read-Host "Please enter the OS language (e.g., en-US, de-DE)"
    
    try {
        Write-Log "Starting OSDCloud deployment with language: $osLanguage..."
        Start-OSDCloud -OSName 'Windows 11 24H2 x64' -OSEdition Pro -OSLanguage $osLanguage -OSActivation Volume -ZTI *>&1 | Tee-Object -FilePath $LogFile -Append
        $Success = $true
    } catch {
        Write-Log "Invalid OS Language entered. Please try again." -Color Red
        $Success = $false
    }
} until ($Success)

Write-Log "Deployment in progress..." -Color Cyan

# OS Installation Completed
Write-Log "Operating system installation completed. Adding additional configuration to complete the OSDCloud deployment..."

# Define the XML content for the Unattend.xml file
$UnattendXML = @"
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="specialize">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <ComputerName>$ComputerName</ComputerName>
        </component>
    </settings>
</unattend>
"@

# Define the path to save the Unattend.xml file
$UnattendPath = "C:\Windows\Panther\Unattend.xml"

# Save the Unattend.xml file silently
try {
    $UnattendXML | Out-File -Encoding utf8 -FilePath $UnattendPath -Force
    Write-Log "Unattend.xml file saved to $UnattendPath."
} catch {
    Write-Log "Failed to save Unattend.xml file to $UnattendPath. Error: $_"
    exit 1
}

# Restart the system after OS deployment
Write-Log "Restarting system in 10 seconds..."
Start-Sleep -Seconds 10
wpeutil reboot
