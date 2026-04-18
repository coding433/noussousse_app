# DISABLE reCAPTCHA - QUICK SOLUTION

## The Problem

Firebase is trying to enforce reCAPTCHA SMS defense, but it's not set up. This causes "Pin
verification failed" error.

**Solution: Disable reCAPTCHA enforcement entirely.**

---

## STEP-BY-STEP FIX

### **Step 1: Go to Firebase Console**

https://console.firebase.google.com/

### **Step 2: Select Your Project**

Click on **"Kitaby App"**

### **Step 3: Go to Authentication Settings**

1. Left sidebar → **Authentication**
2. Top menu → **Settings** tab
3. Scroll down to **"reCAPTCHA"** section

### **Step 4: Disable reCAPTCHA**

You'll see the reCAPTCHA section showing:

- "You must first set up reCAPTCHA to create site keys..."

**Click "Manage reCAPTCHA" button**

### **Step 5: In Google Cloud Console**

This will open Google Cloud Console → reCAPTCHA

1. Look for **SMS settings** or **Phone authentication enforcement**
2. Find the toggle for enforcement
3. **Turn it OFF** (set to "OFF" or "DISABLED")
4. **SAVE**

### **Step 6: Return to Firebase**

Go back to Firebase Console

### **Step 7: Disable SMS Defense in Firebase**

Still in **Authentication → Settings → reCAPTCHA**:

Look for options like:

- "SMS defense for authentication"
- "Phone verification enforcement"
- "reCAPTCHA protection"

**Set all of them to "OFF" or "DISABLED"**

Click **SAVE**

---

## Alternative: Use Google Cloud CLI

If the UI is confusing, you can disable it via command line:

```bash
gcloud identity-platform config update \
  --recaptcha-config=phoneEnforcementState=OFF \
  --project=kitaby-app
```

---

## After Disabling

✅ reCAPTCHA will be completely ignored  
✅ Email/Password auth will work directly  
✅ No "Pin verification failed" error  
✅ No rebuild needed  
✅ Your existing APK should work immediately

---

## Quick Test

1. **Don't rebuild anything**
2. **Use your existing APK**
3. **Try to register**
4. **Should work!** ✅

If it still doesn't work after disabling reCAPTCHA, then there's another issue we need to
investigate.

---

## Commands to Verify

Check if reCAPTCHA is disabled:

```bash
gcloud identity-platform config describe \
  --project=kitaby-app
```

Look for: `phoneEnforcementState: OFF`
