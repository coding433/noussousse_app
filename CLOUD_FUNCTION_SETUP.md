# ☁️ Cloud Function Setup Guide

## 🎯 الهدف

إنشاء Cloud Function تسمح للـ Admin بتعيين كلمة مرور جديدة للـ User مباشرة من Firestore.

---

## 🔄 كيف يعمل النظام؟

```
1. User → "Forgot Password" → Option 2
   ↓
2. Request يُحفظ في Firestore
   {
     email: "user@example.com",
     status: "pending",
     newPassword: ""  ← فارغ
   }
   ↓
3. Admin → يفتح Firestore
   → يضيف كلمة مرور في حقل "newPassword"
   → مثال: "NewPass123!"
   ↓
4. Cloud Function → تلتقط التغيير تلقائياً
   → تحدّث كلمة المرور في Firebase Auth
   → تحدّث status إلى "completed"
   → تحذف حقل newPassword (للأمان)
   ↓
5. User → يسجل دخول بكلمة المرور الجديدة ✓
```

---

## 📦 الملفات المطلوبة

```
project/
├── functions/
│   ├── index.js          ← Cloud Function code
│   └── package.json      ← Dependencies
├── firebase.json         ← Firebase config
└── .firebaserc          ← Project config
```

---

## 🚀 خطوات الإعداد

### **1️⃣ تثبيت Firebase CLI**

```bash
# إذا لم يكن مثبتاً
npm install -g firebase-tools

# تسجيل الدخول
firebase login
```

### **2️⃣ تهيئة Firebase Functions**

```bash
# في مجلد المشروع
firebase init functions

# اختر:
# - Use an existing project → kitaby-app
# - Language: JavaScript
# - ESLint: No (أو Yes إذا تريد)
# - Install dependencies: Yes
```

### **3️⃣ نسخ الملفات**

```bash
# الملفات موجودة في:
# - functions/index.js
# - functions/package.json

# أو استخدم الكود أدناه ⬇️
```

---

## 📝 **الكود الكامل**

### **functions/index.js**

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

/**
 * Triggered when passwordResetRequests document is updated
 * If admin adds 'newPassword', update Firebase Auth automatically
 */
exports.updateUserPassword = functions.firestore
    .document('passwordResetRequests/{requestId}')
    .onUpdate(async (change, context) => {
        const before = change.before.data();
        const after = change.after.data();
        
        // Check if newPassword was just added by admin
        if (!before.newPassword && after.newPassword && after.newPassword.trim() !== '') {
            const email = after.email;
            const newPassword = after.newPassword;
            
            console.log(`Admin set new password for: ${email}`);
            
            try {
                // Get user by email
                const userRecord = await admin.auth().getUserByEmail(email);
                
                // Update password in Firebase Auth
                await admin.auth().updateUser(userRecord.uid, {
                    password: newPassword
                });
                
                console.log(`✅ Password updated successfully for: ${email}`);
                
                // Update request status
                await change.after.ref.update({
                    status: 'completed',
                    resolvedAt: admin.firestore.FieldValue.serverTimestamp(),
                    resolvedBy: 'admin',
                    notes: 'Password updated successfully by admin',
                    passwordUpdated: true
                });
                
                return { success: true };
                
            } catch (error) {
                console.error(`❌ Error updating password:`, error);
                
                await change.after.ref.update({
                    status: 'failed',
                    notes: `Error: ${error.message}`,
                    passwordUpdated: false
                });
                
                return { success: false, error: error.message };
            }
        }
        
        return null;
    });

/**
 * Cleanup: Remove newPassword field after update (security)
 */
exports.cleanupPasswordField = functions.firestore
    .document('passwordResetRequests/{requestId}')
    .onUpdate(async (change, context) => {
        const after = change.after.data();
        
        if (after.passwordUpdated === true && after.newPassword) {
            await change.after.ref.update({
                newPassword: admin.firestore.FieldValue.delete()
            });
            console.log(`✅ Password field removed for security`);
        }
        
        return null;
    });
```

---

## 🔧 **نشر Cloud Function**

### **الطريقة 1: نشر من Terminal**

```bash
# الانتقال لمجلد functions
cd functions

# تثبيت Dependencies
npm install

# العودة للمجلد الرئيسي
cd ..

# نشر Functions
firebase deploy --only functions
```

### **الطريقة 2: نشر من Firebase Console**

```
1. افتح Firebase Console
2. اذهب لـ Functions
3. Create Function
4. انسخ الكود من index.js
5. Deploy
```

---

## 🧪 **كيف تختبر؟**

### **Test Complete Flow:**

```bash
# 1. User يطلب إعادة تعيين
User App → "Forgot Password" → Option 2
Email: testuser@example.com

