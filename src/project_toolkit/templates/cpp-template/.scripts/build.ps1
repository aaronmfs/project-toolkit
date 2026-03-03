# Remove build directory if it exists
if (Test-Path ".\build") {
    Write-Host "Removing existing build directory..." -ForegroundColor Yellow
    Remove-Item ".\build" -Recurse -Force
}
else {
    Write-Host "No build directory found, skipping cleanup." -ForegroundColor Gray
}

# Possible VS Developer Shell locations
$vsDevShell = @(
    "C:\Program Files\Microsoft Visual Studio\18\Community\Common7\Tools\Launch-VsDevShell.ps1"
    "C:\Program Files\Microsoft Visual Studio\18\BuildTools\Common7\Tools\Launch-VsDevShell.ps1"
    "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\Launch-VsDevShell.ps1"
    "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\Launch-VsDevShell.ps1"
    "C:\Program Files (x86)\Microsoft Visual Studio\18\BuildTools\Common7\Tools\Launch-VsDevShell.ps1"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $vsDevShell) {
    Write-Error "Visual Studio Developer Shell not found. Install VS with C++ workload."
    exit 1
}

# Dot-source so environment persists
Write-Host "Loading Visual Studio Developer Shell:" -ForegroundColor Cyan
Write-Host "$vsDevShell" -ForegroundColor Gray
. $vsDevShell

# Configure and build
Write-Host "Configuring project with CMake..." -ForegroundColor Cyan
cmake -S . -B build

Write-Host "Building project..." -ForegroundColor Cyan
cmake --build build --config Release
