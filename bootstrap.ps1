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

. (sourceScript "functions/Set-PathVariable.ps1")

# #--- Setting up Windows ---
# executeScript "SystemConfiguration.ps1";
# executeScript "FileExplorerSettings.ps1";
# executeScript "RemoveDefaultApps.ps1";
# executeScript "CommonDevTools.ps1";

executeScript "Configure-Windows.ps1";
executeScript "Configure-Power.ps1";

# Configure PSGallery
Install-PackageProvider NuGet -MinimumVersion '2.8.5.201' -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# PowerShellGet. Do this early as reboots are required
if (-not (Get-InstalledModule -Name PowerShellGet -ErrorAction SilentlyContinue)) {
    Write-Host "Install-Module PowerShellGet"
    Install-Module -Name "PowerShellGet" -AllowClobber -Force -Scope AllUsers

    # Exit equivalent
    Invoke-Reboot
}

. (sourceScript "functions/Install-WingetApps.ps1")

$terminalAppsToInstall = @(
    
    @{id = "Microsoft.PowerShell" },     
    @{name = "Microsoft.WindowsTerminal"; source = "msstore" }
)
Install-WingetApps $terminalAppsToInstall

choco install cascadia-code-nerd-font
choco install -y git --package-parameters="'/GitAndUnixToolsOnPath /WindowsTerminal'"


Install-Module z -Force -Scope CurrentUser
Install-Module posh-git -Force -Scope CurrentUser
Install-Module Get-ChildItemColor -Force -Scope CurrentUser
Install-Module -Name PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck
Install-Module -Name Terminal-Icons -Repository PSGallery -Force -Scope CurrentUser

# PowerShell SSH connection manager
Install-Module posh-sshell

executeScript "Configure-WinGet.ps1";

#Install New apps
Write-Output "Installing Apps"

