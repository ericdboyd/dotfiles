
# Get the base URI path from the ScriptToCall value
$bstrappackage = "-bootstrapPackage"
$helperUri = $Boxstarter['ScriptToCall']
$strpos = $helperUri.IndexOf($bstrappackage)
$helperUri = $helperUri.Substring($strpos + $bstrappackage.Length)
$helperUri = $helperUri.TrimStart("'", " ")
$helperUri = $helperUri.TrimEnd("'", " ")
$helperUri = $helperUri.Substring(0, $helperUri.LastIndexOf("/"))
$helperUri += "/scripts"
Write-Host "helper script base URI is $helperUri"

function executeScript {
    Param ([string]$script)
    
    Write-Host ""
    Write-Host "Executing $helperUri/$script ..." -ForegroundColor Green
    Write-Host "------------------------------------" -ForegroundColor Green

	Invoke-Expression ((New-Object net.webclient).DownloadString("$helperUri/$script"))
}

function sourceScript {
    Param ([string]$script)

    Write-Host ""
    Write-Host "Sourcing $helperUri/$script ..." -ForegroundColor Green
    Write-Host "------------------------------------" -ForegroundColor Green

    $content = (Invoke-WebRequest -Uri "${helperUri}/${script}").Content
    $scriptBlock = [Scriptblock]::Create($content)
    return $scriptBlock
}

# #--- Setting up Windows ---
# executeScript "SystemConfiguration.ps1";
# executeScript "FileExplorerSettings.ps1";
# executeScript "RemoveDefaultApps.ps1";
# executeScript "CommonDevTools.ps1";

executeScript "Configure-Windows.ps1";

# Configure PSGallery
Install-PackageProvider NuGet -MinimumVersion '2.8.5.201' -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

Install-Module posh-sshell

choco install -y git --package-parameters="'/GitAndUnixToolsOnPath /WindowsTerminal'"

executeScript "Configure-WinGet.ps1";

#Install New apps
Write-Output "Installing Apps"

