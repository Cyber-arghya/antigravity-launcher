@echo off
setlocal enabledelayedexpansion

title Antigravity CLI Launcher Setup

echo ========================================================
echo        Antigravity IDE Launcher Auto-Setup
echo ========================================================
echo.

set "INSTALL_DIR=%LOCALAPPDATA%\AntigravityLauncher"

echo [*] Creating launcher directory: "%INSTALL_DIR%"
if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%" >nul 2>&1
)

echo [*] Copying scripts...
copy /y "%~dp0ant.cmd" "%INSTALL_DIR%\ant.cmd" >nul
copy /y "%~dp0ant.ps1" "%INSTALL_DIR%\ant.ps1" >nul

if not exist "%INSTALL_DIR%\ant.cmd" (
    echo [!] Failed to copy files to "%INSTALL_DIR%".
    goto failure
)

echo [*] Configuring User PATH and PowerShell Profiles...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$installDir = [System.IO.Path]::GetFullPath($env:LOCALAPPDATA + '\AntigravityLauncher');" ^
    "$userPath = [Environment]::GetEnvironmentVariable('Path', 'User');" ^
    "if ($userPath -split ';' -notcontains $installDir) {" ^
    "    $newPath = if ([string]::IsNullOrWhiteSpace($userPath)) { $installDir } else { $userPath.TrimEnd(';') + ';' + $installDir };" ^
    "    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User');" ^
    "    Write-Host '    [+] Added to User PATH: ' $installDir -ForegroundColor Cyan;" ^
    "} else {" ^
    "    Write-Host '    [=] Already present in User PATH.' -ForegroundColor Gray;" ^
    "};" ^
    "$profiles = @(" ^
    "    (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'WindowsPowerShell\Microsoft.PowerShell_profile.ps1')," ^
    "    (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell\Microsoft.PowerShell_profile.ps1')" ^
    ");" ^
    "$snippet = \"`n# Antigravity IDE Launcher`nif (Test-Path `\"`$env:LOCALAPPDATA\AntigravityLauncher\ant.ps1`\") { . `\"`$env:LOCALAPPDATA\AntigravityLauncher\ant.ps1`\" }`n\";" ^
    "foreach ($prof in $profiles) {" ^
    "    $dir = Split-Path $prof;" ^
    "    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null };" ^
    "    if (-not (Test-Path $prof)) { New-Item -ItemType File -Path $prof -Force | Out-Null };" ^
    "    $content = Get-Content -Path $prof -Raw -ErrorAction SilentlyContinue;" ^
    "    if ($content -notlike '*AntigravityLauncher\ant.ps1*') {" ^
    "        Add-Content -Path $prof -Value $snippet;" ^
    "        Write-Host ('    [+] Updated profile: ' + $prof) -ForegroundColor Cyan;" ^
    "    } else {" ^
    "        Write-Host ('    [=] Profile already configured: ' + $prof) -ForegroundColor Gray;" ^
    "    }" ^
    "}"

if %ERRORLEVEL% neq 0 (
    echo [!] Warning: Some PowerShell profile settings could not be applied automatically.
)

echo.
echo ========================================================
echo    [SUCCESS] Setup Completed Successfully!
echo ========================================================
echo.
echo Now you can open any folder in Antigravity IDE from:
echo.
echo   1. Command Prompt (CMD):
echo      ant .              (Opens current folder)
echo      ant -n .           (Opens in new window)
echo      ant "C:\path"      (Opens specific folder)
echo.
echo   2. PowerShell / pwsh:
echo      ant .              (Opens current folder)
echo      ant -NewWindow .   (Opens in new window)
echo      ant "C:\path"      (Opens specific folder)
echo.
echo NOTE: If CMD or PowerShell is already open, please close
echo and reopen it to reload the new PATH.
echo.
pause
exit /b 0

:failure
echo.
echo [!] Setup failed! Please run as administrator or check permissions.
echo.
pause
exit /b 1
