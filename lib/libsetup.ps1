
function Upstall-WingetPackage {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string] $Id,
        [Parameter(Mandatory=$false, Position=1)]
        [string] $Store = $null
    )

    $test= {
        winget list -e --id $Id
        $LASTEXITCODE -eq 0
    }
    if ($Store) {
        $run = {
            param($SubCmd)
            winget $SubCmd -e -s $Store --id $Id --accept-package-agreements
        }
    } else {
        $run = {
            param($SubCmd)
            winget $SubCmd -e --id $Id --accept-package-agreements
        }
    }

    if (!(Invoke-Command $test | Select-Object -Last 1)) {
        Invoke-Command $run -ArgumentList @("install")
    } else {
        Invoke-Command $run -ArgumentList @("upgrade")
    }
}