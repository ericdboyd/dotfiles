
Write-Host "Boxstarter[ScriptToCall]"
Write-Host $Boxstarter['ScriptToCall']

Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions

Enable-RemoteDesktop

Install-PackageProvider NuGet -MinimumVersion '2.8.5.201' -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

Install-Module posh-sshell

choco install -y git --package-parameters="'/GitAndUnixToolsOnPath /WindowsTerminal'"

#Install WinGet
#Based on this gist: https://gist.github.com/crutkas/6c2096eae387e544bd05cde246f23901
$hasPackageManager = Get-AppPackage -name 'Microsoft.DesktopAppInstaller'
if (!$hasPackageManager -or [version]$hasPackageManager.Version -lt [version]"1.10.0.0") {
    "Installing winget Dependencies"
    
    Add-AppxPackage -Path 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'
    
    # Microsoft.UI.Xaml.2.7_7.2109.13004.0_x64__8wekyb3d8bbwe.Appx
    Add-AppxPackage -Path 'http://tlu.dl.delivery.mp.microsoft.com/filestreamingservice/files/de44abf4-d2ba-4197-a139-85c485d58e0b?P1=1678125670&P2=404&P3=2&P4=D8ZIcnWwi0tKLRmbXqkj4WoM%2fqyYaq4KOo%2b38lxAlh6FPPsZPxlbIj%2fxgmkyOcgRLX3iKufakQCaAzyff3TiUA%3d%3d'
    

    $releases_url = 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $releases = Invoke-RestMethod -uri $releases_url
    $latestRelease = $releases.assets | Where { $_.browser_download_url.EndsWith('msixbundle') } | Select -First 1

    "Installing winget from $($latestRelease.browser_download_url)"
    Add-AppxPackage -Path $latestRelease.browser_download_url
}
else {
    "winget already installed"
}

#Configure WinGet
Write-Output "Configuring winget"

#winget config path from: https://github.com/microsoft/winget-cli/blob/master/doc/Settings.md#file-location
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json";
$settingsJson = 
@"
    {
        // For documentation on these settings, see: https://aka.ms/winget-settings
        "experimentalFeatures": {
          "experimentalMSStore": true,
        }
    }
"@;
# $settingsJson | Out-File $settingsPath -Encoding utf8

winget settings --enable InstallerHashOverride 

#Install New apps
Write-Output "Installing Apps"

