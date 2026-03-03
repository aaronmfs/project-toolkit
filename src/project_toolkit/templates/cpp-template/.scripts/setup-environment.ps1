# Windows Development Environment Setup Script
# Installs Git, CMake, and Visual Studio Build Tools with MSVC
#Requires -RunAsAdministrator

$skipGit   = $false
$skipCMake = $false
$skipVS    = $false

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "  Windows Development Environment Setup" -ForegroundColor Cyan
Write-Host "  Installing: Git, CMake, and Visual Studio Build Tools (MSVC)" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

$tempDir = "$env:TEMP\DevSetup"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
Write-Host "Created temporary directory: $tempDir" -ForegroundColor Gray
Write-Host ""

function Test-Command {
    param($Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

function Download-File {
    param(
        [string]$Url,
        [string]$OutputPath,
        [string]$Name
    )

    Write-Host "Downloading $Name..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $Url -OutFile $OutputPath
        Write-Host "[OK] Downloaded $Name" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "[X] Failed to download $Name" -ForegroundColor Red
        return $false
    }
}

# =============================================================================
# STEP 1: Install Git
# =============================================================================
Write-Host "[1/3] Installing Git" -ForegroundColor Cyan

if (Test-Command "git") {
    Write-Host "[OK] Git already installed" -ForegroundColor Green
    if ((Read-Host "Reinstall Git? (y/N)") -notmatch "^[yY]$") {
        $skipGit = $true
    }
}

if (-not $skipGit) {
    $gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/Git-2.43.0-64-bit.exe"
    $gitInstaller = Join-Path $tempDir "git-installer.exe"

    if (Download-File $gitUrl $gitInstaller "Git") {
        Start-Process $gitInstaller -ArgumentList "/VERYSILENT","/NORESTART" -Wait
    }
}

Write-Host ""

# =============================================================================
# STEP 2: Install CMake
# =============================================================================
Write-Host "[2/3] Installing CMake" -ForegroundColor Cyan

if (Test-Command "cmake") {
    Write-Host "[OK] CMake already installed" -ForegroundColor Green
    if ((Read-Host "Reinstall CMake? (y/N)") -notmatch "^[yY]$") {
        $skipCMake = $true
    }
}

if (-not $skipCMake) {
    $cmakeUrl = "https://github.com/Kitware/CMake/releases/download/v3.28.1/cmake-3.28.1-windows-x86_64.msi"
    $cmakeInstaller = Join-Path $tempDir "cmake-installer.msi"

    if (Download-File $cmakeUrl $cmakeInstaller "CMake") {
        Start-Process "msiexec.exe" -ArgumentList "/i",$cmakeInstaller,"/quiet","/norestart","ADD_CMAKE_TO_PATH=System" -Wait
    }
}

Write-Host ""

# =============================================================================
# STEP 3: Visual Studio / MSVC Installation
# =============================================================================
Write-Host "[3/3] Installing Visual Studio / MSVC" -ForegroundColor Cyan

$vsPath = "C:\Program Files\Microsoft Visual Studio\18\Community"
$btPath = "C:\Program Files (x86)\Microsoft Visual Studio\18\BuildTools"

if ((Test-Path $vsPath) -or (Test-Path $btPath)) {
    Write-Host "[OK] Visual Studio detected at:"
    Write-Host "$($vsPath | Where-Object { Test-Path $_ })"
    if ((Read-Host "Modify Visual Studio installation? (Y/n)") -notmatch "^[yY]$") {
        $skipVS = $true
    }
}

if (-not $skipVS) {

    Write-Host "Choose MSVC installation mode:"
    Write-Host "  1 = Automated (silent install of required components)"
    Write-Host "  2 = Manual (open Visual Studio Installer UI)"
    $installMode = Read-Host "Enter choice (1 or 2)"

    Write-Host "Choose Visual Studio edition:"
    Write-Host "  1 = Build Tools only (no IDE)"
    Write-Host "  2 = Visual Studio Community (IDE)"
    $vsEdition = Read-Host "Enter choice (1 or 2)"

    if ($vsEdition -eq "1") {
        $vsUrl = "https://aka.ms/vs/stable/vs_BuildTools.exe"
        $vsInstaller = Join-Path $tempDir "vs_buildtools.exe"
    }
    else {
        $vsUrl = "https://aka.ms/vs/17/release/vs_community.exe"
        $vsInstaller = Join-Path $tempDir "vs_community.exe"
    }

    if (-not (Test-Path $vsInstaller)) {
        Write-Host "Downloading Visual Studio Installer..."
        Download-File -Url $vsUrl -OutputPath $vsInstaller -Name "Visual Studio Installer"
    }

    if ($installMode -eq "1") {
        # Automated install with selected components
        $vsArgs = @(
            "--quiet",
            "--wait",
            "--norestart",
            "--nocache",
            "--add", "Microsoft.VisualStudio.Workload.NativeDesktop",
            "--add", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
            "--add", "Microsoft.VisualStudio.Component.Windows10SDK",
            "--add", "Microsoft.VisualStudio.Component.Windows11SDK",
            "--add", "Microsoft.VisualStudio.Component.VC.CMake.Project",
            "--includeRecommended"
        )

        Write-Host "Starting automated Visual Studio installation..."
        Start-Process -FilePath $vsInstaller -ArgumentList $vsArgs -Wait
        Write-Host "[OK] Visual Studio automated install complete!" -ForegroundColor Green
    }
    else {
        # Manual install - open UI
        Write-Host "Launching Visual Studio Installer UI..."
        Start-Process -FilePath $vsInstaller
        Write-Host "IMPORTANT: Select the workload and components as instructed:"
        Write-Host "  - Desktop development with C++"
        Write-Host "  - Ensure MSVC v143, Windows SDK (latest), and C++ CMake tools are checked"
    }
}

# =============================================================================
# Cleanup
# =============================================================================
Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "Please restart your terminal before continuing." -ForegroundColor Yellow
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""
