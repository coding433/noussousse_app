# 🧪 دليل اختبار Cloud Functions

## ✅ **تم النشر بنجاح!**

```
✓ updateUserPassword(us-central1)
✓ cleanupPasswordField(us-central1)
```

---

## 📋 **خطوات الاختبار الكاملة**

### **الخطوة 1: إنشاء User للاختبار**

1. افتح Firebase Console → Authentication
2. أضف user جديد للاختبار:
    - Email: `testuser@example.com`
    - Password: `OldPassword123!`
3. احفظ

---

### **الخطوة 2: إنشاء طلب Reset من التطبيق**

1. افتح التطبيق
2. Login Screen → **"Forgot Password?"**
3. اختر **"Request manual reset from Admin"**
4. أدخل: `testuser@example.com`
5. اضغط Submit

✅ يجب أن تظهر رسالة: **"Reset request submitted"**

---

### **الخطوة 3: التحقق من Firestore**

1. افتح Firebase Console
2. اذهب لـ **Firestore Database**
3. ابحث عن Collection: **`passwordResetRequests`**
4. افتح آخر Document

يجب أن ترى:

```json
{
  "email": "testuser@example.com",
  "status": "pending",
  "requestedAt": 1761045678900,
  "requestType": "manual_password_reset",
  "appVersion": "1.1.0",
  "userAgent": "RMX3834",
  "notes": "",
  "resolvedAt": null,
  "resolvedBy": null,
  "newPassword": null
}
```

---

### **الخطوة 4: Admin يضيف كلمة المرور الجديدة**

**في Firebase Console → Firestore:**

1. افتح الـ Document (status: "pending")
2. اضغط **"Edit Document"** (أيقونة القلم)
3. اضغط **"Add Field"**
    - **Field name:** `newPassword`
    - **Type:** `string`
    - **Value:** `NewPassword2024!`
4. اضغط **"Save"** أو **"Update"**

---

### **الخطوة 5: مراقبة Cloud Function (3-5 ثوانٍ)**

**ماذا سيحدث تلقائياً:**

1. ✅ Cloud Function تلتقط التغيير
2. ✅ تحدّث Firebase Auth (password → `NewPassword2024!`)
3. ✅ تحدّث الـ Document:
    - `status` → `"completed"`
    - `resolvedAt` → timestamp
    - `resolvedBy` → `"admin"`
    - `passwordUpdated` → `true`
    - `notes` → `"Password updated successfully by admin"`
4. ✅ تحذف حقل `newPassword` (للأمان)

---

### **الخطوة 6: التحقق من التحديث**

**في Firestore:**

بعد 5 ثوانٍ، refresh الصفحة، يجب أن ترى:

```json
{
  "email": "testuser@example.com",
  "status": "completed",  ← تغيّر
  "resolvedAt": 1761045690000,  ← جديد
  "resolvedBy": "admin",  ← جديد
  "passwordUpdated": true,  ← جديد
  "notes": "Password updated successfully by admin",  ← جديد
  "newPassword": [DELETED]  ← تم الحذف!
}
```

---

### **الخطوة 7: اختبار تسجيل الدخول**

**في التطبيق:**

1. Login Screen
2. Email: `testuser@example.com`
3. Password: `NewPassword2024!` ← **كلمة المرور الجديدة**
4. اضغط Login

✅ **يجب أن يعمل!**

---

## 📊 **مراقبة Logs**

### **في Terminal:**

```bash
firebase functions:log
```

أو

### **في Firebase Console:**

1. Functions → Logs
2. ابحث عن:
   ```
   ✅ Admin set new password for: testuser@example.com
   ✅ Password updated successfully for: testuser@example.com
   ✅ Request marked as completed
   ✅ Password field removed for security
   ```

---

## ⚠️ **Troubleshooting**

### **المشكلة 1: status ما زال "pending"**

✅ **الحلول:**

- انتظر 10 ثوانٍ وrefresh
- تحقق من Logs: `firebase functions:log`
- تحقق من User موجود في Authentication

### **المشكلة 2: "User not found"**

✅ **الحل:**

- User يجب أن يكون في **Firebase Authentication → Users**
- Email يجب أن يطابق تماماً

### **المشكلة 3: Login لا يعمل**

✅ **الحلول:**

- تأكد من `passwordUpdated: true` في Firestore
- تأكد من status: `"completed"`
- جرب logout/login من التطبيق
- تحقق من Logs

---

## 🎯 **النتيجة المتوقعة**

### **سيناريو ناجح:**

```
User → Forgot Password (Option 2)
  ↓
Firestore → Document created (status: "pending")
  ↓
Admin → Adds "newPassword" field
  ↓ (3-5 seconds)
Cloud Function → Updates Firebase Auth
  ↓
Firestore → status: "completed", newPassword deleted
  ↓
User → Login with new password ✅
```

---

## 📱 **للـ Admin App (اختياري)**

إذا كنت تبني تطبيق Admin منفصل، يمكن إضافة UI:

```java
// في Admin App
AlertDialog.Builder builder = new AlertDialog.Builder(context);
builder.setTitle("Set New Password for: " + email);

EditText input = new EditText(context);
input.setHint("Enter new password");
input.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
builder.setView(input);

builder.setPositiveButton("Update", (dialog, which) -> {
    String newPassword = input.getText().toString();
    
    if (newPassword.length() < 6) {
        Toast.makeText(context, "Password must be at least 6 characters", Toast.LENGTH_SHORT).show();
        return;
    }
    
    // Update Firestore
    FirebaseFirestore.getInstance()
        .collection("passwordResetRequests")
        .document(requestId)
        .update("newPassword", newPassword)
        .addOnSuccessListener(aVoid -> {
            Toast.makeText(context, 
                "Password update triggered!\nCheck in 5 seconds.", 
                Toast.LENGTH_LONG).show();
        })
        .addOnFailureListener(e -> {
            Toast.makeText(context, 
                "Error: " + e.getMessage(), 
                Toast.LENGTH_SHORT).show();
        });
});

builder.setNegativeButton("Cancel", null);
builder.show();
```

---

## 🔗 **روابط مفيدة**

- **Firebase Console:** https://console.firebase.google.com/project/kitaby-app
- **Functions Logs:** https://console.firebase.google.com/project/kitaby-app/functions/logs
- **Firestore:** https://console.firebase.google.com/project/kitaby-app/firestore

---

## ✅ **Checklist**

قبل اعتبار الميزة جاهزة:

- [ ] User يقدر يطلب Reset (Option 2)
- [ ] Firestore يحفظ الطلب بنجاح
- [ ] Admin يقدر يضيف `newPassword`
- [ ] Cloud Function تحدّث Firebase Auth
- [ ] Status يتغير لـ `completed`
- [ ] `newPassword` يُحذف من Firestore
- [ ] User يقدر يسجل دخول بكلمة المرور الجديدة

---

**Date:** 2025-10-21  
**Status:** ✅ Deployed Successfully
