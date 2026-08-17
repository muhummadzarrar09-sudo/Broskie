# build_broskie.ps1
# This script sets up the environment and builds the Broskie APK using 2026 standards.

# 1. Setup Environment Paths
$env:PATH = "C:\Windows\System32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0;$env:PATH"  
$env:JAVA_HOME = "$env:USERPROFILE\.jdks\jdk-17"  
$env:PATH = "$env:JAVA_HOME\bin;$env:USERPROFILE\flutter\bin;$env:LOCALAPPDATA\Android\Sdk\cmdline-tools\latest\bin;$env:LOCALAPPDATA\Android\Sdk\platform-tools;$env:PATH"  
$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"  

# 2. Dynamic Path Setup
$currentDir = $PSScriptRoot
$sdk = $env:ANDROID_HOME -replace "\\","\\"
$fl = "$env:USERPROFILE\flutter" -replace "\\","\\"

# 3. Generate local.properties
$localPropsContent = "sdk.dir=$sdk`nflutter.sdk=$fl`nflutter.buildMode=release`nflutter.versionName=1.0.0`nflutter.versionCode=1"
$localPropsPath = Join-Path $currentDir "android\local.properties"
if (!(Test-Path (Join-Path $currentDir "android"))) { New-Item -ItemType Directory -Path (Join-Path $currentDir "android") -Force | Out-Null }
$localPropsContent | Set-Content $localPropsPath

# 4. Build Process
Set-Location $currentDir
Write-Host "--- FETCHING DEPENDENCIES ---" -ForegroundColor Cyan
flutter pub get  

Write-Host "--- GENERATING CODE (Riverpod MAX EFFICIENCY) ---" -ForegroundColor Cyan
dart run build_runner build --delete-conflicting-outputs

Write-Host "--- BUILDING APK ---" -ForegroundColor Cyan
flutter build apk --release --android-skip-build-dependency-validation

# 5. Final Check
$apk = Join-Path $currentDir "build\app\outputs\flutter-apk\app-release.apk"
if (Test-Path $apk) { 
    Write-Host "SUCCESS! Broskie APK is ready at: $apk" -ForegroundColor Green
    Start-Process explorer.exe (Split-Path $apk) 
} else { 
    Write-Host "BUILD FAILED. Please check the logs above." -ForegroundColor Red 
}
