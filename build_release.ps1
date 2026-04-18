# Build script for Google Play Store release
# نصوص - سكريبت بناء الإصدار للنشر

Write-Host "🚀 Building نصوص App for Google Play Store..." -ForegroundColor Green

# Check if keystore.properties exists
if (-not (Test-Path "keystore.properties")) {
    Write-Host "❌ Error: keystore.properties file not found!" -ForegroundColor Red
    Write-Host "Please create keystore.properties with your signing credentials" -ForegroundColor Yellow
    exit 1
}

# Check if release keystore exists
$keystoreFile = Get-Content "keystore.properties" | Where-Object { $_ -match "RELEASE_STORE_FILE=" } | ForEach-Object { $_.Split("=")[1] }
if (-not (Test-Path $keystoreFile)) {
    Write-Host "❌ Error: Release keystore not found: $keystoreFile" -ForegroundColor Red
    Write-Host "Please generate your release keystore first" -ForegroundColor Yellow
    exit 1
}

Write-Host "📦 Cleaning previous builds..." -ForegroundColor Yellow
./gradlew clean

Write-Host "🔨 Building release App Bundle..." -ForegroundColor Yellow
./gradlew bundleRelease

Write-Host "📊 Generating build report..." -ForegroundColor Yellow
$bundlePath = "app/build/outputs/bundle/release/app-release.aab"

if (Test-Path $bundlePath) {
    $bundleSize = [math]::Round((Get-Item $bundlePath).Length / 1MB, 2)
    Write-Host "✅ Success! App Bundle created:" -ForegroundColor Green
    Write-Host "   📍 Location: $bundlePath" -ForegroundColor Cyan
    Write-Host "   📏 Size: $bundleSize MB" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🎯 Ready for Google Play Store upload!" -ForegroundColor Green
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Upload the .aab file to Google Play Console" -ForegroundColor White
    Write-Host "2. Complete store listing with screenshots" -ForegroundColor White
    Write-Host "3. Set content rating and pricing" -ForegroundColor White
    Write-Host "4. Submit for review" -ForegroundColor White
} else {
    Write-Host "❌ Build failed! Check logs above for errors." -ForegroundColor Red
    exit 1
}