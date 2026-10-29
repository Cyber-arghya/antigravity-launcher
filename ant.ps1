<#
.SYNOPSIS
    Antigravity IDE PowerShell Integration.
.DESCRIPTION
    Provides the Open-Antigravity function and registers the 'ant' alias.
    Works seamlessly with 'ant .', 'ant -n .', or 'ant "path"'.
#>

function Open-Antigravity {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Path = ".",

        [Alias("n")]
        [switch]$NewWindow
    )

    # 1. Resolve full path
    try {
        $resolvedPath = (Resolve-Path -LiteralPath $Path -ErrorAction Stop).Path
    } catch {
        Write-Error "Path not found: $Path"
        return
    }

    # 2. Check if antigravity-ide is directly in PATH
    $cmd = Get-Command antigravity-ide -ErrorAction SilentlyContinue
    if ($cmd) {
        $exe = $cmd.Source
    } else {
        $searchPaths = @(
            "$env:LOCALAPPDATA\Programs\Antigravity IDE\bin\antigravity-ide.cmd",
            "$env:ProgramFiles\Antigravity IDE\bin\antigravity-ide.cmd",
            "${env:ProgramFiles(x86)}\Antigravity IDE\bin\antigravity-ide.cmd"
        )
        $exe = $searchPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
    }

    if (-not $exe) {
        Write-Error "Antigravity IDE could not be found! Please make sure it is installed."
        return
    }

    # 3. Build arguments and invoke
    $callArgs = @()
    if ($NewWindow) {
        $callArgs += "-n"
    }
    $callArgs += $resolvedPath

    & "$exe" @callArgs
}

# Register alias 'ant'
if (-not (Get-Alias -Name ant -ErrorAction SilentlyContinue)) {
    Set-Alias -Name ant -Value Open-Antigravity -Description "Opens folder in Antigravity IDE"
}
