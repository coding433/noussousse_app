# ✅ CORRECT GRADLE BUILD COMMANDS

## The Issue

You're using **PowerShell**, which requires `.\` before commands in the current folder.

```
❌ WRONG (PowerShell):
gradlew clean

✅ CORRECT (PowerShell):
.\gradlew clean
```

---

## SOLUTION FOR POWERSHELL

Use these commands **EXACTLY as shown**:

```powershell
.\gradlew clean
.\gradlew assembleRelease
```

**Or all in one:**

```powershell
.\gradlew clean assembleRelease
```

---

## SOLUTION FOR COMMAND PROMPT

If you prefer Command Prompt (cmd.exe):

```cmd
gradlew clean
gradlew assembleRelease
```

Or:

```cmd
gradlew clean assembleRelease
```

---

## Complete Steps (PowerShell)

Run these commands in order:

```powershell
# Step 1: Delete old Android Studio keystore
del E:\realease\kitaby_noussousse_12.jks

# Step 2: Clean previous builds
.\gradlew clean

# Step 3: Build release APK
.\gradlew assembleRelease
```

---

## What Happens Next

After `.\gradlew assembleRelease` completes:

1. ✅ Build finishes successfully
2. ✅ APK is created at: `app/release/app-release.apk`
3. ✅ Signed with correct keystore
4. ✅ Ready to install on phones

---

## If Still Not Working

### Issue: "gradlew is not recognized"

**Solution:** Make sure you're in the correct directory:

```powershell
# Check current directory
pwd

# Should show: E:\13_projects\21_book_app\1_noussousse_app

# If not, navigate there:
cd E:\13_projects\21_book_app\1_noussousse_app

# Then run:
.\gradlew clean
```

### Issue: Permission Denied

**Solution:** Run PowerShell as Administrator

```powershell
# Right-click PowerShell → Run as Administrator
# Then run:
.\gradlew clean
.\gradlew assembleRelease
```

---

## Complete Guide to Build and Test

### Step 1: Build the APK

```powershell
# Navigate to project
cd E:\13_projects\21_book_app\1_noussousse_app

# Clean and build
.\gradlew clean
.\gradlew assembleRelease
```

**Wait for completion...** (takes 2-5 minutes)

### Step 2: Find the APK

```powershell
# The APK is here:
# E:\13_projects\21_book_app\1_noussousse_app\app\release\app-release.apk
```

### Step 3: Uninstall Old App

On your phone:

- Settings → Apps → [Your App] → Uninstall

On friend's phone:

- Same steps

### Step 4: Install New APK

**On your phone:**

```
1. Copy app-release.apk to phone
2. Open file manager
3. Tap app-release.apk
4. Install
```

**On friend's phone:**

```
1. Copy SAME app-release.apk to phone
2. Open file manager
3. Tap app-release.apk
4. Install
```

### Step 5: Test Registration

**Your phone:**

- ✅ Open app
- ✅ Try to register with test account
- ✅ Should work ✓

**Friend's phone:**

- ✅ Open app
- ✅ Try to register with different account
- ✅ Should work ✓

---

## Pro Tip: Use Command Prompt Instead

If PowerShell keeps giving errors, use Command Prompt (cmd.exe):

```cmd
# Right-click → Open Command Prompt here
# Or: Win+R → type cmd → Enter → cd /d E:\13_projects\21_book_app\1_noussousse_app

gradlew clean
gradlew assembleRelease
```

---

## Summary

| OS/Shell | Command |
|----------|---------|
| PowerShell | `.\gradlew clean` |
| PowerShell | `.\gradlew assembleRelease` |
| Command Prompt | `gradlew clean` |
| Command Prompt | `gradlew assembleRelease` |

**The dot-slash (`.\`) is required in PowerShell!**

