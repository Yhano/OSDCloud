Start-OSDCloud -OSName 'Windows 11 24H2 x64' -OSEdition Pro -OSLanguage en-us -Verbose -ErrorAction Stop

# Restart from WinPE
wpeutil reboot -ErrorAction Stop
