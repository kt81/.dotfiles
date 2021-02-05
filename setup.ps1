# for windows (PowerShell 5.1 <=)

$repoRoot = $PSScriptRoot

if ($IsLinux -or $IsMacOS) {
    # There's no $IsWindows definition on old PowerShell
    Write-Error "This script should be run on Windows only." -Category InvalidOperation
    Exit 1
}

# Check privilege
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Please run this script as Admin." -Category PermissionDenied
    Exit 1
}

if (!(Get-Command choco -ErrorAction SilentlyContinue) -and !(Get-Command scoop -ErrorAction SilentlyContinue)) {
    # prefer chocolatey
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

if (Get-COmmand choco -ErrorAction SilentlyContinue) {
    # Essentials
    choco install -y git git-lfs 7zip dotnet-sdk pwsh gsudo openssh make
    # Util
    choco install -y `
        ctrl2cap fd fzf ripgrep ntop.portable bottom`
        shellcheck `
        font-hackgen font-hackgen-nerd `
        microsoft-windows-terminal
    # Pre packages
    choco install -y --pre neovim

    $pwsh = "C:\Program Files\PowerShell\7\pwsh.exe"
    & $pwsh $repoRoot\git.ps1 
    & $pwsh $repoRoot\setup.core.ps1
}
