function Install-WingetApps {
    [CmdletBinding()]
    param (
        [Parameter()]
        $AppsToInstall
    )
    Foreach ($app in $AppsToInstall) {
        $installApp = $true
        if ($null -ne $app.id) {
            Write-Host "Checking:" $app.id
            $listApp = winget list --id $app.id
            if ([String]::Join("", $listApp).Contains($app.id)) {
                $installApp = $false
            }
        }
        else {
            Write-Host "Checking:" $app.name
            $listApp = winget list --exact -q $app.name
            if ([String]::Join("", $listApp).Contains($app.name)) {
                $installApp = $false
            }
        }
    
        if ($installApp) {
            Write-Host "Installing:" $app.name "-" $app.id "-" $app.source
            if ($null -ne $app.source) {
                if ($null -ne $app.id) {
                    winget install --exact --silent --id $app.id --source $app.source --accept-package-agreements --accept-source-agreements --ignore-security-hash
                }
                else {
                    winget install --exact --silent --name $app.name --source $app.source --accept-package-agreements --accept-source-agreements --ignore-security-hash
                }
            }
            else {
                if ($null -ne $app.id) {
                    winget install --exact --silent --id $app.id --accept-package-agreements --accept-source-agreements --ignore-security-hash
                }
                else {
                    winget install --exact --silent --name $app.name --accept-package-agreements --accept-source-agreements --ignore-security-hash
                }
            }
        }
        else {
            Write-Host "Skipping Install of name:" $app.name " id:" $app.id " source:" $app.source
        }
    }
}