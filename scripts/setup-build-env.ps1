#requires -Version 7.0
<#
.SYNOPSIS
Rebuild the ignored temp/ Arduino build environment for ChineseWallClock.

.DESCRIPTION
Downloads and verifies Arduino CLI 0.35.3, installs ESP8266 core 3.1.2 with
the pinned board-manager URL, and extracts the tracked libraries snapshot.
Existing components are reused unless -Force is given. Network access is
required for missing components.

The script never touches hardware, never flashes a clock, and never deletes
the private K4-03 factory backup.

.PARAMETER Force
Re-download the Arduino CLI archive and re-extract the libraries snapshot.
An already installed ESP8266 core is kept.

.PARAMETER SkipCore
Do not install the ESP8266 core. Useful for an offline dry run.

.PARAMETER SkipLibraries
Do not extract libraries/libraries.zip.

.EXAMPLE
pwsh -NoProfile -File scripts/setup-build-env.ps1

.EXAMPLE
pwsh -NoProfile -File scripts/setup-build-env.ps1 -Force
#>
[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$SkipCore,
    [switch]$SkipLibraries
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
Set-Location -LiteralPath $RepoRoot

if ((Split-Path -Leaf $RepoRoot) -ne 'ChineseWallClock') {
    Write-Warning "Repository directory is '$(Split-Path -Leaf $RepoRoot)'. Arduino sketch builds require the directory name 'ChineseWallClock'; rename before running build-firmware.ps1."
}

$CliVersion = '0.35.3'
$CliUri = 'https://downloads.arduino.cc/arduino-cli/arduino-cli_0.35.3_Windows_64bit.zip'
$CliSha256 = 'B3B03C37DF87C99C9B201E4D4D5FB37F4F24E7441AC34510F5BB451DE1EDA35C'
$CliZip = Join-Path $RepoRoot 'temp\downloads\arduino-cli_0.35.3_Windows_64bit.zip'
$CliDir = Join-Path $RepoRoot 'temp\toolchain\arduino-cli-0.35.3'
$CliExe = Join-Path $CliDir 'arduino-cli.exe'
$CliConfig = Join-Path $RepoRoot 'scripts\arduino-cli.yaml'

$CoreId = 'esp8266:esp8266'
$CoreVersion = '3.1.2'
$CoreDir = Join-Path $RepoRoot 'temp\arduino-data\packages\esp8266\hardware\esp8266\3.1.2'

$LibrariesZip = Join-Path $RepoRoot 'libraries\libraries.zip'
$LibrariesSha256 = 'E92457AAE7DCCE9591787C9240D9D468B99E711AA15912361B62EB900ECBDD07'
$LibrariesRoot = Join-Path $RepoRoot 'temp\bundled'
$LibrariesDir = Join-Path $LibrariesRoot 'libraries'


function Write-Step([string]$Message) {
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}


function Assert-FileHash([string]$Path, [string]$ExpectedSha256) {
    $actual = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
    if ($actual -ne $ExpectedSha256) {
        throw "SHA-256 mismatch for $Path`nexpected: $ExpectedSha256`nactual:   $actual"
    }
}


Write-Step 'Preparing temp directories'
$tempDirs = @(
    'temp\downloads',
    'temp\toolchain',
    'temp\build',
    'temp\artifacts',
    'temp\logs',
    'temp\arduino-data',
    'temp\arduino-downloads',
    'temp\bundled'
)
foreach ($relative in $tempDirs) {
    New-Item -ItemType Directory -Force -Path (Join-Path $RepoRoot $relative) | Out-Null
}


Write-Step "Arduino CLI $CliVersion"
if ($Force -and (Test-Path -LiteralPath $CliZip)) {
    Remove-Item -LiteralPath $CliZip -Force
}
if (-not (Test-Path -LiteralPath $CliZip)) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $CliZip) | Out-Null
    Write-Host "Downloading $CliUri"
    Invoke-WebRequest -Uri $CliUri -OutFile $CliZip
}
Assert-FileHash -Path $CliZip -ExpectedSha256 $CliSha256
if ($Force -or -not (Test-Path -LiteralPath $CliExe)) {
    New-Item -ItemType Directory -Force -Path $CliDir | Out-Null
    Expand-Archive -LiteralPath $CliZip -DestinationPath $CliDir -Force
}
if (-not (Test-Path -LiteralPath $CliExe)) {
    throw "arduino-cli.exe not found after extraction: $CliExe"
}
if (-not (Test-Path -LiteralPath $CliConfig)) {
    throw "Missing CLI configuration: $CliConfig"
}
$cliVersion = (& $CliExe version 2>&1 | Out-String).Trim()
if ($cliVersion -notmatch [regex]::Escape($CliVersion)) {
    throw "Unexpected Arduino CLI version: $cliVersion"
}
Write-Host $cliVersion