$appsToInstall = @(
    @{id = "Microsoft.PowerShell" }, 

    @{id = "Microsoft.AzureCLI" }, 
    @{id = "Microsoft.Bicep"},
    @{name = "Azure Functions Core Tools"; id = "Microsoft.Azure.FunctionsCoreTools"},
    @{name = "Azure Cosmos DB Emulator"; id = "Microsoft.Azure.CosmosEmulator"},
    @{name = "Microsoft Azure Storage Explorer"; id = "Microsoft.Azure.StorageExplorer"}, 
    @{name = "Microsoft Azure Storage Emulator"; id = "Microsoft.Azure.StorageEmulator"},
    @{name = "Azure IoT Explorer Preview"; id = "Microsoft.Azure.IoTExplorer"},
    @{id = "Microsoft.AzureDataStudio"},
    @{name = "Azure Data CLI"; id = "Microsoft.Azure.DataCLI"},
    @{name = "Azure Media Services Explorer"; id = "Microsoft.AzureMediaServicesExplorer" },
    @{id = "Microsoft.ServiceFabricRuntime"},
    @{name = "Service Fabric Explorer"; id = "Microsoft.ServiceFabricExplorer"},
    @{name = "Azure Developer CLI"; id = "Microsoft.Azd"},
    @{name = "Azure VPN Client"; id = "9NP355QT2SQB"; source = "msstore" },
    
    @{id = "Microsoft.PowerAutomateDesktop"},
    @{id = "Microsoft.PowerAppsCLI"},

    @{name = "Sysinternals Suite"; id = "9P7KNL5RWT25"; source = "msstore" },
    @{name = "Microsoft.WindowsTerminal"; source = "msstore" },
    @{id = "Microsoft.PowerToys" }, 
    @{id = "GitHub.cli" },
    @{id = "TortoiseGit.TortoiseGit"},
    @{id = "GitHub.GitHubDesktop"},
    @{id = "Atlassian.Sourcetree"},

    @{id = "Docker.DockerDesktop" },    
    @{id = "suse.RancherDesktop"},
    
    @{id = "Wox.Wox"},
    @{id = "gerardog.gsudo"},
    @{id = "QL-Win.QuickLook"},
    @{id = "Bitvise.SSH.Client"},
    @{id = "Microsoft.OpenSSH.Beta"},
    @{id = "Discord.Discord"},
    
    @{id = "Microsoft.VisualStudio.2019.Enterprise"},
    @{id = "Microsoft.VisualStudioCode" }, 
    
    @{id = "JanDeDobbeleer.OhMyPosh"},

    @{name = "Microsoft Teams"; id = "Microsoft.Teams"},

    @{id = "Microsoft.BotFrameworkEmulator"},
    @{id = "Microsoft.BotFrameworkComposer"},

    @{id = "PortSwigger.BurpSuite.Community"},

    @{id = "7zip.7zip"},
    @{id = "Audacity.Audacity"},
    @{id = "ScooterSoftware.BeyondCompare4"},
    @{id = "Dropbox.Dropbox"},
    @{id = "Telerik.Fiddler.Classic"},
    @{id = "Telerik.Fiddler.Everywhere"},
    @{id = "Telerik.Fiddler.Everywhere.Insiders"},
    @{id = "Google.Chrome"},
    @{name = "Mozilla Firefox"; id = "Mozilla.Firefox"},
    @{id = "LogMeIn.LastPass"},
    @{id = "NordVPN"},
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

    @{id = "Microsoft.SQLServerManagementStudio"},
    @{name = "Microsoft SQL Server 2019 Developer"; id = "Microsoft.SQLServer.2019.Developer"},
    @{id = "Microsoft.CLRTypesSQLServer.2019"},

    @{id = "Microsoft.Office"},
    @{id = "Microsoft.OneDrive"},

    @{id = "OBSProject.OBSStudio"},
    
    @{id = "Postman.Postman"},
    @{id = "WiresharkFoundation.Wireshark"},
    @{id = "Flywheel.Local"},
    @{id = "tagspaces.tagspaces"},
    @{id = "Notion.Notion"},
    @{id = "SlackTechnologies.Slack"},

    @{id = "Microsoft.VCRedist.2015+.x64"},
    @{id = "Microsoft.VCRedist.2013.x64"},
    @{id = "Microsoft.VCRedist.2012.x64"},
    @{name = "Microsoft Visual C++ 2010 x64 Redistributable"; id = "Microsoft.VCRedist.2010.x64"},
    @{name = "Microsoft Visual C++ 2008 Redistributable - x64"; id = "Microsoft.VCRedist.2008.x64"},
    @{name = "Microsoft Visual C++ 2005 Redistributable (x64)"; id = "Microsoft.VCRedist.2005.x64"},

    @{id = "Python.Python.2"},
    @{id = "Python.Python.3.11"},
    @{id = "OpenJS.NodeJS.LTS"},
    @{name = "JetBrains ReSharper"; id = "JetBrains.ReSharper"},
    @{id = "JetBrains.Toolbox"},

    @{name = "Unity Hub"; id = "Unity.UnityHub"},
    @{name = "Unity"; id = "Unity.Unity.2020"},
    @{name = "Unity 2021"; id = "Unity.Unity.2021"},
    @{name = "Unity 2022"; id = "Unity.Unity.2022"},

    @{id = "Microsoft.DotNet.SDK.Preview"},
    @{id = "Microsoft.DotNet.SDK.7"},
    @{id = "Microsoft.DotNet.SDK.6"},
    @{id = "Microsoft.DotNet.SDK.5"},
    @{id = "Microsoft.DotNet.SDK.3_1"},
    @{id = "Microsoft.DotNet.Runtime.3_1"},
    @{id = "Microsoft.DotNet.Framework.DeveloperPack_4"},

    @{id = "Microsoft.WebDeploy"},
    @{id = "Microsoft.WindowsSDK"},
    @{id = "Microsoft.webpicmd"},

    @{id = "ShiningLight.OpenSSL"},
    @{id = "Oracle.JavaRuntimeEnvironment"},
    @{id = "Microsoft.WindowsPCHealthCheck"},
    @{id = "mRemoteNG.mRemoteNG"},

    @{name = "Logitech G HUB"; id = "Logitech.GHUB"},
    @{id = "Logitech.CameraSettings"},
    
    @{id = "Microsoft.BingWallpaper"},

    @{id = "TechSmith.Camtasia"},
    @{name = "Snagit 2022"; id = "TechSmith.Snagit.2022"},

    @{name = "Messenger"; source = "msstore"; id = "9WZDNCRF0083"},

    @{name = "The Silver Searcher"},
    
    @{id = "Ghisler.TotalCommander"},
    @{id = "GNU.MidnightCommander"},

    @{name = "Harvest Time Tracker"; id = "9PBLBM45RJQJ"; source = "msstore"}

);