$appsToInstall = @(

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
    @{id = "Microsoft.Azure.AztfExport"},
    
    @{id = "Microsoft.PowerAutomateDesktop"},
    @{id = "Microsoft.PowerAppsCLI"},

    @{name = "Sysinternals Suite"; id = "9P7KNL5RWT25"; source = "msstore" },
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
    @{name = "DisplayLink Manager"; id = "9N09F8V8FS02"; source = "msstore" },
    @{name = "Lenovo Commercial Vantage"; id = "9NR5B8GVVM13"; source = "msstore"},
    
    @{id = "Microsoft.VisualStudio.2019.Enterprise"},
    # @{id = "Microsoft.VisualStudioCode" }, 
    # @{id = "Microsoft.VisualStudioCode.Insiders" },

    @{id = "Insomnia.Insomnia"},
    @{id = "AutoHotkey.AutoHotkey"},
    
    @{id = "JanDeDobbeleer.OhMyPosh"},

    @{name = "Microsoft Teams"; id = "Microsoft.Teams"},

    @{id = "Microsoft.BotFrameworkEmulator"},
    @{id = "Microsoft.BotFrameworkComposer"},

    @{id = "PortSwigger.BurpSuite.Community"},
    @{id = "PortSwigger.BurpSuite.Professional"},

    @{id = "7zip.7zip"},
    @{id = "Audacity.Audacity"},
    @{id = "ScooterSoftware.BeyondCompare4"},
    @{id = "Dropbox.Dropbox"},
    @{id = "Telerik.Fiddler.Classic"},
    @{id = "Telerik.Fiddler.Everywhere"},
    @{id = "Telerik.Fiddler.Everywhere.Insiders"},
    @{id = "Google.Chrome"},
    @{name = "Mozilla Firefox"; id = "Mozilla.Firefox"},
    # @{id = "LogMeIn.LastPass"},
    @{name = "LastPass"; id = "LastPass.LastPass"},
    @{id = "NordVPN"},
    @{name = "Discord"; id = "Discord.Discord"},
    @{name = "WhatsApp"; id = "WhatsApp.WhatsApp"},
    @{name = "Zoom"; id = "Zoom.Zoom"},
    
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
    @{id = "Microsoft.CLRTypesSQLServer.2019"},

    @{name = "Microsoft 365 (Office)"; id = "9WZDNCRD29V9"; source = "msstore" },
    @{id = "Microsoft.Office"},
    @{id = "Microsoft.OneDrive"},
    @{name = "OneNote"; id = "XPFFZHVGQWWLHB"; source = "msstore" },
    @{name = "OneNote for Windows 10"; id = "9WZDNCRFHVJL"; source = "msstore" },

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
    @{name = "Visual Studio BuildTools 2022"; id = "Microsoft.VisualStudio.2022.BuildTools"},
    @{name = "Visual Studio BuildTools 2019"; id = "Microsoft.VisualStudio.2019.BuildTools"},    

    @{id = "Python.Python.3.9"},
    @{id = "Python.Python.3.10"},
    @{id = "Python.Python.3.11"},
    @{id = "Python.Python.3.12"},
    @{id = "Python.Python.3.13"},
    @{id = "Anaconda.Anaconda3"},

    @{id = "OpenJS.NodeJS.LTS"},
    # @{name = "JetBrains ReSharper"; id = "JetBrains.ReSharper"},
    @{id = "JetBrains.Toolbox"},

    @{name = "Unity Hub"; id = "Unity.UnityHub"},
    @{name = "Unity"; id = "Unity.Unity.2020"},
    @{name = "Unity 2021"; id = "Unity.Unity.2021"},
    @{name = "Unity 2022"; id = "Unity.Unity.2022"},

    @{id = "Microsoft.DotNet.SDK.Preview"},
    # @{id = "Microsoft.DotNet.SDK.7"},
    # @{id = "Microsoft.DotNet.SDK.6"},
    # @{id = "Microsoft.DotNet.SDK.5"},
    # @{id = "Microsoft.DotNet.SDK.3_1"},
    @{id = "Microsoft.DotNet.Runtime.3_1"},
    # @{id = "Microsoft.DotNet.Runtime.5"},
    # @{id = "Microsoft.DotNet.Runtime.6"},
    # @{id = "Microsoft.DotNet.Runtime.7"},
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
    @{name = "Logi Options+"; id = "Logitech.OptionsPlus"},
    @{name = "Logitech Options"; id = "Logitech.Options"},
    @{id = "Logitech.UnifyingSoftware"},
    @{id = "Logitech.LogiBolt"},
    @{id = "Logitech.LogiTune"},
    @{id = "Logitech.Presentation"},
    
    @{id = "Microsoft.BingWallpaper"},

    @{id = "TechSmith.Camtasia"},
    @{name = "Snagit 2022"; id = "TechSmith.Snagit.2022"},

    @{name = "Messenger"; source = "msstore"; id = "9WZDNCRF0083"},

    @{name = "The Silver Searcher"},
    
    @{id = "Ghisler.TotalCommander"},
    @{id = "GNU.MidnightCommander"},

    @{name = "Harvest Time Tracker"; id = "9PBLBM45RJQJ"; source = "msstore"},
    @{name = "NuGet Package Explorer"; id = "9WZDNCRDMDM3"; source = "msstore"},

    @{name = "Adobe Creative Cloud"; id = "XPDLPKWG9SW2WD"; source="msstore"},
    @{name = "Windows IoT Remote Client"; id="9NBLGGH5MNXZ"; source="msstore"},
    @{name = "OpenVPN"; id = "OpenVPNTechnologies.OpenVPN"},
    @{name = "Microsoft Remote Desktop"; id = "9WZDNCRFJ3PS"; source = "msstore"},
    @{name = "Spicetify"; id = "Spicetify.Spicetify"},
    @{id = "Hashicorp.Terraform"},
    @{id = "Microsoft.PowerBI"},
    @{id = "Google.Drive"},
    @{name = "Microsoft Hololens"; id = "9NBLGGH4QWNX"; source = "msstore"},
    @{id = "Grammarly.Grammarly"},
    @{id = "AstroComma.AstroGrep"},
    @{name = "Dev Home (Preview)"; id = "Microsoft.DevHome"},
    @{name = "Dev Home GitHub Extension (Preview)"; id = "9NZCC27PR6N6"; source = "msstore"},
    @{name = "Dev Home Azure Extension (Preview)"; id = "9MV8F79FGXTR"; source = "msstore"},

    @{id = "Ultimaker.Cura"},
    @{id = "fzf"},
    @{name = "Microsoft To Do: Lists, Tasks & Reminders"; id = "9NBLGGH5R558"; source = "msstore"},
    @{name = "Microsoft Whiteboard"; id = "9MSPC6MP8FM4"; source = "msstore"},
    @{name = "Microsoft Promptflow"; id = "Microsoft.Promptflow" }
);

Install-WingetApps $appsToInstall

winget install --force Microsoft.VisualStudioCode --override '/VERYSILENT /SP- /MERGETASKS="!runcode,!desktopicon,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"'
winget install --force Microsoft.VisualStudioCode.Insiders --override '/VERYSILENT /SP- /MERGETASKS="!runcode,!desktopicon,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"'


# gh extensions
gh extension install github/gh-copilot
gh extension install mislav/gh-branch
gh extension install redraw/gh-install
gh extension install k1LoW/gh-grep

# Failing asking for install location
# @{id = "AutoHotkey.AutoHotkey"},

