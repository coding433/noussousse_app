# 🔐 Keystore Password Reset - Solution

## Problem

```
keytool error: java.io.IOException: keystore password was incorrect
```

The current `noussousse-release-key.keystore` has a password that doesn't match any of our guesses.

## Solution: Create a New Keystore

Since we don't know the old password, we'll create a brand new one. This is the safest option.

---

## OPTION 1: Automated Solution (PowerShell - EASIEST)

Run this PowerShell script:

```powershell
# Run from project root directory
# Make sure you have Java/keytool installed

.\generate_keystore.ps1
```

This will:

1. Ask you for a new password (write it down!)
2. Ask for your name and organization info
3. Generate a new keystore
4. Update `keystore.properties` automatically

---

## OPTION 2: Manual Solution (Command Prompt)

### Step 1: Backup the Old Keystore

```bash
# Rename the old keystore just in case
ren noussousse-release-key.keystore noussousse-release-key.keystore.old
```

### Step 2: Generate New Keystore

Open **Command Prompt** (NOT PowerShell) and run:

```bash
keytool -genkey -v -keystore noussousse-release-key.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias noussousse
```

**When prompted:**

```
Enter keystore password (minimum 6 characters): 
  → Enter: MySecurePassword123
Re-enter new password:
  → Enter: MySecurePassword123
  
What is your first name and middle initial?
  → Your Name
  
What is your last name?
  → Your Surname
  
What is your organizational unit?
  → Development
  
What is your organization?
  → Your Company
  
What is your City or Locality?
  → Your City
  
What is your State or Province Name?
  → Your State
  
What is the two-letter country code for this unit?
  → SA (or your country code)
  
Is CN=Your Name, OU=Development, O=Your Company, L=Your City, S=Your State, C=SA correct?
  → yes
  
Enter key password for <noussousse>:
  → Press ENTER (to use same password as keystore)
  
Re-enter new password:
  → Press ENTER
```

### Step 3: Update keystore.properties

Edit `keystore.properties`:

```properties
RELEASE_STORE_FILE=noussousse-release-key.keystore
RELEASE_STORE_PASSWORD=MySecurePassword123
RELEASE_KEY_ALIAS=noussousse
RELEASE_KEY_PASSWORD=MySecurePassword123
```

Replace `MySecurePassword123` with the password you entered.

---

## Step 4: Verify the New Keystore

```bash
keytool -list -v -keystore noussousse-release-key.keystore -alias noussousse
```

When prompted, enter the password you just set.

**You should see:**

```
Alias name: noussousse
Creation date: ...
Entry type: PrivateKeyEntry
Certificate chain length: 1
Certificate[1]:
Owner: CN=Your Name, OU=Development, O=Your Company, L=Your City, S=Your State, C=SA
...
SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
SHA256: XXXX...
```

✅ **Copy the SHA1 and SHA256 values**

---

## Step 5: Add New SHA Fingerprints to Firebase

1. Go to: **Firebase Console → Project Settings → Your App**
2. Under **"SHA certificate fingerprints"**
3. **Delete the old fingerprints** (if any)
4. Click **"Add fingerprint"**
5. Paste the new **SHA1**
6. Click **"Add fingerprint"** again
7. Paste the new **SHA256**
8. **Save**

---

## Step 6: Build and Test

```bash
# Clean previous builds
gradlew clean

# Build release APK
gradlew assembleRelease
```

Output: `app/release/app-release.apk`

---

## Step 7: Test on Both Phones

1. Uninstall old app from both phones
2. Install the new `app-release.apk` on your phone
3. Install the same APK on your friend's phone
4. Both should now register successfully! ✅

---

## IMPORTANT: Save Your Password!

**Write down and save your new keystore password:**

```
Keystore Password: ___________________
Keystore File: noussousse-release-key.keystore
Alias: noussousse
```

Store this in a secure location (password manager, secure note, etc.)

**⚠️ If you lose this password, you'll need to create a new keystore again!**

---

## What to Do with Old Keystore

After confirming the new keystore works:

- Keep `noussousse-release-key.keystore.old` as backup for 30 days
- Then safely delete it

---

## Troubleshooting

### "keytool command not found"

- Java is not installed or not in PATH
- Install Java JDK and add it to PATH
- Or use Android Studio's built-in keytool

### Still getting "password was incorrect"

- Make sure you're using the same password you just entered
- Try running the command again
- Make sure the keystore file isn't corrupted

### Build still fails

- Clean: `gradlew clean`
- Rebuild: `gradlew assembleRelease`
- Check `keystore.properties` has correct passwords
