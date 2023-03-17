# Configure Power Lid Close Action
# retrieve the current power mode Guid
$guid = (Get-WmiObject -Class win32_powerplan -Namespace root\cimv2\power -Filter "isActive='true'").InstanceID.ToString()
$regex = [regex]"{(.*?)}$" 
$guidVal = $regex.Match($guid).groups[1].value #$regex.Match($guid) 
# Write-Host $guidVal

# Set close the lid power option to 'Do Nothing' for plugged in.
# https://learn.microsoft.com/en-us/windows-hardware/customize/power-settings/power-button-and-lid-settings
$powerButtonAndLidSettingsSubGroupGuid = "4f971e89-eebd-4455-a8de-9e59040e7347"

# https://learn.microsoft.com/en-us/windows-hardware/customize/power-settings/power-button-and-lid-settings-lid-switch-close-action
$lidSwitchCloseActionGuid = "5ca83367-6e45-459f-a27b-476b1d01c936"

powercfg -SETACVALUEINDEX $guidVal $powerButtonAndLidSettingsSubGroupGuid $lidSwitchCloseActionGuid 0

#To see what other options are available - run the following:
# powercfg -Q $guidVal

# Configure Power Plan Timeout Settings
powercfg /X monitor-timeout-ac 5
powercfg /X monitor-timeout-dc 5
powercfg /X standby-timeout-ac 0
powercfg /X standby-timeout-dc 5