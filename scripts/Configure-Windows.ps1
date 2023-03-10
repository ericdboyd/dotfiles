Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions

Enable-RemoteDesktop

# Disable Password Caching
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" "DisablePasswordCaching" 1

# Configure Power Plan Settings
powercfg /X monitor-timeout-ac 5
powercfg /X monitor-timeout-dc 5
powercfg /X standby-timeout-ac 5
powercfg /X standby-timeout-dc 0

# Enable Developer Mode
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" "AllowDevelopmentWithoutDevLicense" 1
