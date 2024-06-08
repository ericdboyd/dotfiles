$directory = Get-ChildItem -Path "F:\D" -Directory
foreach ($directoryItem in $directory) {
    $destination = "D:\$(Split-Path -Path $directoryItem -Leaf)"
    Write-Host "Copying $directoryItem to $destination"
    & "robocopy" $directoryItem $destination /S /E /Z /ZB /R:5 /W:5 /TBD /V /MT:32
}