Write-Step "ESP8266 core $CoreVersion"
$coreInstalled = Test-Path -LiteralPath (Join-Path $CoreDir 'platform.txt')
if ($SkipCore) {
    Write-Host 'Skipped (-SkipCore).'
}
elseif ($coreInstalled) {
    Write-Host "Already installed at $CoreDir"
}
else {
    Write-Host 'Downloading core and compiler tools from the board-manager index...'
    & $CliExe --config-file $CliConfig core update-index
    if ($LASTEXITCODE -ne 0) {
        throw "arduino-cli core update-index failed with exit code $LASTEXITCODE"
    }
    & $CliExe --config-file $CliConfig core install "$CoreId@$CoreVersion"
    if ($LASTEXITCODE -ne 0) {
        throw "arduino-cli core install failed with exit code $LASTEXITCODE"
    }
    if (-not (Test-Path -LiteralPath (Join-Path $CoreDir 'platform.txt'))) {
        throw "ESP8266 core not found after install: $CoreDir"
    }
}


Write-Step 'Libraries snapshot'
if ($SkipLibraries) {
    Write-Host 'Skipped (-SkipLibraries).'
}
elseif (-not $Force -and (Test-Path -LiteralPath (Join-Path $LibrariesDir 'WiFiManager\library.properties'))) {
    Write-Host "Already extracted at $LibrariesDir"
}
else {
    if (-not (Test-Path -LiteralPath $LibrariesZip)) {
        throw "Missing tracked libraries snapshot: $LibrariesZip"
    }
    Assert-FileHash -Path $LibrariesZip -ExpectedSha256 $LibrariesSha256
    New-Item -ItemType Directory -Force -Path $LibrariesRoot | Out-Null
    Expand-Archive -LiteralPath $LibrariesZip -DestinationPath $LibrariesRoot -Force
}
if (Test-Path -LiteralPath $LibrariesDir) {
    $libraryCount = @(Get-ChildItem -LiteralPath $LibrariesDir -Directory).Count
    Write-Host "Library directories: $libraryCount"
    if ($libraryCount -ne 18) {
        Write-Warning "Expected 18 library directories from libraries.zip; found $libraryCount."
    }
}


Write-Step 'esptool (flash tool, optional for build)'
try {
    $esptoolOutput = (& python -m esptool version 2>&1 | Out-String).Trim()
    if ($LASTEXITCODE -eq 0 -and $esptoolOutput -match '5\.3\.1') {
        Write-Host $esptoolOutput
    }
    else {
        Write-Warning "esptool 5.3.1 was not reported. Install it with: python -m pip install esptool==5.3.1"
        if ($esptoolOutput) { Write-Host $esptoolOutput }
    }
}
catch {
    Write-Warning "python/esptool not found. Install it with: python -m pip install esptool==5.3.1"
}


Write-Step 'Done'
Write-Host "Build environment root: $(Join-Path $RepoRoot 'temp')"
Write-Host 'Next: pwsh -NoProfile -File scripts/build-firmware.ps1 -Variant canonical1 -Clean'
