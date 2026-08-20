param(
    [ValidateSet("bundle", "apk")]
    [string]$Target = "apk"
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
    throw "Flutter is not on PATH. Install Flutter 3.44+ and run flutter doctor first."
}

if ($Target -eq "bundle" -and -not (Test-Path "android/key.properties")) {
    throw "A release bundle requires android/key.properties and a private upload keystore. See README.md."
}

if (-not (Test-Path "pubspec.lock")) {
    throw "pubspec.lock is missing. Run flutter pub get once, review it, and commit it before releasing."
}

# Don't --enforce-lockfile here: a lint bump must be allowed to refresh the lock.
# Format WRITES so a missing dart-format pass cannot kill a crew APK.
Invoke-Checked "RESOLVING DEPENDENCIES" { flutter pub get }
Invoke-Checked "FORMATTING" { dart format lib test }
Invoke-Checked "STATIC ANALYSIS" { flutter analyze }
Invoke-Checked "RUNNING TESTS" { flutter test }

if ($Target -eq "bundle") {
    Invoke-Checked "BUILDING SIGNED APP BUNDLE" { flutter build appbundle --release }
    $artifact = Join-Path $projectRoot "build/app/outputs/bundle/release/app-release.aab"
} else {
    # Debug APKs are signed automatically by Android's debug keystore, making
    # them directly installable for local QA without weakening release signing.
    Invoke-Checked "BUILDING INSTALLABLE DEBUG APK" { flutter build apk --debug }
    $sourceArtifact = Join-Path $projectRoot "build/app/outputs/flutter-apk/app-debug.apk"
    if (-not (Test-Path $sourceArtifact)) {
        throw "Build finished without the expected artifact: $sourceArtifact"
    }

    $artifact = Join-Path $projectRoot "build/app/outputs/flutter-apk/BROSKIE.apk"
    Copy-Item -LiteralPath $sourceArtifact -Destination $artifact -Force
}

if (-not (Test-Path $artifact)) {
    throw "Build finished without the expected artifact: $artifact"
}

Write-Host "SUCCESS: $artifact" -ForegroundColor Green
