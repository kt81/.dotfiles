#!/usr/bin/env pwsh

# Only works on PowerShell Core

$repoRoot = $PSScriptRoot
$linuxXdgData = ([string]::IsNullOrEmpty($env:XDG_DATA_HOME) ? "$HOME/.local/share" : $env:XDG_DATA_HOME);
$linuxXdgConfig = ([string]::IsNullOrEmpty($env:XDG_CONFIG_HOME) ? "$HOME/.config" : $env:XDG_CONFIG_HOME);

function task {
    param($message)
    Write-Host -ForegroundColor Green "$message"
}
function skip {
    param($message)
    Write-Host -ForegroundColor DarkGray "$message"
}

function doTested {
    param(
        [scriptblock] $TestScript,
        [scriptblock] $DoScript,
        [string] $SkippedResultMessage = "Skipped."
    )
    $result = ($TestScript.Invoke()) -and ($DoScript.Invoke())
    if ($result) {
        Return $result
    } else {
        skip $SkippedResultMessage
    }
}
function linkNx {
    param(
        [string] $DestinationPath,
        [string] $FromPath,
        [string] $SkippedResultMessage = "File exists.",
        [bool] $NoDirCreation = $false,
        [bool] $IsFullPath = $false
    )
    if (!$IsFullPath) {
        $FromPath = Join-Path $repoRoot $FromPath
    }
    task "Linking: $FromPath -> $DestinationPath"
    $destDir = Split-Path $DestinationPath
    $name = Split-Path -Leaf $DestinationPath
    if (!$NoDirCreation -and !(Test-Path $destDir)) {
        New-Item -ItemType Directory $destDir
    }
    
    $result = doTested {!(Test-Path $DestinationPath)} {New-Item -ItemType SymbolicLink -Path $destDir -Name $name -Target $FromPath }
    if ($result) {
        Write-Host -ForegroundColor Blue "Link created."
    }
}

if ($IsWindows) {
    # Admin privilege is required in Windows to create symlinks (if not in dev mode)
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Error "Please run this script as Admin." -Category PermissionDenied
        Exit 1
    }

    Write-Host -ForegroundColor Green 'Enabling windows feature: Japanese Fonts'
    DISM.exe /Online /Add-Capability /CapabilityName:Language.Fonts.Jpan~~~und-JPAN~0.0.1.0

    if (!(Get-Command code -ErrorAction SilentlyContinue)) {
        Write-Host -ForegroundColor Green -Object 'Installing Visual Studio Code'
        Invoke-Expression (Invoke-WebRequest https://raw.githubusercontent.com/PowerShell/vscode-powershell/master/scripts/Install-VSCode.ps1)
    }
}

task "Installing: posh-git"
doTested {!(Get-Module -ListAvailable posh-git)} {Install-Module posh-git -Scope CurrentUser -Force}
task "Installing: oh-my-posh"
doTested {!(Get-Module -ListAvailable oh-my-posh)} {Install-Module oh-my-posh -AllowPrerelease -Scope CurrentUser -Force}
task "Installing: PSReadLine"
doTested {!(Get-Module -ListAvailable PSReadLine)} {Install-Module -Name PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck}
task "Installing: PSFzf"
doTested {!(Get-Module -ListAvailable PSFzf)} {Install-Module -Name PSFzf -Scope CurrentUser -Force}


task "Creating symbolic links for various settings."
$psProfile = "Microsoft.PowerShell_profile.ps1"
if ($IsWindows) {
    $psProfileDest = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "PowerShell" $psProfile
} else {
    $psProfileDest = Join-Path $linuxXdgConfig "powershell" $psProfile
}
linkNx $psProfileDest $psProfile
linkNx ~/.posh-theme.json .posh-theme.json
linkNx ~/.vimrc .vimrc

if ($IsWindows) {
    $nvimInitPath = Join-Path $env:LOCALAPPDATA "/nvim/init.vim"
} else {
    $nvimInitPath = Join-Path $linuxXdgConfig "/nvim/init.vim"
}
linkNx $nvimInitPath .vimrc
#linkNx ~/.tmux.conf .tmux.conf

task "Installing: vim-plug"
$plugInstalled = $false
if ($IsWindows) {
    $nvimAlPath = "$env:LOCALAPPDATA/nvim-data/site/autoload/plug.vim";
    $vimAlPath = "$HOME/vimfiles/autoload/plug.vim"
} else {
    $nvimAlPath = $linuxXdgData + "/nvim/site/autoload/plug.vim"
    $vimAlPath = "$HOME/.vim/autoload/plug.vim"
}
if (!(Test-Path $nvimAlPath)) {
    Invoke-WebRequest -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
        New-Item $nvimAlPath -Force
    nvim --headless +PlugInstall +qall
    $plugInstalled = $true
}
if ((Get-Command vim -ErrorAction SilentlyContinue) -and !(Test-Path $vimAlPath)) {
    New-Item -ItemType File $vimAlPath -Force
    Copy-Item $nvimAlPath $vimAlPath -Force
    vim +'PlugInstall --sync' +qa
    $plugInstalled = $true
}
if (!$plugInstalled) {
    skip "vim-plug has already been installed."
}

Write-Host -ForegroundColor Yellow -Object "Done!!!"

#[ ! -e ~/.zshrc ] && ln -s ~/.common_conf/.zshrc ~/.zshrc
