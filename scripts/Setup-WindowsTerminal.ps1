$workstationSetupPath = "D:\WorkstationSetup"

# Get-ChildItem "$workstationSetupPath\OMP\Themes" -Filter "ericdboyd.*" | ForEach-Object { 
#     Copy-Item -Path $_ -Destination "$env:POSH_THEMES_PATH" -Force
# }

Get-ChildItem "$workstationSetupPath\PowerShell\Profiles" | ForEach-Object { 
    Copy-Item -Path $_ -Destination (Split-Path -Parent $PROFILE) -Force
}