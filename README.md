# Social Post App (Flutter + Firebase + BLoC)

A modern Flutter application that allows users to **sign up**, **log in**, and **post messages** in real time using **Firebase Authentication**, **Cloud Firestore**, and **BLoC Architecture**.

---

## 🧠 Overview

**Social Post App** demonstrates a clean, scalable Flutter architecture built on the **BLoC pattern**, integrated with **Firebase** for real-time data handling.  
Users can authenticate via email/password, create posts, and view posts in a live feed synced across all users.

---

## ✨ Core Features

- 🔐 **User Authentication** (Signup & Login using Firebase)
- 💬 **Post Creation** with user info and timestamps
- 🔄 **Real-Time Feed** via Firestore streams
- 🧠 **BLoC Pattern** for clean separation of concerns
- 🚫 **Form Validation** for blank fields and invalid inputs
- ☁️ **Cloud Function Trigger** on new post creation


## How to run
1. Clone repository
2. Install dependencies: `flutter pub get`
3. Configure Firebase:
    - Create Firebase project
    - Enable Email/Password auth
    - Add Android app and download `google-services.json` -> place in `android/app/`
    - Run `flutterfire configure` to generate `lib/firebase_options.dart` (or add manually)
4. Run:
    - `flutter run` (development)
    - `flutter build apk --release` (generate APK at `build/app/outputs/flutter-apk/app-release.apk`)

## Project structure
- `lib/`:
    - `repositories/` — Firebase wrappers
    - `blocs/` — AuthBloc, PostsBloc
    - `data/models/` — Post
    - `ui/` — Login, SignUp, Home
    - `main.dart`

## Cloud Function (optional)
`functions/src/index.ts` — Firestore onCreate trigger for `posts` collection.

## Notes
- Use Firestore rules to secure write access.
- For production, update authentication error handling and add input validation (length checks, profanity filters, rate limits).

📱 APK Download
