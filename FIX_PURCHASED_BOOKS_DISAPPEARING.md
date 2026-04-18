# ✅ إصلاح مشكلة اختفاء الكتب المُهداة - الحل النهائي

## المشكلة الحقيقية

عندما المستخدم يسجل خروج ثم يسجل دخول:

- ❌ الكتب المُهداة تختفي من المكتبة

---

## السبب الجذري

### المشكلة كانت في `LoginActivity.java` - السطر 192:

```java
@Override
private void checkBlockStatusBeforeLogin(String userId) {
    deviceManager.checkBlockStatus(userId, (isBlocked, blockReason) -> {
        if (!isBlocked) {
            updateLoginTimestamps();
            FirebaseHelper.saveUserToFirestore();  // ❌ هذا السطر!
            // ...
        }
    });
}
```

### ماذا يفعل `saveUserToFirestore()`؟

```java
// في FirebaseHelper.java - السطر 50
public static void saveUserToFirestore() {
    String uid = auth.getCurrentUser().getUid();
    String email = auth.getCurrentUser().getEmail();
    saveUserToFirestore("User", email);  // ⬇️ يستدعي
}

// السطر 56
public static void saveUserToFirestore(String name, String email) {
    String uid = auth.getCurrentUser().getUid();
    User user = new User(uid, email, name, new ArrayList<>());  // ❌ purchasedBooks فارغة!

    db.collection(Constants.COLLECTION_USERS)
            .document(uid)
            .set(user)  // ❌ يستبدل المستند بالكامل!
            .addOnSuccessListener(...)
}
```

**المشكلة:**

- `.set(user)` يستبدل المستند بالكامل في Firebase
- `new ArrayList<>()` = قائمة `purchasedBooks` فارغة
- **النتيجة:** يمسح جميع الكتب المُهداة!

---

## السيناريو الكامل

```
1. الأدمن يُهدي book7 للمستخدم
   Firebase: purchasedBooks = ["book7"]
   
2. المستخدم يفتح التطبيق
   ✅ LibraryFragment يقرأ: purchasedBooks = ["book7"]
   ✅ الكتاب يظهر ✅
   
3. المستخدم يسجل خروج
   (لا شيء يحدث)
   
4. المستخدم يسجل دخول
   ⚠️ LoginActivity.checkBlockStatusBeforeLogin()
   ⚠️ FirebaseHelper.saveUserToFirestore()
   ❌ Firebase: purchasedBooks = []  // مُسحت!
   
5. LibraryFragment يقرأ: purchasedBooks = []
   ❌ الكتاب اختفى!
```

---

## ✅ الحل

### حذف السطر الذي يستدعي `saveUserToFirestore()` عند تسجيل الدخول:

```java
// في LoginActivity.java
private void checkBlockStatusBeforeLogin(String userId) {
    deviceManager.checkBlockStatus(userId, (isBlocked, blockReason) -> {
        if (!isBlocked) {
            updateLoginTimestamps();
            // ❌ Removed: FirebaseHelper.saveUserToFirestore();
            Toast.makeText(LoginActivity.this, "Login successful", Toast.LENGTH_SHORT).show();
            Intent intent = new Intent(LoginActivity.this, MainActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
            startActivity(intent);
            finish();
        }
    });
}
```

**لماذا هذا الحل صحيح؟**

- ✅ `saveUserToFirestore()` مطلوب فقط عند **إنشاء حساب جديد**
- ✅ عند تسجيل الدخول، المستخدم **موجود بالفعل** في Firebase
- ✅ نحتاج فقط لتحديث `lastLoginTimestamp` (يتم عبر `updateLoginTimestamps()`)
- ✅ لا حاجة لاستبدال المستند بالكامل

---

## ✅ متى نستخدم `saveUserToFirestore()`؟

### ✅ عند التسجيل (RegisterActivity):

```java
// RegisterActivity.java
user.updateProfile(profileUpdates).addOnCompleteListener(profileTask -> {
    FirebaseHelper.saveUserToFirestore(name, email, whatsappNumber, RegisterActivity.this);
    // ✅ صحيح - مستخدم جديد
});
```

### ❌ عند تسجيل الدخول (LoginActivity):

```java
// LoginActivity.java
// ❌ لا تستخدم: FirebaseHelper.saveUserToFirestore();
// ✅ استخدم فقط: updateLoginTimestamps();
```

---

## الاختبار

### بعد التعديل:

```
1. اهدِ كتاب للمستخدم من تطبيق الأدمن
   Firebase: purchasedBooks = ["book7"]
   
2. المستخدم يفتح التطبيق
   ✅ الكتاب يظهر
   
3. المستخدم يسجل خروج ودخول
   ✅ Firebase: purchasedBooks = ["book7"]  // لم يُمسح!
   
4. المستخدم يفتح المكتبة
   ✅ الكتاب ما زال موجود ✅
```

---

## ملخص الإصلاحات

| الملف | السطر | التعديل | الحالة |
|------|-------|---------|--------|
| `LoginActivity.java` | 192 | حذف `FirebaseHelper.saveUserToFirestore()` | ✅ |

---

## الفرق بين `.set()` و `.update()`

### `.set()` - يستبدل المستند بالكامل:

```java
// ❌ يمسح جميع الحقول غير المذكورة
db.collection("users").document(uid)
    .set(newUser)  // purchasedBooks = []
```

### `.update()` - يحدث حقول محددة فقط:

```java
// ✅ يحدث فقط الحقول المذكورة
Map<String, Object> updates = new HashMap<>();
updates.put("lastLoginTimestamp", currentTime);

db.collection("users").document(uid)
    .update(updates)  // purchasedBooks يبقى كما هو
```

---

## النتيجة النهائية

**✅ الآن الكتب المُهداة تبقى حتى بعد تسجيل الخروج والدخول!**

**الحل كان:**

1. ❌ إزالة `saveUserToFirestore()` من LoginActivity
2. ✅ استخدام `updateLoginTimestamps()` فقط (يستخدم `.update()`)

** المشكلة محلولة بالكامل!**