$elgatoApps = @(
    @{id = "Elgato.StreamDeck"},
    @{id = "Elgato.ControlCenter"},
    @{id = "Elgato.CameraHub"}
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

winget install --silent --id "Microsoft.SQLServer.2022.Developer" --override ' /INSTANCENAME="MSSQLSERVER01"' --accept-package-agreements --accept-source-agreements --ignore-security-hash

# https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-community
# https://docs.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio#list-of-workload-ids-and-component-ids
winget install --id Microsoft.VisualStudio.2022.Enterprise --override "--quiet --add Microsoft.Visualstudio.Workload.Azure;includeRecommended;includeOptional --add Microsoft.VisualStudio.Workload.Data;includeRecommended;includeOptional --add Microsoft.VisualStudio.Workload.DataScience;includeRecommended;includeOptional --add Microsoft.VisualStudio.Workload.ManagedDesktop;includeRecommended;includeOptional --add Microsoft.VisualStudio.Workload.ManagedGame;includeRecommended;includeOptional -add Microsoft.VisualStudio.Workload.NetCrossPlat;includeRecommended;includeOptional -add Microsoft.VisualStudio.Workload.NetWeb;includeRecommended;includeOptional -add Microsoft.VisualStudio.Workload.Node;includeRecommended;includeOptional -add Microsoft.VisualStudio.Workload.Python;includeRecommended;includeOptional -add Microsoft.VisualStudio.Workload.Universal;includeRecommended;includeOptional"
winget install --id Microsoft.VisualStudio.2022.Enterprise.Preview --override "--quiet --add Microsoft.Visualstudio.Workload.Azure;includeRecommended;includeOptional --add Microsoft.VisualStudio.Workload.Data;includeRecommended;includeOptional --add Microsoft.VisualStudio.Workload.DataScience;includeRecommended;includeOptional --add Microsoft.VisualStudio.Workload.ManagedDesktop;includeRecommended;includeOptional --add Microsoft.VisualStudio.Workload.ManagedGame;includeRecommended;includeOptional -add Microsoft.VisualStudio.Workload.NetCrossPlat;includeRecommended;includeOptional -add Microsoft.VisualStudio.Workload.NetWeb;includeRecommended;includeOptional -add Microsoft.VisualStudio.Workload.Node;includeRecommended;includeOptional -add Microsoft.VisualStudio.Workload.Python;includeRecommended;includeOptional -add Microsoft.VisualStudio.Workload.Universal;includeRecommended;includeOptional"



Install-Module Az -AllowClobber
Install-Module Microsoft.Graph
Install-Module Az.Tools.Migration

# FileZilla isn't available in winget because it's can't be redistributed
choco install filezilla

# Used to pin apps to the taskbar
choco install syspin

# Spotify doesn't install in elevated mode in winget
choco install spotify --force

choco install mysql.workbench

# Install-Module Get-ChildItemColor -AllowClobber
# Install-Module -Name PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck
# Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

# -----------------------------------------------------------------------------
# Install dotnet sdk
Write-Host "Installing dotnet SDKs for Windows..." -ForegroundColor Green
powershell -NoProfile -ExecutionPolicy unrestricted -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; &([scriptblock]::Create((Invoke-WebRequest -UseBasicParsing 'https://dot.net/v1/dotnet-install.ps1'))) -Channel LTS"
Enable-WindowsOptionalFeature -Online -FeatureName NetFx3

executeScript "Install-HyperV.ps1";
executeScript "Install-WSL.ps1";

# Configure Git
# Permanently add C:\Program Files\Git\usr\bin to machine Path variable
# [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Git\usr\bin", "Machine")

Set-PathVariable -AddPath "C:\Program Files\Git\usr\bin" -Scope "Machine"


$pythonPath = (py -c "import os, sys; print(os.path.dirname(sys.executable))")
Set-PathVariable -AddPath $pythonPath -Scope "Machine"


# python
# Update pip
py -m pip install --upgrade pip

# Install ML related python packages through pip
# py -m pip install numpy
# py -m pip install scipy
# py -m pip install pandas
# py -m pip install matplotlib
# py -m pip install tensorflow
# py -m pip install keras
# py -m pip install scikit-learn
# py -m pip install pytorch
# py -m pip install scrapy
# py -m pip install beautifulsoup4
# py -m pip install lightgbm
# py -m pip install Theano
# py -m pip install ramp
# py -m pip install pipenv
# py -m pip install bob
# py -m pip install pybrain
# py -m pip install seaborn
# py -m pip install plotly
# py -m pip install dask
# py -m pip install mahotas
# py -m pip install pytest
# py -m pip install xgboost

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