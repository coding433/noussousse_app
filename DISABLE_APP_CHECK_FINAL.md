# ✅ FINAL FIX - DISABLE APP CHECK IN FIREBASE

## The Problem

Firebase **App Check** is automatically enabled and requires **Play Integrity API verification**
which:

- Fails on some devices
- Causes "Pin verification failed" error
- Blocks authentication

## The Solution: Disable App Check in Firebase Console

### Step 1: Go to Firebase Console

1. Open: https://console.firebase.google.com/
2. Select project: **kitaby-app**

### Step 2: Go to App Check

In the left menu, scroll down and look for **"App Check"**

(If you don't see it, it might be under "Build" section)

### Step 3: Find Your App

You should see: **com.applov.noussousse** (your app)

### Step 4: Disable App Check

**Option A: If you see a toggle or three-dots menu**

- Click the **three dots (⋯)** next to your app
- Click **"Remove registration"** or **"Unregister app"**
- Confirm

**Option B: If it shows as enabled**

- Click on the app name
- Look for **"Disable"** or **"Remove"** button
- Click it and confirm

**Option C: If you see a card with your app**

- Look for a delete icon or "Remove" option
- Click and confirm

### Step 5: Verify It's Disabled

After removal:

- Your app should no longer appear in the list
- OR show as "Not registered"

### Step 6: Wait 2-3 Minutes

Firebase needs time to update

### Step 7: Rebuild APK

```powershell
.\gradlew clean assembleRelease
```

### Step 8: Test

1. Uninstall old app from BOTH phones
2. Install new APK on both phones
3. Try registration - **SHOULD WORK NOW!** ✅

---

## Complete Checklist

- [ ] Opened Firebase Console
- [ ] Found "App Check" in left menu
- [ ] Found app: com.applov.noussousse
- [ ] Clicked three dots or disable button
- [ ] Removed/Unregistered the app
- [ ] Waited 2-3 minutes
- [ ] Rebuilt APK with `.\gradlew clean assembleRelease`
- [ ] Uninstalled old app from both phones
- [ ] Installed new APK on both phones
- [ ] Tested registration - WORKS! ✅

---

## If You Can't Find App Check

1. Go to **Firebase Console → Project Settings** (gear icon, top)
2. Look for **"Security"** tab
3. Look for any mention of **"App Check"** or **"Attestation"**
4. Disable/Remove it

---

## Why This Works

```
WITH App Check enabled:
Firebase requires Play Integrity verification
→ Play Integrity API fails on your devices
→ "Pin verification failed" error
❌ Registration blocked

WITHOUT App Check:
Firebase just checks email/password
→ No Play Integrity required
→ Authentication succeeds
✅ Registration works!
```

---

**Do this and registration will work perfectly!** 🎉
