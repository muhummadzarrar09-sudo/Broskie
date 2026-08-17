param(
    [ValidateSet("bundle", "apk")]
    [string]$Target = "bundle"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Invoke-Checked {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Command
    )

    Write-Host "--- $Label ---" -ForegroundColor Cyan
    & $Command
    if ($LASTEXITCODE -ne 0) {
        throw "$Label failed with exit code $LASTEXITCODE."
    }
}

$projectRoot = $PSScriptRoot
Set-Location $projectRoot

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw "Flutter is not on PATH. Install Flutter 3.41+ and run flutter doctor first."
}

if ($Target -eq "bundle" -and -not (Test-Path "android/key.properties")) {
    throw "A release bundle requires android/key.properties and a private upload keystore. See README.md."
}

Invoke-Checked "FETCHING LOCKED DEPENDENCIES" { flutter pub get --enforce-lockfile }
Invoke-Checked "CHECKING FORMATTING" { dart format --output=none --set-exit-if-changed lib test }
Invoke-Checked "STATIC ANALYSIS" { flutter analyze }
Invoke-Checked "RUNNING TESTS" { flutter test }

if ($Target -eq "bundle") {
    Invoke-Checked "BUILDING SIGNED APP BUNDLE" { flutter build appbundle --release }
    $artifact = Join-Path $projectRoot "build/app/outputs/bundle/release/app-release.aab"
} else {
    Invoke-Checked "BUILDING QA APK" { flutter build apk --release }
    $artifact = Join-Path $projectRoot "build/app/outputs/flutter-apk/app-release.apk"
}

if (-not (Test-Path $artifact)) {
    throw "Build finished without the expected artifact: $artifact"
}

Write-Host "SUCCESS: $artifact" -ForegroundColor Green
