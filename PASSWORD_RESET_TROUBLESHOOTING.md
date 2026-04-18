# 🔒 Password Reset Troubleshooting Guide

## تشخيص مشكلة "نسيت كلمة المرور"

### 🎯 الميزات المطبّقة:

#### ✅ الخيار الأول: إرسال Email عبر Firebase Auth

- يستخدم `FirebaseAuth.sendPasswordResetEmail()`
- يرسل رابط إعادة تعيين كلمة المرور إلى Gmail المستخدم

#### ✅ الخيار الثاني: طلب إعادة تعيين يدوي من Admin

- يحفظ الطلب في Firestore collection: `passwordResetRequests`
- Admin يمكنه مراجعة الطلبات وإعادة تعيين كلمة المرور يدوياً

---

## 🔍 لماذا قد لا يعمل Password Reset؟

### السبب 1: إعدادات Firebase Console غير مفعّلة ❌

**الحل:**

1. افتح [Firebase Console](https://console.firebase.google.com/)
2. اذهب إلى **Authentication** → **Templates**
3. تأكد من تفعيل **Password reset** template
4. تحقق من اللغات المدعومة (Arabic/English)

### السبب 2: User غير موجود في Firebase Auth

**الحل:**

- الـ email يجب أن يكون مسجّل في Firebase Authentication
- تحقق من قسم **Authentication** → **Users**

### السبب 3: Email في Spam Folder

**الحل:**

- تحقق من مجلد Spam/Junk في Gmail
- أضف `noreply@kitaby-app.firebaseapp.com` للـ safe senders

### السبب 4: Rate Limiting (كثرة الطلبات)

**الحل:**

- Firebase يحد الطلبات لنفس الـ IP
- انتظر 5-10 دقائق قبل المحاولة مرة أخرى

### السبب 5: Network Issues

**الحل:**

- تحقق من اتصال الإنترنت
- جرّب على WiFi مختلف

---

## 🧪 اختبار الميزة:

### Test Case 1: Firebase Email Reset

```
1. افتح تطبيق
2. اضغط "Forgot Password?"
3. اختر "Send reset link via Email"
4. أدخل email مسجّل
5. افتح Logcat واقرأ:
   - "=== PASSWORD RESET DIAGNOSTIC ==="
   - "✅ Password reset email sent successfully" → نجح
   - "❌ Failed..." → فشل (اقرأ error code)
6. افتح Gmail وتحقق من الرسالة
```

### Test Case 2: Admin Manual Reset

```
1. افتح تطبيق
2. اضغط "Forgot Password?"
3. اختر "Request manual reset from Admin"
4. أدخل email
5. افتح Firebase Console → Firestore
6. تحقق من collection "passwordResetRequests"
7. يجب أن تجد document جديد مع:
   - email: "user@example.com"
   - status: "pending"
   - requestedAt: timestamp
```

---

## 🛠️ الكود المحسّن:

### الملفات المعدّلة:

- ✅ `LoginActivity.java` - Dialog محسّن + خيارين
- ✅ `RegisterActivity.java` - Phone validation محسّن
- ✅ `activity_register.xml` - Checkbox أكبر وأوضح
- ✅ `strings.xml` - Strings جديدة للميزات

### البنية الجديدة في Firestore:

```
passwordResetRequests/
  ├── {documentId}/
      ├── email: "user@example.com"
      ├── requestedAt: 1704067200000
      ├── status: "pending" | "completed" | "rejected"
      ├── requestType: "manual_password_reset"
      ├── resolvedAt: null | timestamp
      ├── resolvedBy: null | "admin_email"
      └── notes: ""
```

---

## 📱 Logcat للتشخيص:

عند الضغط على "Send reset email"، ابحث في Logcat عن:

```
D/LoginActivity: === PASSWORD RESET DIAGNOSTIC ===
D/LoginActivity: Attempting to send password reset email to: user@example.com
D/LoginActivity: Firebase Auth instance: Initialized
D/LoginActivity: Current user: Not logged in
D/LoginActivity: ✅ Password reset email sent successfully
D/LoginActivity: === PASSWORD RESET DIAGNOSTIC END ===
```

إذا فشل:

```
E/LoginActivity: ❌ Failed to send password reset email
E/LoginActivity: Firebase Auth Error Code: ERROR_USER_NOT_FOUND
E/LoginActivity: User not found in Firebase Auth
```

---

## 🎯 الخطوات التالية لإصلاح المشكلة:

### إذا كان الكود لا يعمل على الإطلاق:

1. ✅ تحقق من Firebase Console → Authentication → Settings
2. ✅ تأكد من Email/Password provider enabled
3. ✅ تحقق من Email templates configured
4. ✅ جرّب إنشاء user جديد أولاً ثم طلب reset

### إذا كان Email لا يصل:

1. ✅ تحقق من Spam folder
2. ✅ تحقق من Firebase Console → Authentication → Templates → Password reset
3. ✅ تأكد من Domain في whitelist

### إذا كنت تريد SMTP مخصص (optional):

1. يمكن استخدام Cloud Function + Nodemailer
2. أو تكامل مع SendGrid/Mailgun
3. لكن Firebase Auth Email كافٍ للبداية

---

## 📞 الدعم:

- Email: nosousreader@gmail.com
- GitHub Issues: [create issue]

**آخر تحديث:** {{ current_date }}
