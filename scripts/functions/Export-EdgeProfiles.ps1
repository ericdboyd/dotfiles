Function Export-EdgeProfiles {
    param (
        [string]
        [Parameter(Mandatory = $true)]
        $ProfilePath,

        [string]
        [Parameter(Mandatory = $true)]
        $ExportPath 
    )

    Get-ChildItem -Path $ProfilePath -Filter "Profile *" -Directory | ForEach-Object { 
        # Copy-Item -Path $_ -Destination $ExportPath -Force -Container -Recurse 
        Write-Host $_
    }
}