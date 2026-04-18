# GOOGLE CLOUD SOLUTION - DISABLE RECAPTCHA ENFORCEMENT

## The Real Issue

Even though SHA certificates are correct, Firebase Authentication has **reCAPTCHA/App Verification
ENFORCED** at the Google Cloud project level.

This can only be disabled via **Google Cloud CLI** or **Google Cloud Console**.

---

## SOLUTION 1: Google Cloud CLI (Fastest)

### Step 1: Install Google Cloud CLI

Download from: https://cloud.google.com/sdk/docs/install

### Step 2: Login

```bash
gcloud auth login
```

### Step 3: Set Project

```bash
gcloud config set project kitaby-app
```

### Step 4: Disable reCAPTCHA Enforcement

```bash
gcloud identity-platform config update \
  --recaptcha-config=phoneEnforcementState=OFF \
  --project=kitaby-app
```

### Step 5: Verify It's Disabled

```bash
gcloud identity-platform config describe --project=kitaby-app
```

Look for: `phoneEnforcementState: OFF`

---

## SOLUTION 2: Google Cloud Console (Manual)

### Step 1: Open Google Cloud Console

https://console.cloud.google.com/

### Step 2: Select Project

Click on "Kitaby App" project

### Step 3: Go to Identity and Access Management

1. Search for **"Identity Platform"**
2. Click on **"Identity Platform"**

### Step 4: Find Authentication Settings

1. Look for **"Settings"** or **"Configuration"**
2. Find **"reCAPTCHA"** or **"Phone Authentication"** settings
3. Set **enforcement** to **"OFF"** or **"DISABLED"**

### Step 5: Save

Click **SAVE**

---

## SOLUTION 3: Alternative API Call

Use this REST API call:

```bash
curl -X PATCH \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  -d '{
    "recaptchaConfig": {
      "phoneEnforcementState": "OFF"
    }
  }' \
  "https://identitytoolkit.googleapis.com/admin/v2/projects/kitaby-app/config"
```

---

## After Disabling

1. **Wait 2-3 minutes** for changes to propagate
2. **Don't rebuild** - use existing APK
3. **Test registration** - should work! ✅

---

## Why This Works

Firebase Authentication has **server-side enforcement** that can't be disabled from client code. It
must be disabled at the Google Cloud project level.

```
BEFORE:
Firebase Server → reCAPTCHA ENFORCED → "Pin verification failed"

AFTER:
Firebase Server → reCAPTCHA OFF → Authentication works ✅
```