$appsToInstall = @(
    @{name = "Microsoft.PowerShell" }, 

    @{name = "Microsoft.AzureCLI" }, 
    @{name = "Microsoft.Bicep"},
    @{name = "Azure Functions Core Tools"; id = "Microsoft.Azure.FunctionsCoreTools"},
    @{name = "Azure Cosmos DB Emulator"; id = "Microsoft.Azure.CosmosEmulator"},
    @{name = "Microsoft Azure Storage Explorer"; id = "Microsoft.Azure.StorageExplorer"}, 
    @{name = "Microsoft Azure Storage Emulator"; id = "Microsoft.Azure.StorageEmulator"},
    @{name = "Azure IoT Explorer Preview"; id = "Microsoft.Azure.IoTExplorer"},
    @{name = "Microsoft.AzureDataStudio"},
    @{name = "Azure Data CLI"; id = "Microsoft.Azure.DataCLI"},
    @{name = "Azure Media Services Explorer"; id = "Microsoft.AzureMediaServicesExplorer" },
    @{name = "Microsoft.ServiceFabricRuntime"},
    @{name = "Service Fabric Explorer"; id = "Microsoft.ServiceFabricExplorer"},
    @{name = "Azure Developer CLI"; id = "Microsoft.Azd"},
    @{name = "Azure VPN Client"; id = "9NP355QT2SQB"; source = "msstore" },
    
    @{name = "Microsoft.PowerAutomateDesktop"},
    @{name = "Microsoft.PowerAppsCLI"},

    @{name = "Sysinternals Suite"; id = "9P7KNL5RWT25"; source = "msstore" },
    @{name = "Microsoft.WindowsTerminal"; source = "msstore" },
    @{name = "Microsoft.PowerToys" }, 
    @{name = "GitHub.cli" },
    @{name = "TortoiseGit.TortoiseGit"},
    @{name = "GitHub.GitHubDesktop"},
    @{name = "Atlassian.Sourcetree"},

    @{name = "Docker.DockerDesktop" },
    @{id = "Canonical.Ubuntu"},
    @{name = "Canonical.Ubuntu.2204"},
    @{name = "openSUSE Leap 15.4"; source = "msstore"},
    @{name = "openSUSE Tumbleweed"; source = "msstore"},
    @{name = "kalilinux.kalilinux"},
    @{name = "Debian.Debian"},
    @{name = "SuperTux.SuperTux"},
    @{name = "whitewaterfoundry.fedora-remix-for-wsl"},
    @{name = "suse.RancherDesktop"},
    
    @{name = "Wox.Wox"},
    @{name = "gerardog.gsudo"},
    @{name = "AutoHotkey.AutoHotkey"},
    @{name = "QL-Win.QuickLook"},
    @{name = "Bitvise.SSH.Client"},
    @{name = "Microsoft.OpenSSH.Beta"},
    @{name = "Discord.Discord"},
    
    @{name = "Microsoft.VisualStudio.2019.Enterprise"},
    @{name = "Microsoft.VisualStudioCode" }, 
    
    @{name = "JanDeDobbeleer.OhMyPosh"},

    @{name = "Microsoft Teams"; id = "Microsoft.Teams"},

    @{name = "Microsoft.BotFrameworkEmulator"},
    @{name = "Microsoft.BotFrameworkComposer"},

    @{name = "PortSwigger.BurpSuite.Community"},

    @{name = "7zip.7zip"},
    @{name = "Audacity.Audacity"},
    @{name = "ScooterSoftware.BeyondCompare4"},
    @{name = "Dropbox.Dropbox"},
    @{name = "Telerik.Fiddler.Classic"},
    @{name = "Google.Chrome"},
    @{name = "Mozilla Firefox"; id = "Mozilla.Firefox"},
    @{name = "LogMeIn.LastPass"},
    @{name = "NordVPN"},
    @{name = "Discord"; id = "Discord.Discord"},
    @{name = "WhatsApp"; id = "WhatsApp.WhatsApp"},
    
    @{name = "Microsoft Edge Dev"; id = "Microsoft.Edge.Dev"},
    @{name = "Microsoft Edge Beta"; id = "Microsoft.Edge.Beta"},
    @{name = "Microsoft Edge Canary"; id = "Microsoft.Edge.Canary"},
    
    @{name = "Kubernetes - Minikube - A Local Kubernetes Development Environment"; id = "Kubernetes.minikube"},
    @{name = "kubectl"; id = "Kubernetes.kubectl"},
    @{name = "kompose"; id = "Kubernetes.kompose"},
    @{name = "Helm"; id = "Helm.Helm"},
    
    @{name = "Microsoft Azure Kubelogin"; id = "Microsoft.Azure.Kubelogin"},
    @{name = "Azure Terrafy"; id = "Microsoft.Azure.Aztfy"},
    @{name = "AzCopy v10"; id = "Microsoft.Azure.AZCopy.10"},

    @{name = "Microsoft.SQLServerManagementStudio"},
    @{name = "Microsoft SQL Server 2019 Developer"; id = "Microsoft.SQLServer.2019.Developer"},
    @{name = "Microsoft.CLRTypesSQLServer.2019"},

    @{name = "Microsoft.Office"},
    @{name = "Microsoft.OneDrive"},

    @{name = "OBSProject.OBSStudio"},
    
    @{name = "Postman.Postman"},
    @{name = "WiresharkFoundation.Wireshark"},
    @{name = "Flywheel.Local"},
    @{name = "tagspaces.tagspaces"},
    @{name = "Notion.Notion"},
    @{name = "SlackTechnologies.Slack"},

    @{name = "Microsoft.VCRedist.2015+.x64"},
    @{name = "Microsoft.VCRedist.2013.x64"},
    @{name = "Microsoft.VCRedist.2012.x64"},
    @{name = "Microsoft Visual C++ 2010 x64 Redistributable"; id = "Microsoft.VCRedist.2010.x64"},
    @{name = "Microsoft Visual C++ 2008 Redistributable - x64"; id = "Microsoft.VCRedist.2008.x64"},
    @{name = "Microsoft Visual C++ 2005 Redistributable (x64)"; id = "Microsoft.VCRedist.2005.x64"},

    @{name = "Python.Python.2"},
    @{name = "Python.Python.3.11"},
    @{name = "OpenJS.NodeJS.LTS"},
    @{name = "JetBrains ReSharper"; id = "JetBrains.ReSharper"},
    @{name = "JetBrains.Toolbox"},

    @{name = "Unity Hub"; id = "Unity.UnityHub"},
    @{name = "Unity"; id = "Unity.Unity.2020"},
    @{name = "Unity 2021"; id = "Unity.Unity.2021"},
    @{name = "Unity 2022"; id = "Unity.Unity.2022"},

    @{name = "Microsoft.DotNet.SDK.Preview"},
    @{name = "Microsoft.DotNet.SDK.7"},
    @{name = "Microsoft.DotNet.SDK.6"},
    @{name = "Microsoft.DotNet.SDK.5"},
    @{name = "Microsoft.DotNet.SDK.3_1"},
    @{name = "Microsoft.DotNet.Runtime.3_1"},
    @{name = "Microsoft.DotNet.Framework.DeveloperPack_4"},

    @{name = "Microsoft.WebDeploy"},
    @{name = "Microsoft.WindowsSDK"},
    @{name = "Microsoft.webpicmd"},

    @{name = "ShiningLight.OpenSSL"},
    @{name = "Oracle.JavaRuntimeEnvironment"},
    @{name = "Microsoft.WindowsPCHealthCheck"},
    @{name = "mRemoteNG.mRemoteNG"},

    @{name = "Elgato.StreamDeck"},
    @{name = "Elgato.ControlCenter"},

    @{name = "Logitech G HUB"; id = "Logitech.GHUB"},
    @{name = "Logitech.CameraSettings"},
    
    @{name = "Microsoft.BingWallpaper"},

    @{name = "TechSmith.Camtasia"},
    @{name = "Snagit 2022"; id = "TechSmith.Snagit.2022"},

    @{name = "Messenger"; source = "msstore"; id = "9WZDNCRF0083"},

    @{name = "The Silver Searcher"},
    
    @{name = "Ghisler.TotalCommander"},
    @{name = "GNU.MidnightCommander"}

);
Foreach ($app in $appsToInstall) {
    $installApp = $true
    if ($null -ne $app.id) {
        Write-host "Checking:" $app.id
        $listApp = winget list --id $app.id
        if ([String]::Join("", $listApp).Contains($app.id)){
            $installApp = $false
        }
    }
    else {
        Write-host "Checking:" $app.name
        $listApp = winget list --exact -q $app.name
        if ([String]::Join("", $listApp).Contains($app.name)){
            $installApp = $false
        }
    }
    
    if ($installApp) {
        Write-host "Installing:" $app.name "-" $app.id "-" $app.source
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
        Write-host "Skipping Install of " $app.name
    }
}

