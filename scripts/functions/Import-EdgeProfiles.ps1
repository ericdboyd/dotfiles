Function Import-EdgeProfiles {
    param (
        [string]
        [Parameter(Mandatory = $true)]
        $ProfilePath,

        [string]
        [Parameter(Mandatory = $true)]
        $ImportPath 
    )

Get-ChildItem -Path $ImportPath -Filter "Profile *" -Directory | ForEach-Object { 
    Copy-Item -Path $_ -Destination $ProfilePath -Force -Container -Recurse 
    # Write-Host $_
}

# Get-ChildItem -Path $ImportPath -Filter "Profile *" -Directory | ForEach-Object { Write-Host $_ }
}