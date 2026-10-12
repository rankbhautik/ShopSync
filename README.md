# ShopSync - Two-Shop Product & Inventory Manager

**Two shops. One system. Total control.**

ShopSync is a production-ready Flutter mobile application designed to help shop owners manage products, categories, pricing, and separate inventory across two physical shops in real time.

## 🚀 Features
- **Clean Architecture:** Organized feature-first structure.
- **Firebase Backend:** Secure Authentication and Cloud Firestore for real-time synchronization.
- **State Management:** Fully reactive using `flutter_riverpod`.
- **Multi-Shop Inventory:** Track independent inventory per shop, including atomic stock transfers and adjustments using Firestore transactions.
- **Reporting:** Export product and inventory data to CSV natively.
- **Dynamic Dashboard:** Real-time metrics on product counts, category counts, and low-stock alerts.

## 🛠 Tech Stack
- **Framework:** Flutter / Dart
- **Database:** Firebase Cloud Firestore
- **Authentication:** Firebase Auth
- **Routing:** `go_router`
- **Models:** `freezed` & `json_serializable`

## ⚙️ Setup Instructions

### 1. Flutter Dependencies
Ensure you have Flutter installed, then run:
```bash
flutter pub get
```

### 2. Code Generation
If you modify any domain models or Riverpod providers, you must run the build runner to regenerate the `.g.dart` and `.freezed.dart` files:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Firebase Configuration
Before running the application, you **must** configure Firebase.

1. Install the Firebase CLI: `npm install -g firebase-tools`
2. Log in: `firebase login`
3. Install FlutterFire CLI: `dart pub global activate flutterfire_cli`
4. Configure your project:
```bash
flutterfire configure
```
5. Choose your Firebase project and select the target platforms (iOS/Android). This will automatically generate `lib/firebase_options.dart`.

**Important Firestore Rules:**
Make sure to secure your database so users can only access their own data. Example `firestore.rules`:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 4. Run the App
```bash
flutter run
```

## 🧪 Testing
Run the unit and widget test suite:
```bash
flutter test
```