winget install --id Microsoft.VisualStudio.2022.Enterprise --override "--quiet --add Microsoft.Visualstudio.Workload.Azure;includeRecommended;includeOptional --add Microsoft.VisualStudio.Workload.Data;includeRecommended;includeOptional --add Microsoft.VisualStudio.Workload.DataScience;includeRecommended;includeOptional --add Microsoft.VisualStudio.Workload.ManagedDesktop;includeRecommended;includeOptional --add Microsoft.VisualStudio.Workload.ManagedGame;includeRecommended;includeOptional -add Microsoft.VisualStudio.Workload.NetCrossPlat;includeRecommended;includeOptional -add Microsoft.VisualStudio.Workload.NetWeb;includeRecommended;includeOptional -add Microsoft.VisualStudio.Workload.Node;includeRecommended;includeOptional -add Microsoft.VisualStudio.Workload.Python;includeRecommended;includeOptional -add Microsoft.VisualStudio.Workload.Universal;includeRecommended;includeOptional"

# FileZilla isn't available in winget because it's can't be redistributed
choco install filezilla
# Spotify doesn't install in elevated mode in winget
choco install spotify
choco install cascadia-code-nerd-font

# Install-Module -AllowClobber Get-ChildItemColor
Install-Module -Name PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

# -----------------------------------------------------------------------------
# Install dotnet sdk
Write-Host "Installing dotnet SDKs for Windows..." -ForegroundColor Green
powershell -NoProfile -ExecutionPolicy unrestricted -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; &([scriptblock]::Create((Invoke-WebRequest -UseBasicParsing 'https://dot.net/v1/dotnet-install.ps1'))) -Channel LTS"
Enable-WindowsOptionalFeature -Online -FeatureName NetFx3

# Install Hyper-V
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Tools-All

# -----------------------------------------------------------------------------
# Install WSL
Write-Host ""
Write-Host "Installing WSL..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
Enable-WindowsOptionalFeature -FeatureName Containers -Online -NoRestart

wsl --set-default-version 2

# Configure Git
# Permanently add C:\Program Files\Git\usr\bin to machine Path variable
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Git\usr\bin", "Machine")

# Generate the key and put into the your user profile .ssh directory
ssh-keygen -t rsa -b 4096 -C "$gitEmail" -f $env:USERPROFILE\.ssh\id_rsa

# Copy the public key. Be sure to copy the .pub for the public key
Get-Content $env:USERPROFILE\.ssh\id_rsa.pub | clip

# python
# Update pip
python -m pip install --upgrade pip

# Install ML related python packages through pip
pip install numpy
pip install scipy
pip install pandas
pip install matplotlib
pip install tensorflow
pip install keras

#--- Enable developer mode on the system ---
Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock -Name AllowDevelopmentWithoutDevLicense -Value 1

#Remove Apps
Write-Output "Removing Apps"

# $apps = "*3DPrint*", "Microsoft.MixedReality.Portal"
# $appsToRemove = $null
# Foreach ($app in $appsToRemove)
# {
#   Write-host "Uninstalling:" $app
#   Get-AppxPackage -allusers $app | Remove-AppxPackage
# }

