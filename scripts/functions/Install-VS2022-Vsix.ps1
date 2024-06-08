# Based on http://nuts4.net/post/automated-download-and-installation-of-visual-studio-extensions-via-powershell
Function Install-VS2022-Vsix {
    param(
        [String] $PackageName,

        [String] $PackagePath = $null,
        
        [String] $VSInstallDir = $null,

        [String] $VSVersion = "2022",

        [String] $VSEdition = "Enterprise"
    )
 
    $ErrorActionPreference = "Stop"
 
    $baseProtocol = "https:"
    $baseHostName = "marketplace.visualstudio.com"
 
    $Uri = "$($baseProtocol)//$($baseHostName)/items?itemName=$($PackageName)"

    $VsixLocation = "$($env:Temp)\$([guid]::NewGuid()).vsix"

    if ($PackagePath) {    
        Copy-Item -Path $PackagePath -Destination $VsixLocation -Force
    }
 
    # $VSInstallDir = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\resources\app\ServiceHub\Services\Microsoft.VisualStudio.Setup.Service"
    # $VSInstallDir = "C:\Program Files (x86)\Microsoft Visual Studio\2022\Enterprise"

    # Write-Host "VSInstallDir is $($VSInstallDir)"
    if (!$VSInstallDir) {
        # This is the path to VSIXInstaller.exe
        # Write-Host "Set VsInstallDir to default"
        $VSInstallDir = "C:\Program Files\Microsoft Visual Studio\$VSVersion\$VSEdition\Common7\IDE" 
    }
 
    # Write-Host "VSInstallDir is $($VSInstallDir)"
    if (-Not $VSInstallDir) {
        Write-Error "Visual Studio InstallDir is missing"
        Exit 1
    }
 
    if (!$PackagePath) {
        Write-Host "Grabbing VSIX extension at $($Uri)"
        $HTML = Invoke-WebRequest -Uri $Uri -UseBasicParsing -SessionVariable session
 
        Write-Host "Attempting to download $($PackageName)..."
        $anchor = $HTML.Links |
        Where-Object { $_.class -eq 'install-button-container' } |
        Select-Object -ExpandProperty href

        if (-Not $anchor) {
            Write-Error "Could not find download anchor tag on the Visual Studio Extensions page"
            Exit 1
        }
        Write-Host "Anchor is $($anchor)"
        $href = "$($baseProtocol)//$($baseHostName)$($anchor)"
        Write-Host "Href is $($href)"
        Invoke-WebRequest $href -OutFile $VsixLocation -WebSession $session
    }
    
    if (-Not (Test-Path $VsixLocation)) {
        Write-Error "Downloaded VSIX file could not be located"
        Exit 1
    }
    Write-Host "VSInstallDir is $($VSInstallDir)"
    Write-Host "VsixLocation is $($VsixLocation)"
    Write-Host "Installing $($PackageName)..."
    Start-Process -Filepath "$($VSInstallDir)\VSIXInstaller" -ArgumentList "/q /a $($VsixLocation)" -Wait
 
    Write-Host "Cleanup..."
    rm $VsixLocation
 
    Write-Host "Installation of $($PackageName) complete!"
}