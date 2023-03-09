# Hide desktop system files
Get-Item ([Environment]::GetFolderPath("Desktop")+"\*.lnk") | Remove-Item -Force
Get-Item ([Environment]::GetFolderPath("CommonDesktopDirectory")+"\*.lnk") | Remove-Item -Force