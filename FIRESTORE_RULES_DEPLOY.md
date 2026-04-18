# 🚀 Firestore Rules Deployment Guide

## ⚡ نشر القواعد بسرعة

### الخطوة 1: افتح Firebase Console

```
https://console.firebase.google.com/
```

### الخطوة 2: اذهب إلى Firestore Rules

```
Project: kitaby-app
→ Firestore Database
→ Rules (التبويب في الأعلى)
```

### الخطوة 3: انسخ القواعد من الملف

```
ملف: firestore.rules
نسخ المحتوى بالكامل ⬇️
```

### الخطوة 4: الصق في Console

```
1. احذف القواعد القديمة في Console
2. الصق القواعد الجديدة
3. اضغط "Publish"
```

---

## ✅ التأكد من نجاح النشر

بعد الضغط على "Publish":

```
✓ يجب أن تظهر رسالة: "Rules published successfully"
✓ تحقق من وجود القاعدة الجديدة:
  
  match /passwordResetRequests/{requestId} {
    allow create: if true;
    ...
  }
```

---

## 🧪 اختبار بعد النشر

### Test: Admin Reset Request

```bash
1. شغّل التطبيق
2. LoginActivity → "Forgot Password?"
3. اختر "Request manual reset from Admin"
4. أدخل email
5. افتح Logcat:

✅ يجب أن تظهر:
D/LoginActivity: ✅ Reset request saved successfully with ID: xxx

❌ إذا ظهر:
E/LoginActivity: Firestore error code: PERMISSION_DENIED
→ القواعد لم تُنشر بشكل صحيح، جرب مرة أخرى
```

---

## 🔍 تحقق من Firestore Data

بعد اختبار ناجح:

```bash
1. Firebase Console → Firestore Database → Data
2. ابحث عن collection: "passwordResetRequests"
3. يجب أن تجد document مع:
   {
     email: "user@example.com",
     status: "pending",
     requestedAt: timestamp,
     requestType: "manual_password_reset",
     userAgent: "Device Model",
     appVersion: "1.1.0"
   }
```

---

## ⚠️ ملاحظات مهمة

### القواعد الحالية المحفوظة:

- ✅ Books (public read, admin write)
- ✅ Categories (public read, admin write)
- ✅ Orders (user own, admin all)
- ✅ Users (user own, admin all)
- ✅ Carts (user own only)
- ✅ Admins (restricted)
- ✅ Analytics (admin only)
- ✅ Notifications (admin only)

### القاعدة الجديدة المضافة:

- ⭐ **passwordResetRequests**
    - Create: Anyone (حتى غير مسجلين)
    - Read: User own + Admins
    - Update/Delete: Admins only

---

## 🆘 إذا واجهت مشكلة

### المشكلة: "Syntax error in rules"

**الحل:**

1. تأكد من نسخ الملف بالكامل
2. تحقق من عدم وجود أخطاء في النسخ
3. استخدم Editor في Console للتحقق

### المشكلة: "PERMISSION_DENIED" ما زالت تظهر

**الحل:**

1. انتظر 30 ثانية بعد النشر (التحديث يأخذ وقت)
2. أعد تشغيل التطبيق
3. جرّب مرة أخرى

### المشكلة: القواعد القديمة اختفت

**الحل:**

- ✅ لا تقلق! الملف `firestore.rules` يحتوي على جميع القواعد
- ✅ انسخه مرة أخرى والصق في Console

---

## ✅ تأكيد النجاح

عند نجاح كل شيء، يجب أن تحصل على:

```
✓ Firestore Rules منشورة
✓ Admin Reset Request يعمل
✓ Logcat يظهر "✅ Reset request saved"
✓ Firestore Console يظهر document جديد
```

---

**جاهز؟ ابدأ الآن!** 🚀
