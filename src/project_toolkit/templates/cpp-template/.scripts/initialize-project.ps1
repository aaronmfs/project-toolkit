# Bank Account System - Project Initialization Script
# This script clones the repository, downloads dependencies (WebView2), and sets up the project

param(
    [string]$ProjectPath = "C:\Projects\Bank-Account-System",
    [switch]$SkipClone = $false,
    [switch]$CleanBuild = $false
)

$skipWebView2 = $false

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "  Bank Account System - Project Initialization" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host ""

# Repository URL
$repoUrl = "https://github.com/aaronmfs/Bank-Account-System.git"

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

function Test-Internet {
    try {
        return Test-Connection -ComputerName "github.com" -Count 1 -Quiet
    }
    catch {
        return $false
    }
}

# =============================================================================
# Pre-flight Checks
# =============================================================================
Write-Host "[Pre-flight Checks]" -ForegroundColor Cyan
Write-Host "-------------------" -ForegroundColor Cyan

if (-not (Test-Command "git")) {
    Write-Host "[X] Git is not installed or not in PATH" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Git is available" -ForegroundColor Green

if (-not (Test-Command "cmake")) {
    Write-Host "[X] CMake is not installed or not in PATH" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] CMake is available" -ForegroundColor Green

if (-not (Test-Internet)) {
    Write-Host "[X] No internet connection detected" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Internet connection available" -ForegroundColor Green

Write-Host ""

# =============================================================================
# Step 1: Clone Repository
# =============================================================================
Write-Host "[1/4] Cloning Repository" -ForegroundColor Cyan

if (-not $SkipClone) {
    if (Test-Path $ProjectPath) {
        $overwrite = Read-Host "Directory exists. Delete and re-clone? (y/N)"
        if ($overwrite -match "^[yY]$") {
            Remove-Item -Path $ProjectPath -Recurse -Force
        }
        else {
            $SkipClone = $true
        }
    }

    if (-not $SkipClone) {
        $parentDir = Split-Path -Parent $ProjectPath
        if (-not (Test-Path $parentDir)) {
            New-Item -ItemType Directory -Force -Path $parentDir | Out-Null
        }

        git clone --recurse-submodules $repoUrl $ProjectPath
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[X] Git clone failed" -ForegroundColor Red
            exit 1
        }
    }
}

Set-Location $ProjectPath

if ($SkipClone) {
    git submodule update --init --recursive
}

Write-Host ""

# =============================================================================
# Step 2: Download WebView2 SDK
# =============================================================================
Write-Host "[2/4] Downloading WebView2 SDK" -ForegroundColor Cyan

$webview2Path = "lib/webview2"
$webview2Url  = "https://www.nuget.org/api/v2/package/Microsoft.Web.WebView2/1.0.2792.45"

if ((Test-Path $webview2Path) -and -not $CleanBuild) {
    $redownload = Read-Host "WebView2 exists. Re-download? (y/N)"
    if ($redownload -notmatch "^[yY]$") {
        $skipWebView2 = $true
    }
    else {
        Remove-Item -Path $webview2Path -Recurse -Force
    }
}

if (-not $skipWebView2) {
    $tempZip = "webview2_temp.zip"
    Invoke-WebRequest -Uri $webview2Url -OutFile $tempZip
    Expand-Archive -Path $tempZip -DestinationPath $webview2Path -Force
    Remove-Item $tempZip -Force
}

Write-Host ""

# =============================================================================
# Step 3: Dependency Checks
# =============================================================================
Write-Host "[3/4] Checking Dependencies" -ForegroundColor Cyan

if ((Test-Path "package.json") -and (Test-Command "npm")) {
    npm install
}

if ((Test-Path "requirements.txt") -and (Test-Command "pip")) {
    pip install -r requirements.txt
}

Write-Host ""

# =============================================================================
# Step 4: Summary
# =============================================================================
Write-Host "[4/4] Project Summary" -ForegroundColor Cyan
Write-Host "Project Location: $ProjectPath"

Write-Host "Project Structure:"
Get-ChildItem -Directory | ForEach-Object {
    Write-Host "  [DIR]  $($_.Name)"
}
Get-ChildItem -File | Select-Object -First 10 | ForEach-Object {
    Write-Host "  [FILE] $($_.Name)"
}

Write-Host ""
Write-Host "Initialization Complete!" -ForegroundColor Green
Write-Host "Happy coding!" -ForegroundColor Green