# Google Play Console & AdMob Policy Compliance Audit

**Date:** December 8, 2025  
**App:** QuickList (com.rimaoli.quicklist.dev)  
**Audit Type:** Play Store & AdMob Policy Violations

---

## 🚨 CRITICAL VIOLATIONS FOUND

### 1. ❌ **MISSING INTERNET PERMISSION** (CRITICAL)

**Severity:** 🔴 **BLOCKER** - App will crash/ads won't load

**Issue:**

- AdMob requires `INTERNET` permission to load ads
- AndroidManifest.xml has NO internet permission declared
- Ads will fail to load without this permission

**Current Permissions:**

```xml
✅ POST_NOTIFICATIONS
✅ SCHEDULE_EXACT_ALARM
✅ USE_EXACT_ALARM
✅ RECEIVE_BOOT_COMPLETED
✅ VIBRATE
✅ WAKE_LOCK
❌ INTERNET (MISSING!)
❌ ACCESS_NETWORK_STATE (MISSING - recommended)
```

**Impact:**

- ❌ Banner ads won't load
- ❌ Native ads won't load
- ❌ Interstitial ads won't load
- ❌ Rewarded ads won't load
- ❌ App Open ads won't load
- ❌ Play Store will reject app

**Required Fix:**

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- REQUIRED for AdMob -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>

    <!-- Existing permissions -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <!-- ... -->
```

---

### 2. ❌ **NO USER CONSENT IMPLEMENTATION (GDPR/CCPA)** (CRITICAL)

**Severity:** 🔴 **BLOCKER** - Legal compliance issue

**Issue:**

- No UMP (User Messaging Platform) SDK implementation
- No consent dialog shown to users
- Required by GDPR (EU), CCPA (California), and AdMob policies

**Impact:**

- ❌ Legal violations (GDPR fines up to €20M or 4% revenue)
- ❌ CCPA fines up to $7,500 per violation
- ❌ AdMob account suspension risk
- ❌ Play Store may remove app
- ❌ Cannot serve personalized ads in EU/EEA

**Required Fix:**

1. Add UMP SDK implementation
2. Show consent dialog on first launch
3. Store consent status
4. Allow users to change consent in settings

**Code Required:**

```dart
// Add to main.dart
Future<void> _requestConsent() async {
  final params = ConsentRequestParameters();

  ConsentInformation.instance.requestConsentInfoUpdate(
    params,
    () async {
      if (await ConsentInformation.instance.isConsentFormAvailable()) {
        _loadConsentForm();
      }
    },
    (error) {
      debugPrint('Consent error: ${error.message}');
    },
  );
}

Future<void> _loadConsentForm() async {
  ConsentForm.loadConsentForm(
    (ConsentForm consentForm) async {
      var status = await ConsentInformation.instance.getConsentStatus();
      if (status == ConsentStatus.required) {
        consentForm.show((FormError? formError) {
          _loadConsentForm(); // Reload if needed
        });
      }
    },
    (formError) {
      debugPrint('Form error: ${formError.message}');
    },
  );
}
```

---

### 3. ❌ **NO PRIVACY POLICY** (CRITICAL)

**Severity:** 🔴 **BLOCKER** - Play Store requirement

**Issue:**

- No privacy policy URL in app
- No privacy policy in Play Store listing
- Required by both Play Store and AdMob policies

**Play Store Requirements:**

- Must have publicly accessible privacy policy URL
- Must cover data collection and usage
- Must explain third-party services (AdMob)
- Must be in Play Store listing

**Required Content:**

```
Privacy Policy must include:
1. Information We Collect
   - Task data (stored locally)
   - Gamification data (XP, achievements)
   - Device advertising ID (AdMob)
   - App usage data (AdMob)

2. How We Use Information
   - Task management functionality
   - Displaying personalized ads
   - Analytics and app improvement

3. Third-Party Services
   - Google AdMob (advertising)
   - Link to Google's privacy policy

4. Data Retention
   - Local data stored until user deletes
   - Ad-related data per Google's policies

5. User Rights (GDPR/CCPA)
   - Right to access data
   - Right to delete data
   - Right to opt out of personalized ads
   - Right to withdraw consent

6. Children's Privacy (COPPA)
   - App not directed at children under 13
   - Statement of compliance

7. Contact Information
   - Developer email
   - How to contact for privacy concerns

8. Policy Updates
   - How users will be notified of changes
