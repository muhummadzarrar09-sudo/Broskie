# ══════════════════════════════════════════════════════════════
# BROSKIE — jump onto the arena branch + full verify, ONE paste
# (Windows PowerShell 5.1 compatible — semicolons, not && )
# ══════════════════════════════════════════════════════════════

Set-Location "C:\Users\YOU\Desktop\Broskie"   # ← EDIT THIS ONE LINE: your local clone path

# — 1. SWITCH + SYNC (guaranteed zero merge conflicts on a clean tree) —
git fetch origin
git checkout arena/01a01558-broskie
git reset --hard origin/arena/01a01558-broskie
git pull origin arena/01a01558-broskie
git log --oneline -3
git status --short

# — 2. FLUTTER GATES —
flutter pub get
dart format --set-exit-if-changed lib test
flutter analyze
flutter test

# — 3. CREW APK (uncomment when the gates are green) —
# .\build_broskie.ps1 -Target apk
