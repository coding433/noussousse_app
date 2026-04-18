# 👨‍💼 دليل Admin - إضافة كلمة مرور جديدة

## 📍 **أنت الآن هنا:**

لديك Document في Firestore بهذه البيانات:

```json
{
  "appVersion": "1.1.0",
  "email": "samir@gmail.com",
  "notes": "",
  "requestType": "manual_password_reset",
  "requestedAt": 1761060051678,
  "resolvedAt": null,
  "resolvedBy": null,
  "status": "pending",
  "userAgent": "RMX3834"
}
```

---

## 🎯 **الهدف:**

إضافة حقل `newPassword` حتى تتعرف Cloud Function وتحدّث كلمة المرور تلقائياً.

---

## 📝 **الخطوات (مع صور توضيحية):**

### **الخطوة 1: Edit Document**

في Firebase Console، في نفس الصفحة التي تشاهد فيها البيانات:

```
1. ابحث عن أيقونة القلم ✏️ (Edit) في أعلى اليمين
2. اضغط عليها
```

ستفتح لك نافذة تحرير.

---

### **الخطوة 2: Add Field**

```
1. في النافذة، ستجد زر "+ Add field"
2. اضغط عليه
```

---

### **الخطوة 3: املأ بيانات الحقل الجديد**

ستظهر لك 3 خانات:

```
┌─────────────────────────────────────┐
│ Field name:  newPassword            │
│ Type:        string                 │
│ Value:       Samir2024!             │  ← كلمة المرور الجديدة
└─────────────────────────────────────┘
```

**املأها كالتالي:**

- **Field name:** اكتب بالضبط: `newPassword`
- **Type:** اختر `string` (نص)
- **Value:** اكتب كلمة المرور الجديدة للمستخدم (مثال: `Samir2024!`)

⚠️ **مهم جداً:**

- Field name يجب أن يكون `newPassword` بالضبط (حساس للأحرف الكبيرة/الصغيرة)
- كلمة المرور يجب أن تكون قوية (6 أحرف على الأقل)

---

### **الخطوة 4: Save**

```
1. اضغط زر "Update" أو "Save" في أسفل النافذة
2. انتظر حتى يحفظ
```

---

### **الخطوة 5: مراقبة التغيير**

بعد الحفظ مباشرة:

```
⏰ انتظر 3-5 ثوانٍ...

ثم اضغط F5 (Refresh) على الصفحة
```

---

## ✅ **النتيجة المتوقعة:**

بعد Refresh، يجب أن تجد البيانات تغيرت إلى:

```json
{
  "appVersion": "1.1.0",
  "email": "samir@gmail.com",
  "notes": "Password updated successfully by admin",  ← جديد
  "requestType": "manual_password_reset",
  "requestedAt": 1761060051678,
  "resolvedAt": 1761060055000,  ← جديد (timestamp)
  "resolvedBy": "admin",  ← جديد
  "status": "completed",  ← تغيّر من "pending"
  "userAgent": "RMX3834",
  "passwordUpdated": true  ← جديد
}
```

⚠️ **لاحظ:**

- ✅ `status` تغيّر من `"pending"` إلى `"completed"`
- ✅ `newPassword` اختفى (تم حذفه تلقائياً للأمان)
- ✅ ظهرت حقول جديدة (`resolvedAt`, `resolvedBy`, `passwordUpdated`)

---

## 🧪 **الخطوة 6: اختبار Login**

الآن من التطبيق:

```
1. افتح التطبيق
2. Login Screen
3. Email: samir@gmail.com
4. Password: Samir2024!  ← كلمة المرور الجديدة
5. اضغط Login
```

✅ **يجب أن يعمل!**

---

## ⚠️ **إذا لم يتغير Status:**

### **تشخيص المشكلة:**

**1. تحقق من Logs:**

```bash
# في Terminal
firebase functions:log
```

**2. أو في Firebase Console:**

```
Functions → Logs
```

**ابحث عن:**

```
✅ Admin set new password for: samir@gmail.com
✅ Password updated successfully
```

**إذا وجدت أخطاء:**

```
❌ Error: User not found
```

→ تأكد أن `samir@gmail.com` موجود في **Authentication → Users**

---

## 📊 **الخلاصة:**

```
Step 1: ✏️ Edit Document
  ↓
Step 2: ➕ Add Field (newPassword)
  ↓
Step 3: 💾 Save
  ↓
Step 4: ⏰ انتظر 5 ثوانٍ
  ↓
Step 5: 🔄 Refresh (F5)
  ↓
Step 6: ✅ تحقق من status: "completed"
  ↓
Step 7: 📱 اختبر Login من التطبيق
```

---

## 🎯 **جرّب الآن!**

اتبع الخطوات أعلاه وأخبرني بالنتيجة:

- ✅ هل تغيّر status إلى "completed"؟
- ✅ هل اختفى حقل newPassword؟
- ✅ هل يعمل Login بكلمة المرور الجديدة؟

**في انتظار النتيجة!** 🚀
