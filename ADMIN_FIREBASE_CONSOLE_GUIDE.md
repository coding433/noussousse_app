# 🔐 Admin Guide: Managing Password Reset Requests

## 📋 الهدف

دليل للـ **Admin** لإدارة طلبات "نسيت كلمة المرور" من **Firebase Console** مباشرة.

---

## 🎯 كيف يعمل النظام؟

### **User Side (في هذا التطبيق):**

```
1. User → "Forgot Password?" → Option 2 (Request Admin Reset)
   ↓
2. Request يُحفظ في Firestore
   Collection: "passwordResetRequests"
   Status: "pending"
```

### **Admin Side (في Firebase Console أو تطبيق Admin منفصل):**

```
1. Admin → يفتح Firebase Console
   ↓
2. Firestore Database → "passwordResetRequests"
   ↓
3. يشوف جميع الطلبات بـ status: "pending"
   ↓
4. يرسل Password Reset Email يدوياً
   ↓
5. يحدث status إلى "completed"
```

---

## 📊 بنية البيانات في Firestore

### **Collection: `passwordResetRequests`**

```json
{
  "email": "user@example.com",
  "requestedAt": 1761038437276,
  "status": "pending",          // ← Admin يغيره
  "requestType": "manual_password_reset",
  "resolvedAt": null,            // ← Admin يحدثه
  "resolvedBy": null,            // ← Admin يضيف email الخاص به
  "notes": "",                   // ← Admin يضيف ملاحظات
  "userAgent": "RMX3834",
  "appVersion": "1.1.0"
}
```

---

## 🔧 **خطوات Admin لإدارة الطلبات من Firebase Console**

### **الطريقة 1: من Firebase Console (Web)**

#### **1️⃣ فتح Firebase Console:**

```
https://console.firebase.google.com/
→ Project: kitaby-app
→ Firestore Database
→ Data
→ Collection: "passwordResetRequests"
```

#### **2️⃣ عرض الطلبات المعلقة:**

```
Filter by: status == "pending"
```

#### **3️⃣ معالجة طلب:**

**Option A: إرسال Reset Email من Firebase Authentication:**

```
1. انسخ email المستخدم من Document
   مثال: "kikou@gmail.com"

2. اذهب إلى: Authentication → Users

3. ابحث عن User بالـ email

4. اضغط على ⋮ (three dots) → Reset password

5. Firebase يرسل email تلقائياً

6. ارجع لـ Firestore → Document → Edit:
   - status: "completed"
   - resolvedAt: (current timestamp)
   - resolvedBy: "admin@example.com"
   - notes: "Password reset email sent manually"
```

**Option B: حذف User وإعادة إنشائه (غير موصى به):**

```
1. Authentication → Users → Delete user
2. User يسجل من جديد
```

---

## 🚀 **خطوات Admin لإدارة من تطبيق Admin منفصل**

### **في تطبيق Admin (Android/Web):**

#### **1️⃣ قراءة الطلبات:**

```java
// في تطبيق Admin
FirebaseFirestore.getInstance()
    .collection("passwordResetRequests")
    .whereEqualTo("status", "pending")
    .orderBy("requestedAt", Query.Direction.DESCENDING)
    .get()
    .addOnSuccessListener(querySnapshot -> {
        for (DocumentSnapshot doc : querySnapshot) {
            String email = doc.getString("email");
            String device = doc.getString("userAgent");
            long timestamp = doc.getLong("requestedAt");
            
            // عرض في RecyclerView
        }
    });
```

#### **2️⃣ إرسال Reset Email:**

```java
// عند ضغط Admin على "Reset Password"
FirebaseAuth.getInstance()
    .sendPasswordResetEmail(email)
    .addOnSuccessListener(aVoid -> {
        // تحديث status في Firestore
        updateRequestStatus(documentId, "completed");
    });
```

#### **3️⃣ تحديث Status:**