```

**Actions Required:**

1. Create comprehensive privacy policy
2. Host on accessible URL (GitHub Pages, website, etc.)
3. Add link to app settings screen
4. Add URL to Play Store listing

---

### 4. ⚠️ **SENSITIVE PERMISSIONS WITHOUT JUSTIFICATION**

**Severity:** 🟡 **WARNING** - May trigger review

**Issue:**

- `SCHEDULE_EXACT_ALARM` is a sensitive permission
- `USE_EXACT_ALARM` is a sensitive permission
- Play Store requires justification for these

**Current Usage:**

- Used for task reminder notifications
- Legitimate use case ✅

**Required Action:**
When submitting to Play Store, you'll need to provide:

```
Justification for SCHEDULE_EXACT_ALARM:
"This permission is required to deliver precise task reminder
notifications at user-specified times for deadline management.
Users set specific times for task reminders, and the app must
deliver notifications at exactly those times to be effective."
```

**Note:** This is acceptable use, but Play Store will ask for explanation.

---

### 5. ⚠️ **AD PLACEMENT DENSITY** (BORDERLINE)

**Severity:** 🟡 **WARNING** - May affect approval

**Issue:**

- Category screen has 4 ads (2 banners + 2 native)
- Maximum recommended is 2-3 ads per screen

**Current Placement:**

```
Home Screen:         1 banner (bottom)           ✅ OK
Category List:       1 banner (top)              ✅ OK
                     1 native (in category list) ✅ OK
                     1 banner (bottom)           ✅ OK
                     1 native (in task list)     ⚠️ BORDERLINE
Calendar Screen:     1 banner (bottom)           ✅ OK
Add Task Screen:     1 banner (bottom)           ⚠️ QUESTIONABLE
Gamification Screen: 2 native ads                ✅ OK
```

**Recommendations:**

1. **Remove banner from Add Task screen** - Interferes with form submission
2. **Consider removing one ad from Category screen** - Either top banner or one native ad
3. **Never have more than 3 ads on one screen**

---

### 6. ⚠️ **MISSING CONTENT RATING**

**Severity:** 🟡 **WARNING** - Play Store requirement

**Issue:**

- No content rating questionnaire completed
- Required before publishing to Play Store

**Required Action:**
Complete content rating questionnaire in Play Console:

- Age appropriateness
- Violence level
- Mature content
- Gambling
- Ads presence
- User-generated content

**For QuickList:**

- Likely rating: **Everyone** or **Everyone 10+**
- Contains ads: **YES**
- No violence, mature content, or gambling
- No user-generated content
- No social features

---

### 7. ⚠️ **NO DATA SAFETY DISCLOSURE**

**Severity:** 🟡 **WARNING** - Play Store requirement

**Issue:**

- Data Safety section not filled in Play Console
- Required since 2022

**Required Disclosures:**

```yaml
Data Collection:
  Personal Info:
    - None collected ✅

  Device or other IDs:
    - Advertising ID ✅
    Purpose: Advertising
    Shared with: Google AdMob

  App Activity:
    - App interactions (task completion)
    Purpose: App functionality
    Stored: On device only ✅

  App info and performance:
    - Crash logs (if using Firebase Crashlytics)
    - Diagnostics
```

---

### 8. ⚠️ **TARGET SDK VERSION**

**Severity:** 🟡 **WARNING** - Play Store requirement

**Issue:**

- Play Store requires apps to target recent Android API levels
- Current targetSdk should be 34 (Android 14) minimum

**Check:**

```kotlin
// In android/app/build.gradle.kts
targetSdk = flutter.targetSdkVersion  // Should be 34+
```

**Action:**

- Verify targetSdk is set to 34 or higher
- If lower, update in `local.properties` or Flutter config

---

### 9. ✅ **APP BUNDLE REQUIREMENT**

**Status:** Must verify

**Play Store Requirement:**

- Must upload Android App Bundle (.aab), not APK
- Required since August 2021

**Build Command:**

```bash
flutter build appbundle --release
```

**File Location:**

```
build/app/outputs/bundle/release/app-release.aab
```

---

### 10. ⚠️ **KEYSTORE SECURITY**

**Severity:** 🟡 **WARNING** - Security issue

**Issue:**

- Keystore credentials in `key.properties` file
- This file is in repository (potential security risk)

**Current key.properties:**

```properties
storePassword=Wednesday365365
keyPassword=Wednesday365365
keyAlias=upload
storeFile=../app/upload-keystore.jks
```

**Recommendations:**

1. Add `key.properties` to `.gitignore` ✅
2. Never commit keystore file (.jks) to repository
3. Keep secure backup of keystore (losing it = can't update app)
4. Consider using environment variables for CI/CD

---

## 📋 COMPLIANCE CHECKLIST

### Before Play Store Submission:

#### Critical (MUST FIX):

- [ ] **Add INTERNET permission to AndroidManifest.xml**
- [ ] **Add ACCESS_NETWORK_STATE permission**
- [ ] **Implement UMP SDK for user consent**
- [ ] **Create and publish privacy policy**
- [ ] **Add privacy policy link to app**
- [ ] **Add privacy policy URL to Play Store listing**
- [ ] **Complete Data Safety disclosure**
- [ ] **Complete Content Rating questionnaire**

#### High Priority (SHOULD FIX):

- [ ] **Remove banner ad from Add Task screen**
- [ ] **Reduce ads on Category screen (max 3 total)**
- [ ] **Verify targetSdk is 34+**
- [ ] **Test app with real ad IDs**
- [ ] **Prepare permission justifications**

#### Medium Priority (RECOMMENDED):

- [ ] Add app screenshots (minimum 2)
- [ ] Add feature graphic (1024x500)
- [ ] Write compelling app description
- [ ] Add app icon (512x512)
- [ ] Set up Google Play Developer account
- [ ] Prepare promotional materials

#### Security:

- [ ] **Verify .gitignore includes key.properties**
- [ ] **Backup keystore file securely**
- [ ] **Document keystore credentials separately**
- [ ] Never commit keystore to repository

---

## 🔧 IMMEDIATE FIXES REQUIRED

### Fix #1: Add Internet Permissions

**File:** `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- REQUIRED for AdMob -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>

    <!-- Permissions for notifications -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <!-- ... rest of manifest -->
