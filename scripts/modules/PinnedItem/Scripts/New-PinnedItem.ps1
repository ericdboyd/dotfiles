Function New-PinnedItem {
    <#
        .SYNOPSIS
            Adds a pinned item to the StartMenu/Taskbar

        .DESCRIPTION
            Adds a pinned item to the StartMenu/Taskbar

        .PARAMETER TargetPath
            Full path to the item that will be pinned

        .PARAMETER Type
            Determine where item will be pinned to.

            Acceptable values:
                StartMenu
                Taskbar

        .PARAMETER Argument
            Additional arguments that will be supplied to create shortcut that will
            be used to pin to Taskbar or StartMenu

        .PARAMETER IconLocation
            Location to icon file path.

        .PARAMETER ShortCutPath
            Name and place where shortcut will be created prior to pinning it to 
            Taskbar or StartMenu.

        .PARAMETER WorkingDirectory
            The directory to start the process in.

        .NOTES
            Name: New-PinnedItem
            Author: Boe Prox
            Version History
                1.0 //Boe Prox - 03 June 2015
                    - Initial Build

        .EXAMPLE
            New-PinnedItem -Type StartMenu -TargetPath "C:\windbg.exe" 

            Description
            -----------
            Pins Windbg to the StartMenu

        .EXAMPLE
            New-PinnedItem -TargetPath "C:\Program Files (x86)\Internet Explorer\iexplore.exe" -Type TaskBar

            Description
            -----------
            Pins Internet Explorer to the TaskBar

        .EXAMPLE
            $TargetPath = 'PowerShell.exe'
            $ShortCutPath = 'WinDbg.lnk'
            $Argument = "-ExecutionPolicy Bypass -NoProfile -NoLogo -Command `"& 'C:\users\proxb\desktop\Windbg.exe'`""
            $Icon = 'C:\users\proxb\desktop\Windbg.exe'
            New-PinnedItem -TargetPath $TargetPath -ShortCutPath $ShortcutPath -Argument $Argument -Type TaskBar -IconLocation $Icon

            Description
            -----------
            Pins an application that normally couldn't be pinned to the Taskbar by defining a custom
            shortcut that is then pinned to the Taskbar.
    #>
    [cmdletbinding(
        DefaultParameterSetName='__DefaultParameterSet'
    )]
    Param (
        [parameter(Position=0,ParameterSetName='AltShortcut')]
        [parameter(Position=0,ParameterSetName='__DefaultParameterSet')]
        [string]$TargetPath,
        [PinnedType]$Type,
        [parameter(ParameterSetName='AltShortcut')]
        [string]$Argument,
        [parameter(ParameterSetName='AltShortcut')]
        [string]$IconLocation,
        [parameter(ParameterSetName='AltShortcut')]
        [ValidateScript({
            If ($_ -match '\.lnk|\.url') {
                $True
            } Else {
                Throw "The extension must end in .lnk or .url!"
            }
        })]
        [string]$ShortcutPath,
        [parameter(ParameterSetName='AltShortcut')]
        [string]$WorkingDirectory

    )

    Write-Verbose "Creating Shell ComObject"
    $Shell = New-Object -ComObject Shell.Application

    If ($PSCmdlet.ParameterSetName -eq 'AltShortcut') {
        $File = $TargetPath -replace '.*\\(.*)','$1' 
        Write-Host "File: $File"       
        $WShell = New-Object -ComObject WScript.Shell
        If ($PSBoundParameters.ContainsKey('ShortcutPath')) {
            Write-Host "Contains ShortcutPath"
            Write-host "Shortcut Path: $ShortcutPath"
            Try {
                Write-host "Try"
                $shortcutDirectoryPath = Split-Path -Parent $ShortcutPath 
                Write-host "Shortcut Directory Path: $shortcutDirectoryPath"
                Convert-Path $shortcutDirectoryPath -ErrorAction Stop
            } Catch {
                Write-host "Catch"
                $ShortcutPath = Join-Path $PWD $ShortcutPath
            }
            Write-Host "Shortcut Path in the contains: $ShortcutPath"
            $Shortcut = $WShell.CreateShortcut($ShortcutPath)
        } Else {
            $Link = $File -replace '^(.*)?\..*','$1.lnk'
            $Shortcut = $WShell.CreateShortcut("$($PWD)\$Link")
        }
        Write-Verbose "ShortcutPath: $($Shortcut.fullname)"
        If ($PSBoundParameters.ContainsKey('IconLocation')) {
            $Shortcut.IconLocation = $IconLocation
        }
        If ($PSBoundParameters.ContainsKey('Argument')) {
            $Shortcut.Arguments = $Argument
        }
        If ($PSBoundParameters.ContainsKey('WorkingDirectory')) {
            $Shortcut.WorkingDirectory = $WorkingDirectory
        }
        Write-Host "TargetPath: $TargetPath"
        $Shortcut.TargetPath = $TargetPath
        $Shortcut.Save()
        $TargetPath = $Shortcut.Fullname
    }

    If ($TargetPath -match '^(?<Path>.*\\)(?<File>.*)$') {
        $Path = $Matches.Path
        $File = $Matches.File
        Write-host "Path: $($Path) -- File: $($File)"
        $NameSpace = $Shell.NameSpace($Path)
        $NameSpaceFile = $NameSpace.ParseName($File)
        Write-Host "Type: $Type"
        Write-Host "Namespace: $NameSpace"
        Write-Host "NameSpaceFile.Verbs: " + $NameSpaceFile.Verbs()

        Switch ($Type) {
            'Taskbar' {
                $_Verb = ConvertToVerb -Action PintoTaskbar
                Write-Host "Verb: $_Verb"
                $Verb = $NameSpaceFile.Verbs() | Where-Object {
                    $_.Name -eq $_Verb
                }                    
                Write-Host "Verb: $Verb"
            }
            'StartMenu' {
                $_Verb = ConvertToVerb -Action PintoStartMenu
                $Verb = $NameSpaceFile.Verbs() | Where-Object {
                    $_.Name -eq $_Verb
                }                     
            }
        }
        If ($Verb) {
            $Verb.DoIt()
        } Else {
            Write-Warning "Unable to perform action: Pin $($File) to $($Type)!"
        }
    } Else {
        Write-Warning "Unable to parse File and Path from provided Fullname: $($TargetPath)!"
    }

    Write-Verbose 'Cleanup ComObject'
    [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$Shell)
    If ($PSCmdlet.ParameterSetName -eq 'AltShortcut') {
        [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$WShell)
    }
    [gc]::Collect()
    [gc]::WaitForPendingFinalizers()
    Remove-Variable Shell -ErrorAction SilentlyContinue
    Remove-Variable WShell -ErrorAction SilentlyContinue
}