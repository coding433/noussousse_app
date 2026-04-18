# ✅ إصلاح مشكلة (Debug) في اسم التطبيق

## المشكلة

اسم التطبيق كان يظهر: **نصوص(debug)** بدلاً من **نصوص**

---

## السبب

في ملف `app/build.gradle.kts`، كان هناك سطر يضيف `(Debug)` تلقائياً للنسخة التجريبية:

```kotlin
debug {
    isDebuggable = true
    versionNameSuffix = "-debug"
    resValue("string", "app_name", "نصوص (Debug)")  // ❌ السبب
}
```

---

## ✅ الحل

تم حذف السطر `resValue("string", "app_name", "نصوص (Debug)")`:

```kotlin
debug {
    isDebuggable = true
    versionNameSuffix = "-debug"
    // ✅ تم حذف السطر
}
```

الآن التطبيق سيستخدم القيمة من `strings.xml`:

```xml
<string name="app_name" translatable="false"> نصوص </string>
```

---

## النتيجة

- ✅ اسم التطبيق الآن: **نصوص**
- ✅ لا توجد كلمة `(Debug)` أو `(debug)`
- ✅ نفس الاسم في نسخة Debug ونسخة Release

---

## اختبر الآن:

1. **Clean & Rebuild المشروع:**
   ```
   Build > Clean Project
   Build > Rebuild Project
   ```

2. **أعد تشغيل التطبيق:**
    - امسح التطبيق من الهاتف (اختياري)
    - شغّل التطبيق من جديد
    - ✅ اسم التطبيق الآن: **نصوص**

---

## ملاحظة

إذا كنت تريد اسم مختلف للنسخة التجريبية (للتمييز)، يمكنك تعديله:

```kotlin
debug {
    resValue("string", "app_name", "نصوص - تجريبي")
}
```

لكن الأفضل حذفه لنفس الاسم في كل الإصدارات.