```

### Fix #2: Implement UMP SDK

**See:** ADMOB_POLICY_COMPLIANCE_REPORT.md for full implementation

### Fix #3: Create Privacy Policy

**Required Sections:**

1. Data Collection
2. Data Usage
3. Third-Party Services (AdMob)
4. User Rights
5. Children's Privacy
6. Contact Information

### Fix #4: Optimize Ad Placement

**Remove from add_task_screen.dart:**

```dart
// Comment out or remove:
// const BannerAdWidget(screenId: 'add_task_screen'),
```

---

## 📊 RISK ASSESSMENT

### Play Store Rejection Risk: 🔴 **HIGH**

**Reasons:**

- Missing INTERNET permission (app won't work)
- No privacy policy (mandatory)
- No data safety disclosure (mandatory)
- No content rating (mandatory)
- No UMP consent implementation (GDPR/CCPA)

### AdMob Account Suspension Risk: 🔴 **HIGH**

**Reasons:**

- No user consent implementation
- Privacy policy missing
- May violate EU User Consent Policy

### Legal Compliance Risk: 🔴 **HIGH**

**Reasons:**

- GDPR non-compliance
- CCPA non-compliance
- No privacy policy

---

## 🎯 PRIORITY ACTION PLAN

### Phase 1: Critical Fixes (1-2 days)

**Priority:** 🔴 **BLOCKER**

1. **Add INTERNET permission** (5 minutes)

   - Edit AndroidManifest.xml
   - Add INTERNET and ACCESS_NETWORK_STATE

2. **Create Privacy Policy** (2-3 hours)

   - Write comprehensive policy
   - Host on public URL
   - Add link to app settings

3. **Implement UMP SDK** (4-6 hours)
   - Add consent request on launch
   - Show consent form
   - Store consent status
   - Add settings option

### Phase 2: Play Store Requirements (1 day)

**Priority:** 🟡 **HIGH**

1. **Complete Data Safety** (1 hour)

   - Fill out questionnaire in Play Console
   - Declare AdMob data collection

2. **Complete Content Rating** (30 minutes)

   - Fill questionnaire
   - Get rating certificate

3. **Optimize Ad Placement** (1 hour)
   - Remove add task banner
   - Reduce category screen ads

### Phase 3: Testing & Validation (1 day)

**Priority:** 🟡 **HIGH**

1. **Test with production ad IDs**
2. **Test consent flow**
3. **Test all permissions**
4. **Test on multiple devices**
5. **Verify no crashes**

### Phase 4: Submission Prep (1 day)

**Priority:** 🟢 **MEDIUM**

1. Create screenshots
2. Write store listing
3. Prepare promotional materials
4. Build release AAB
5. Submit for review

---

## 📚 REFERENCE DOCUMENTATION

### Google Play Policies:

- [Play Console Requirements](https://support.google.com/googleplay/android-developer/answer/9859455)
- [Data Safety Section](https://support.google.com/googleplay/android-developer/answer/10787469)
- [Content Rating](https://support.google.com/googleplay/android-developer/answer/9859673)
- [Privacy Policy Requirement](https://support.google.com/googleplay/android-developer/answer/9857753)

### AdMob Policies:

- [AdMob Program Policies](https://support.google.com/admob/answer/6128543)
- [EU User Consent Policy](https://www.google.com/about/company/user-consent-policy/)
- [UMP SDK Integration](https://developers.google.com/admob/ump/android/quick-start)

### GDPR/CCPA:

- [GDPR Requirements](https://gdpr.eu/)
- [CCPA Compliance](https://oag.ca.gov/privacy/ccpa)

---

## ✅ SUMMARY

### Critical Violations:

1. ❌ **No INTERNET permission** - Ads won't work
2. ❌ **No UMP consent** - GDPR/CCPA violation
3. ❌ **No privacy policy** - Play Store requirement

### High Priority:

4. ⚠️ **Data Safety disclosure** - Play Store requirement
5. ⚠️ **Content rating** - Play Store requirement
6. ⚠️ **Ad placement optimization** - User experience

### Estimated Fix Time:

- **Critical fixes:** 1-2 days
- **All fixes:** 4-5 days
- **Ready for submission:** 5-7 days

### Current Status:

🔴 **NOT READY FOR PRODUCTION**

### After Fixes:

✅ **READY FOR PLAY STORE SUBMISSION**

---

**Audit completed:** December 8, 2025  
**Next review:** After critical fixes implemented  
**Auditor:** AI Assistant
