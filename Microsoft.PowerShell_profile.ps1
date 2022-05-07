Import-Module posh-git
Import-Module ZLocation
oh-my-posh init pwsh --config ~/.posh-theme.json | Invoke-Expression

# PSReadline Options
Set-PSReadlineOption -EditMode vi
# Set-PSReadlineOption -ViModeIndicator Script -ViModeChangeHandler {
#     Param($mode)
#     $Env:SHELL_VI_MODE = $mode
# }
#Set-PSReadlineOption -ViModeIndicator Prompt
#Set-PSReadlineOption -ViModeIndicator Cursor

# posh-git settings
$global:GitPromptSettings.AutoRefreshIndex = $false

# Emacs-like Keybindings
Set-PSReadLineKeyHandler -Chord Ctrl-a -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition(0) }
Set-PSReadLineKeyHandler -Chord Ctrl-e -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition([Int32]::MaxValue) }
# Additional Keybindings for vi EditMode
Set-PSReadLineKeyHandler -Chord "Ctrl+[" -ScriptBlock { [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition(0) }

# Fzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
Set-PsFzfOption -TabExpansion

# Neovim aliases
if (Get-Command nvim -ErrorAction Ignore) {
    Set-Alias vim nvim
    Set-Alias vi nvim
}

if (Test-Path ~/.profile.mine.ps1) {
    . ~/.profile.mine.ps1
    Write-Output "Local profile has been loaded: ~/.profile.mine.ps1"
}
