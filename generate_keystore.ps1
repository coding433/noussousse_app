# Generate Release Keystore for نصوص App
# سكريبت إنشاء مفتاح التوقيع للتطبيق

Write-Host "🔐 Generating Release Keystore for نصوص..." -ForegroundColor Green

$keystoreName = "noussousse-release-key.keystore"
$alias = "noussousse"

# Check if keystore already exists
if (Test-Path $keystoreName) {
    Write-Host "⚠️  Keystore already exists: $keystoreName" -ForegroundColor Yellow
    $overwrite = Read-Host "Do you want to overwrite it? (y/n)"
    if ($overwrite -ne "y") {
        Write-Host "❌ Operation cancelled" -ForegroundColor Red
        exit 1
    }
    Remove-Item $keystoreName
}

Write-Host "📝 Please provide the following information:" -ForegroundColor Cyan

# Collect keystore information
$storePassword = Read-Host "Enter keystore password (min 8 characters)" -AsSecureString
$keyPassword = Read-Host "Enter key password (min 8 characters)" -AsSecureString
$firstName = Read-Host "Enter your first name"
$lastName = Read-Host "Enter your last name"
$organization = Read-Host "Enter organization (e.g., Your Company Name)"
$city = Read-Host "Enter city"
$state = Read-Host "Enter state/province"
$country = Read-Host "Enter country code (e.g., SA, US, EG)"

# Convert secure strings to plain text for keytool
$storePasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($storePassword))
$keyPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($keyPassword))

# Create keystore
$distinguishedName = "CN=$firstName $lastName, OU=$organization, O=$organization, L=$city, S=$state, C=$country"

Write-Host "🔨 Generating keystore..." -ForegroundColor Yellow

try {
    & keytool -genkey -v -keystore $keystoreName -alias $alias -keyalg RSA -keysize 2048 -validity 10000 -storepass $storePasswordPlain -keypass $keyPasswordPlain -dname $distinguishedName
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Keystore generated successfully!" -ForegroundColor Green
        
        # Create keystore.properties file
        $propertiesContent = @"
RELEASE_STORE_FILE=$keystoreName
RELEASE_STORE_PASSWORD=$storePasswordPlain
RELEASE_KEY_ALIAS=$alias
RELEASE_KEY_PASSWORD=$keyPasswordPlain
"@
        
        $propertiesContent | Out-File -FilePath "keystore.properties" -Encoding UTF8
        Write-Host "📁 keystore.properties file created" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "🔒 IMPORTANT SECURITY NOTES:" -ForegroundColor Red
        Write-Host "1. Keep your keystore file and passwords SECURE" -ForegroundColor Yellow
        Write-Host "2. Make backups of your keystore file" -ForegroundColor Yellow
        Write-Host "3. Never share your keystore or passwords" -ForegroundColor Yellow
        Write-Host "4. Add keystore.properties to .gitignore" -ForegroundColor Yellow
        
        Write-Host ""
        Write-Host "📁 Files created:" -ForegroundColor Cyan
        Write-Host "   - $keystoreName (keystore file)" -ForegroundColor White
        Write-Host "   - keystore.properties (build configuration)" -ForegroundColor White
        
    } else {
        Write-Host "❌ Failed to generate keystore" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "💡 Make sure Java keytool is installed and in PATH" -ForegroundColor Yellow
    exit 1
}

# Clear sensitive variables
$storePasswordPlain = $null
$keyPasswordPlain = $null