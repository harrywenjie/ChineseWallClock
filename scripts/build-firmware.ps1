#requires -Version 7.0
<#
.SYNOPSIS
Compile the ChineseWallClock sketch with the pinned Arduino toolchain.

.DESCRIPTION
Uses Arduino CLI 0.35.3, ESP8266 core 3.1.2, the extracted libraries snapshot
and the recorded build properties. The default SOURCE_DATE_EPOCH is the value
used for the 2026-07-23 K4-03 deployment build. The image hash is printed and
compared with that deployment image when the default epoch is used.

This script only compiles. It does not flash or access a clock.

.PARAMETER Variant
Name used for temp/build/<Variant> and temp/artifacts/<Variant>.
Default: canonical1.

.PARAMETER Epoch
SOURCE_DATE_EPOCH value. Default: 1711661163. Pass an empty string to leave the
environment variable unset (the image then contains the current build time).

.PARAMETER Clean
Pass --clean to arduino-cli. Use this for a reproducible rebuild.

.EXAMPLE
pwsh -NoProfile -File scripts/build-firmware.ps1 -Variant canonical1 -Clean
#>
[CmdletBinding()]
param(
    [string]$Variant = 'canonical1',
    [string]$Epoch = '1711661163',
    [switch]$Clean
)

$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
Set-Location -LiteralPath $RepoRoot

$sketchDirName = Split-Path -Leaf $RepoRoot
if ($sketchDirName -ne 'ChineseWallClock') {
    throw "Sketch directory must be named 'ChineseWallClock' (found '$sketchDirName'). Arduino looks for ChineseWallClock.ino; rename the clone or build from a correctly named directory."
}

if ($Variant -notmatch '^[A-Za-z0-9._-]+$') {
    throw "Invalid variant name: $Variant"
}

$CliExe = Join-Path $RepoRoot 'temp\toolchain\arduino-cli-0.35.3\arduino-cli.exe'
$CliConfig = Join-Path $RepoRoot 'scripts\arduino-cli.yaml'
$Libraries = Join-Path $RepoRoot 'temp\bundled\libraries'
$BuildPath = Join-Path $RepoRoot "temp\build\$Variant"
$OutputDir = Join-Path $RepoRoot "temp\artifacts\$Variant"
$LogPath = Join-Path $RepoRoot "temp\logs\build-$Variant.log"

if (-not (Test-Path -LiteralPath $CliExe)) {
    throw "Missing Arduino CLI: $CliExe. Run scripts/setup-build-env.ps1 first."
}
if (-not (Test-Path -LiteralPath $CliConfig)) {
    throw "Missing Arduino CLI configuration: $CliConfig"
}
if (-not (Test-Path -LiteralPath (Join-Path $Libraries 'WiFiManager\library.properties'))) {
    throw "Missing bundled libraries: $Libraries. Run scripts/setup-build-env.ps1 first."
}

$cliVersion = (& $CliExe version 2>&1 | Out-String).Trim()
if ($cliVersion -notmatch '0\.35\.3') {
    throw "Expected Arduino CLI 0.35.3: $cliVersion"
}

New-Item -ItemType Directory -Force -Path $BuildPath, $OutputDir, (Split-Path -Parent $LogPath) | Out-Null

if ($Epoch) {
    $env:SOURCE_DATE_EPOCH = $Epoch
    Write-Host "SOURCE_DATE_EPOCH=$Epoch"
}
else {
    Remove-Item Env:SOURCE_DATE_EPOCH -ErrorAction SilentlyContinue
    Write-Host 'SOURCE_DATE_EPOCH is not set'
}

$cliArgs = @(
    '--config-file', $CliConfig,
    'compile',
    '--fqbn', 'esp8266:esp8266:d1_mini',
    '--libraries', $Libraries,
    '--build-path', $BuildPath,
    '--output-dir', $OutputDir,
    '--build-property', 'build.warn_data_percentage=75'
)
if ($Clean) {
    $cliArgs += '--clean'
}
$cliArgs += '.'

Write-Host "Compiling variant '$Variant'..."
& $CliExe @cliArgs 2>&1 | Tee-Object -FilePath $LogPath
$exitCode = $LASTEXITCODE
if ($exitCode -ne 0) {
    throw "Compile failed with exit code $exitCode; see $LogPath"
}

$binPath = Join-Path $OutputDir 'ChineseWallClock.ino.bin'
if (-not (Test-Path -LiteralPath $binPath)) {
    throw "Expected image not found: $binPath"
}

$image = Get-Item -LiteralPath $binPath
$imageHash = (Get-FileHash -LiteralPath $binPath -Algorithm SHA256).Hash
Write-Host ""
Write-Host "Variant: $Variant"
Write-Host "Log:     $LogPath"
Write-Host "Image:   $binPath"
Write-Host "Bytes:   $($image.Length)"
Write-Host "SHA-256: $imageHash"

$deploymentHash = '5E4F281421DCE894FED3F03DD9599AF8A690218A85C70B6A5A5DB466748D3D1D'
if ($Epoch -eq '1711661163') {
    if ($imageHash -eq $deploymentHash) {
        Write-Host 'MATCH: 2026-07-23 K4-03 deployment image hash.'
    }
    else {
        Write-Warning 'Hash differs from the deployment image. Check source commit, Arduino CLI/core version, libraries and epoch; if those match, compare image size and the memory report as well.'
    }
}