```java
private void updateRequestStatus(String documentId, String status) {
    Map<String, Object> updates = new HashMap<>();
    updates.put("status", status);
    updates.put("resolvedAt", System.currentTimeMillis());
    updates.put("resolvedBy", FirebaseAuth.getInstance().getCurrentUser().getEmail());
    updates.put("notes", "Password reset email sent by admin");
    
    FirebaseFirestore.getInstance()
        .collection("passwordResetRequests")
        .document(documentId)
        .update(updates);
}
```

---

## 📱 **Firestore Security Rules (مهم!)**

تأكد من أن Admin لديه صلاحيات:

```javascript
// في firestore.rules
match /passwordResetRequests/{requestId} {
  // Anyone can create (for users who forgot password)
  allow create: if true;
  
  // Only admins can read/update/delete
  allow read, update, delete: if request.auth != null && 
    exists(/databases/$(database)/documents/admins/$(request.auth.uid));
}
```

---

## 🔍 **Queries مفيدة للـ Admin**

### **1. جميع الطلبات المعلقة:**

```javascript
// في Firebase Console → Firestore
Collection: passwordResetRequests
Filter: status == "pending"
Order by: requestedAt DESC
```

### **2. الطلبات المكتملة:**

```javascript
Filter: status == "completed"
Order by: resolvedAt DESC
```

### **3. الطلبات المرفوضة:**

```javascript
Filter: status == "rejected"
```

### **4. الطلبات لـ User محدد:**

```javascript
Filter: email == "user@example.com"
```

---

## 📊 **Dashboard للـ Admin (اختياري)**

### **في تطبيق Admin، يمكن إضافة:**

```
┌─────────────────────────────────────┐
│  Password Reset Requests Dashboard  │
├─────────────────────────────────────┤
│                                     │
│  📊 Statistics:                     │
│  • Pending: 5 requests              │
│  • Completed Today: 12              │
│  • Rejected: 2                      │
│                                     │
│  📋 Recent Requests:                │
│  ┌─────────────────────────────┐   │
│  │ kikou@gmail.com             │   │
│  │ Device: RMX3834             │   │
│  │ 15/01/2024 14:30           │   │
│  │ [Reset] [Reject]           │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

---

## ✅ **Status Lifecycle**

```
User Request
     ↓
  "pending"  ← Initial status
     ↓
Admin Action:
     ├─→ "completed"  (Email sent successfully)
     ├─→ "rejected"   (Request denied)
     └─→ "cancelled"  (User cancelled)
```

---

## 📞 **Integration مع تطبيق Admin منفصل**

### **في تطبيق Admin:**

```java
// Activity: AdminPasswordResetActivity.java
// Adapter: PasswordResetAdapter.java
// Model: PasswordResetRequest.java (same as user app)

// RecyclerView يعرض:
// 1. Email
// 2. Request Date
// 3. Device Info
// 4. Status
// 5. Buttons: [Reset Password] [Reject]
```

---

## 🎯 **الملخص**

### **ما هو موجود في تطبيق User:**

- ✅ "Forgot Password?" → Option 2
- ✅ Request يُحفظ في Firestore
- ✅ Status: "pending"

### **ما يحتاج Admin عمله:**

1. ✅ فتح Firebase Console → Firestore
2. ✅ عرض الطلبات pending
3. ✅ إرسال Reset Email من Authentication
4. ✅ تحديث status إلى "completed"

### **أو من تطبيق Admin منفصل:**

1. ✅ عرض الطلبات في RecyclerView
2. ✅ زر "Reset Password" يرسل Email
3. ✅ تحديث Firestore تلقائياً

---

## 📝 **Notes للـ Admin App Development**

عند تطوير تطبيق Admin منفصل، ستحتاج:

```
1. AdminPasswordResetActivity.java
2. PasswordResetAdapter.java
3. PasswordResetRequest.java (Data Model)
4. activity_admin_password_reset.xml
5. item_password_reset_request.xml
```

**أو:**

- Web Dashboard باستخدام React/Vue + Firebase Admin SDK

---

**Status:** ✅ الطلبات تُحفظ في Firestore جاهزة للإدارة من Admin
**Next:** Admin يدير من Firebase Console أو تطبيق منفصل

---

**Date:** 2024-09-16
**Version:** 1.0