# Failing asking for install location
# @{id = "AutoHotkey.AutoHotkey"},

Foreach ($app in $appsToInstall) {
    $installApp = $true
    if ($null -ne $app.id) {
        Write-Host "Checking:" $app.id
        $listApp = winget list --id $app.id
        if ([String]::Join("", $listApp).Contains($app.id)){
            $installApp = $false
        }
    }
    else {
        Write-Host "Checking:" $app.name
        $listApp = winget list --exact -q $app.name
        if ([String]::Join("", $listApp).Contains($app.name)){
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
        Write-Host "Skipping Install of " $app.name
    }
}

. (sourceScript "Install-WingetAppsFunction.ps1")

$elgatoApps = @(
    @{id = "Elgato.StreamDeck"},
    @{id = "Elgato.ControlCenter"}
)
Install-WingetApps $elgatoApps

$wslDistros = @(
    @{id = "Canonical.Ubuntu.2204"},
    @{name = "openSUSE Leap 15.4"; source = "msstore"},
    @{name = "openSUSE Tumbleweed"; source = "msstore"},
    @{id = "kalilinux.kalilinux"},
    @{id = "Debian.Debian"},
    @{id = "SuperTux.SuperTux"},
    @{id = "whitewaterfoundry.fedora-remix-for-wsl"}
)
Install-WingetApps $wslDistros

# https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-community
# https://docs.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio#list-of-workload-ids-and-component-ids
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

executeScript "Install-HyperV.ps1";
executeScript "Install-WSL.ps1";

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



# ################################################################################
# ### PowerShell                                                                 #
# ################################################################################

# # Link Profile to the one inside this repo.
# if (Test-Path "$profile") { Remove-Item "$profile" }
# New-Item -Path "$profile" -ItemType SymbolicLink -Value "$HOME\.dotfiles\powershell\Microsoft.PowerShell_profile.ps1" -Force

# ################################################################################
# ### Bash                                                                       #
# ################################################################################

# if (Test-Path "$HOME\.bashrc") { Remove-Item "$HOME\.bashrc" }
# New-Item -Path "$HOME\.bashrc" -ItemType SymbolicLink -Value "$HOME\.dotfiles\bash\.bashrc"

# if (Test-Path "$HOME\.bash_profile") { Remove-Item "$HOME\.bash_profile" }
# New-Item -Path "$HOME\.bash_profile" -ItemType SymbolicLink -Value "$HOME\.dotfiles\bash\.bash_profile"

# ################################################################################
# ### NPM                                                                        #
# ################################################################################

# if (Test-Path "$HOME\.npmrc") { Remove-Item "$HOME\.npmrc" }
# New-Item -Path "$HOME\.npmrc" -ItemType SymbolicLink -Value "$HOME\.dotfiles\node\.npmrc"

#Remove Apps
Write-Output "Removing Apps"

# $apps = "*3DPrint*", "Microsoft.MixedReality.Portal"
# $appsToRemove = $null
# Foreach ($app in $appsToRemove)
# {
#   Write-Host "Uninstalling:" $app
#   Get-AppxPackage -allusers $app | Remove-AppxPackage
# }

executeScript "scripts/Remove-DesktopShortcuts.ps1"