# 2. افتح Firebase Console → Firestore
Collection: passwordResetRequests
Document: [latest]

البيانات الحالية:
{
  email: "testuser@example.com",
  status: "pending",
  requestedAt: 1761038437276,
  ...
}

# 3. أضف حقل newPassword
في Firebase Console → Edit Document → Add Field:
Field: newPassword
Type: string
Value: TestPassword123!

# 4. احفظ (Save)

# 5. Cloud Function تعمل تلقائياً!
→ تحدّث Firebase Auth
→ تحدّث status إلى "completed"
→ تحذف حقل newPassword

# 6. تحقق من Firebase Console → Authentication
User: testuser@example.com
Password: محدّث ✓

# 7. اختبر من التطبيق
Login with:
Email: testuser@example.com
Password: TestPassword123!
→ يجب أن يعمل ✓
```

---

## 📊 **بنية البيانات**

### **قبل Admin:**

```json
{
  "email": "user@example.com",
  "status": "pending",
  "requestedAt": 1761038437276,
  "requestType": "manual_password_reset",
  "resolvedAt": null,
  "resolvedBy": null,
  "notes": "",
  "userAgent": "RMX3834",
  "appVersion": "1.1.0"
}
```

### **بعد Admin (يضيف newPassword):**

```json
{
  "email": "user@example.com",
  "status": "pending",
  "newPassword": "NewPass123!",  ← Admin أضاف
  ...
}
```

### **بعد Cloud Function:**

```json
{
  "email": "user@example.com",
  "status": "completed",  ← محدّث
  "resolvedAt": 1761045678900,  ← محدّث
  "resolvedBy": "admin",  ← محدّث
  "notes": "Password updated successfully by admin",  ← محدّث
  "passwordUpdated": true,  ← جديد
  "newPassword": [DELETED]  ← محذوف للأمان
}
```

---

## 🔐 **الأمان**

### **لماذا نحذف newPassword؟**

```
⚠️ تخزين كلمات المرور في Firestore غير آمن
✅ Cloud Function تحدّث Firebase Auth فوراً
✅ ثم تحذف الحقل من Firestore
✅ الـ Password موجود فقط في Firebase Auth (مشفّر)
```

---

## 🛠️ **للـ Admin App**

### **في تطبيق Admin، أضف UI:**

```java
// عند ضغط Admin على "Reset Password"
AlertDialog.Builder builder = new AlertDialog.Builder(context);
builder.setTitle("Set New Password");

EditText input = new EditText(context);
input.setHint("Enter new password");
builder.setView(input);

builder.setPositiveButton("Update", (dialog, which) -> {
    String newPassword = input.getText().toString();
    
    // تحديث Firestore
    FirebaseFirestore.getInstance()
        .collection("passwordResetRequests")
        .document(requestId)
        .update("newPassword", newPassword)
        .addOnSuccessListener(aVoid -> {
            Toast.makeText(context, 
                "Password update triggered. Check in a few seconds.", 
                Toast.LENGTH_LONG).show();
        });
});

builder.show();
```

---

## 📱 **Logs & Monitoring**

### **مشاهدة Logs:**

```bash
# في Terminal
firebase functions:log

# أو في Firebase Console
Functions → Logs

# ستظهر:
✅ Admin set new password for: user@example.com
✅ Password updated successfully for: user@example.com
✅ Request marked as completed
✅ Password field removed for security
```

---

## ⚠️ **Troubleshooting**

### **المشكلة: Cloud Function لا تعمل**

```bash
# 1. تحقق من النشر
firebase deploy --only functions

# 2. تحقق من Logs
firebase functions:log

# 3. تحقق من Firestore Rules
# يجب أن يسمح للـ Cloud Function بالكتابة
```

### **المشكلة: "User not found"**

```bash
# User يجب أن يكون مسجّل في Firebase Auth
# Authentication → Users → تحقق من وجود Email
```

---

## 🎯 **الملخص**

### **ما تحتاج عمله:**

```
1. ✅ تثبيت Firebase CLI
2. ✅ firebase init functions
3. ✅ نسخ الكود من functions/index.js
4. ✅ firebase deploy --only functions
5. ✅ اختبار من Firebase Console
```

### **كيف يستخدم Admin:**

```
1. افتح Firestore → passwordResetRequests
2. اختر Document (status: pending)
3. Edit → Add Field: "newPassword"
4. أدخل كلمة المرور الجديدة
5. Save
6. انتظر 2-3 ثوانٍ
7. Cloud Function تعمل تلقائياً ✓
```

---

## 📞 **الدعم**

**الملفات الجاهزة:**

- ✅ `functions/index.js`
- ✅ `functions/package.json`

**في انتظار تأكيدك لنشر Cloud Function!** 🚀

---

**Date:** 2024-09-16
**Version:** 1.0
