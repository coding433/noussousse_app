# 🔴 Firebase PIN Verification Failed - DIRECT APK DISTRIBUTION FIX

## The Problem

You're distributing the APK directly to your friend (NOT via Google Play). Your registration works,
but your friend gets:

```
Registration Failed: An internal error has occurred. [Pin Verification failed]
```

## Root Cause

**Different devices = Different Signing Keys**

- Your phone: Built with your DEBUG keystore (SHA-1: XXXXX)
- Your friend's phone: Built with THEIR debug keystore (SHA-1: YYYYY)

Firebase reCAPTCHA verification fails because your friend's device SHA-1 **doesn't match** what
Firebase expects.

---

## Solution: Use a CONSISTENT Release Keystore

You already have a release keystore (`noussousse-release-key.keystore`), but it's not being used
properly.

### **STEP 1: Get Your Release Keystore SHA-1 Fingerprint**

Open **Command Prompt** (NOT PowerShell) and run:

```bash
keytool -list -v -keystore noussousse-release-key.keystore -alias noussousse
```

**When prompted for password:** Check your `keystore.properties` file for the store password.

**Look for:**

```
SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
SHA256: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

Copy both SHA-1 and SHA-256.

---

### **STEP 2: Add Both SHA Fingerprints to Firebase**

1. Go to: **Firebase Console** → **Project Settings** → Your app (`com.applov.noussousse`)
2. Scroll down to **"SHA certificate fingerprints"**
3. Add BOTH your SHA-1 and SHA-256 from the release keystore
4. **Apply changes**

---

### **STEP 3: Update build.gradle.kts to Use Release Keystore Properly**

Edit `app/build.gradle.kts` and replace the signing config:

**Find this section:**

```kotlin
signingConfigs {
    create("release") {
        // Temporarily use debug signing for testing
        // Replace with actual release keystore later
        storeFile = file("${System.getProperty("user.home")}/.android/debug.keystore")
        storePassword = "android"
        keyAlias = "androiddebugkey"
        keyPassword = "android"
    }
}
```

**Replace with:**

```kotlin
signingConfigs {
    create("release") {
        val keystorePropertiesFile = rootProject.file("keystore.properties")
        val keystoreProperties = Properties()
        if (keystorePropertiesFile.exists()) {
            keystoreProperties.load(keystorePropertiesFile.inputStream())
            storeFile = file(keystoreProperties.getProperty("RELEASE_STORE_FILE"))
            storePassword = keystoreProperties.getProperty("RELEASE_STORE_PASSWORD")
            keyAlias = keystoreProperties.getProperty("RELEASE_KEY_ALIAS")
            keyPassword = keystoreProperties.getProperty("RELEASE_KEY_PASSWORD")
        } else {
            // Fallback to debug keystore if properties not found
            storeFile = file("${System.getProperty("user.home")}/.android/debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
    }
}
```

---

### **STEP 4: Update keystore.properties with Correct Passwords**

Edit `keystore.properties` and set your actual keystore passwords:

```properties
RELEASE_STORE_FILE=noussousse-release-key.keystore
RELEASE_STORE_PASSWORD=your_release_keystore_password_here
RELEASE_KEY_ALIAS=noussousse
RELEASE_KEY_PASSWORD=your_release_key_password_here
```

**⚠️ IMPORTANT:** If you don't know the passwords:

- Try: `noussousse` for both
- Try: `123456` for both
- Try: `password` for both

**If none work:** You'll need to create a new keystore. See "Creating a New Keystore" below.

---

### **STEP 5: Add Both Debug AND Release SHA to Firebase**

Now Firebase needs BOTH:

1. Debug SHA-1 (for your own testing)
2. Release SHA-1 (for distributed APKs)

In **Firebase Console:**

- Add your **debug SHA-1** (from `debug.keystore`)
- Add your **release SHA-1** (from `noussousse-release-key.keystore`)
- Add corresponding **SHA-256** for both

---

### **STEP 6: Build Release APK with Correct Signing**

```bash
# Clean previous builds
./gradlew clean

# Build release APK (this will use keystore.properties)
./gradlew assembleRelease
```

**Output location:**

```
app/release/app-release.apk
```

---

### **STEP 7: Test on Multiple Devices**

1. Uninstall old version from both phones
2. Install the new release APK on your phone
3. Install the same release APK on your friend's phone
4. **Both should now register successfully!**

---

## Alternative: Quick Test with Debug Keystore

If you want to test quickly with debug keystore:

### Get Your Device's Debug SHA-1:

```bash
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

### Add to Firebase:

1. Copy the **SHA1** fingerprint
2. Firebase Console → Add this SHA-1 to fingerprints
3. Rebuild and test

**BUT** - Your friend needs to:

- Get their device's debug SHA-1 (different from yours!)
- You add THEIR SHA-1 to Firebase
- They rebuild the app locally
- Then they can register

**This is tedious, so use Release Keystore instead!**

---

## Creating a New Release Keystore (If Passwords Lost)

If you don't know the passwords, create a new one:

```bash
keytool -genkey -v -keystore noussousse-release-key.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias noussousse
```

**When prompted:**

- **Enter keystore password:** `123456` (or your choice - remember it!)
- **Re-enter password:** `123456`
- **First and last name:** Your Name
- **Organizational unit:** Your Company
- **Organization:** Your Company
- **City:** Your City
- **State:** Your State
- **Country code:** Your Country Code (e.g., US, SA, EG)
- **Key password:** Press Enter to use same as keystore

Then update `keystore.properties`:

```properties
RELEASE_STORE_FILE=noussousse-release-key.keystore
RELEASE_STORE_PASSWORD=123456
RELEASE_KEY_ALIAS=noussousse
RELEASE_KEY_PASSWORD=123456
```

---

## Firestore Rules Check ✅

Your Firestore rules look good for user registration:

```
match /users/{userId} {
  allow read, write: if request.auth != null && 
    (request.auth.uid == userId || 
     exists(/databases/$(database)/documents/admins/$(request.auth.uid)));
}
```

This allows any authenticated user to write their own user document. **This is correct!**

---

## Complete Checklist

- [ ] Get SHA-1 and SHA-256 from release keystore
- [ ] Add BOTH to Firebase Console
- [ ] Update app/build.gradle.kts signing config
- [ ] Update keystore.properties with correct passwords
- [ ] Run: `./gradlew clean assembleRelease`
- [ ] Test on your phone with release APK
- [ ] Test on friend's phone with SAME release APK
- [ ] Both should register successfully ✅

---

## If Still Not Working

1. **Clear Firebase Cache:**
    - Firebase Console → Reauthenticate → Settings
    - Wait 15 minutes for propagation

2. **Verify Email/Password is Enabled:**
    - Firebase Console → Authentication → Sign-in method
    - Check Email/Password has green checkmark ✅

3. **Check Internet:**
    - Both phones need stable internet
    - Try Wi-Fi instead of mobile data

4. **Check Device Time:**
    - Incorrect time can cause verification to fail
    - Go to Settings → Date & Time → Auto
