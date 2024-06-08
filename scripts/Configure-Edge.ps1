. .\functions\Export-EdgeProfiles.ps1
. .\functions\Import-EdgeProfiles.ps1

# Export-EdgeProfiles -ProfilePath "$($env:USERPROFILE)\AppData\Local\Microsoft\Edge\User Data" -ExportPath "D:\WorkstationSetup\Edge\Profiles"

Import-EdgeProfiles -ProfilePath "$($env:USERPROFILE)\AppData\Local\Microsoft\Edge\User Data" -ImportPath "E:\D\WorkstationSetup\Edge\Profiles"