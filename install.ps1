<#
.SYNOPSIS
    One-Line Installer for Antigravity IDE Launcher ('ant')
.DESCRIPTION
    Installs 'ant' CLI launcher for both Command Prompt (CMD) and PowerShell (pwsh).
    Run via:
    irm https://raw.githubusercontent.com/Cyber-arghya/antigravity-launcher/main/install.ps1 | iex
#>

$ErrorActionPreference = 'Stop'

Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "     Antigravity IDE Launcher ('ant') One-Line Setup     " -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

$installDir = [System.IO.Path]::Combine($env:LOCALAPPDATA, "AntigravityLauncher")

if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    Write-Host "[+] Created directory: $installDir" -ForegroundColor Green
}

# 1. Write ant.cmd
$antCmdContent = @'
@echo off
setlocal enabledelayedexpansion

set "NEW_WINDOW="
set "TARGET="

:parse_args
if "%~1"=="" goto done_args
if /i "%~1"=="-n" (
    set "NEW_WINDOW=-n"
    shift
    goto parse_args
)
if /i "%~1"=="--new-window" (
    set "NEW_WINDOW=-n"
    shift
    goto parse_args
)
if not defined TARGET (
    set "TARGET=%~1"
) else (
    set "TARGET=!TARGET! %~1"
)
shift
goto parse_args

:done_args
if not defined TARGET set "TARGET=."

where antigravity-ide.cmd >nul 2>&1
if !ERRORLEVEL! equ 0 (
    call antigravity-ide.cmd !NEW_WINDOW! "!TARGET!"
    exit /b !ERRORLEVEL!
)

if exist "%LOCALAPPDATA%\Programs\Antigravity IDE\bin\antigravity-ide.cmd" (
    call "%LOCALAPPDATA%\Programs\Antigravity IDE\bin\antigravity-ide.cmd" !NEW_WINDOW! "!TARGET!"
    exit /b !ERRORLEVEL!
)

if exist "%ProgramFiles%\Antigravity IDE\bin\antigravity-ide.cmd" (
    call "%ProgramFiles%\Antigravity IDE\bin\antigravity-ide.cmd" !NEW_WINDOW! "!TARGET!"
    exit /b !ERRORLEVEL!
)

if exist "%ProgramFiles(x86)%\Antigravity IDE\bin\antigravity-ide.cmd" (
    call "%ProgramFiles(x86)%\Antigravity IDE\bin\antigravity-ide.cmd" !NEW_WINDOW! "!TARGET!"
    exit /b !ERRORLEVEL!
)

if exist "%LOCALAPPDATA%\Programs\Antigravity IDE\Antigravity IDE.exe" (
    start "" "%LOCALAPPDATA%\Programs\Antigravity IDE\Antigravity IDE.exe" !NEW_WINDOW! "!TARGET!"
    exit /b 0
)

echo [ERROR] Antigravity IDE was not found!
echo Please verify that Antigravity IDE is installed.
exit /b 1
'@

Set-Content -Path (Join-Path $installDir "ant.cmd") -Value $antCmdContent -Encoding ASCII
Write-Host "[+] Installed ant.cmd" -ForegroundColor Green

# 2. Write ant.ps1
$antPs1Content = @'
function Open-Antigravity {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Path = ".",

        [Alias("n")]
        [switch]$NewWindow
    )

    try {
        $resolvedPath = (Resolve-Path -LiteralPath $Path -ErrorAction Stop).Path
    } catch {
        Write-Error "Path not found: $Path"
        return
    }

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

    $callArgs = @()
    if ($NewWindow) {
        $callArgs += "-n"
    }
    $callArgs += $resolvedPath

    & "$exe" @callArgs
}

if (-not (Get-Alias -Name ant -ErrorAction SilentlyContinue)) {
    Set-Alias -Name ant -Value Open-Antigravity -Description "Opens folder in Antigravity IDE"
}
'@

Set-Content -Path (Join-Path $installDir "ant.ps1") -Value $antPs1Content -Encoding UTF8
Write-Host "[+] Installed ant.ps1" -ForegroundColor Green

# 3. Add to User PATH
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if ($userPath -split ';' -notcontains $installDir) {
    $newPath = if ([string]::IsNullOrWhiteSpace($userPath)) { $installDir } else { $userPath.TrimEnd(';') + ';' + $installDir }
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Host "[+] Added $installDir to User PATH" -ForegroundColor Green
} else {
    Write-Host "[=] $installDir is already in User PATH" -ForegroundColor Gray
}

# Update current session PATH immediately
if ($env:PATH -split ';' -notcontains $installDir) {
    $env:PATH = "$env:PATH;$installDir"
}

# 4. Update PowerShell Profiles (Windows PowerShell & PowerShell 7+)
$profiles = @(
    (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'WindowsPowerShell\Microsoft.PowerShell_profile.ps1'),
    (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell\Microsoft.PowerShell_profile.ps1')
)

$snippet = @"

# Antigravity IDE Launcher
if (Test-Path "`$env:LOCALAPPDATA\AntigravityLauncher\ant.ps1") {
    . "`$env:LOCALAPPDATA\AntigravityLauncher\ant.ps1"
}
"@

foreach ($prof in $profiles) {
    try {
        $profDir = Split-Path $prof
        if (-not (Test-Path $profDir)) { New-Item -ItemType Directory -Path $profDir -Force | Out-Null }
        if (-not (Test-Path $prof)) { New-Item -ItemType File -Path $prof -Force | Out-Null }
        $content = Get-Content -Path $prof -Raw -ErrorAction SilentlyContinue
        if ($content -notlike '*AntigravityLauncher\ant.ps1*') {
            Add-Content -Path $prof -Value $snippet
            Write-Host "[+] Updated profile: $prof" -ForegroundColor Green
        } else {
            Write-Host "[=] Profile already configured: $prof" -ForegroundColor Gray
        }
    } catch {
        Write-Warning "Could not update profile: $prof"
    }
}

# 5. Load in current session
. (Join-Path $installDir "ant.ps1")

Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host "            Installation Completed Successfully!        " -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "You can now use 'ant' in this session and any new CMD / pwsh window:" -ForegroundColor Cyan
Write-Host "   ant .               (Open current folder in Antigravity)" -ForegroundColor White
Write-Host "   ant -n .            (Open current folder in new window)" -ForegroundColor White
Write-Host "   ant <path>          (Open specific directory)" -ForegroundColor White
Write-Host ""
