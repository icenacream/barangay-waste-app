# BrgyWaste — Barangay Smart Waste Collection Scheduling and Monitoring System

A Flutter + Firebase application for barangay waste collection management. Built with a mobile app for residents and a web-based admin dashboard for sanitation officers.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter (Dart) |
| Admin Dashboard | Flutter Web |
| Backend | Firebase (Firestore, Auth) |
| Hosting | Vercel |
| UI Design | Figma |

---

## Prerequisites

Before you can run this project, make sure you have the following installed:

### 1. Flutter SDK
- Download from: https://docs.flutter.dev/get-started/install/windows
- Minimum version: Flutter 3.x
- After installing, run `flutter doctor` to verify the setup

### 2. Dart SDK
- Comes bundled with Flutter — no separate installation needed

### 3. Node.js (LTS version)
- Download from: https://nodejs.org
- Click the **LTS** button (left side)
- Required for Firebase CLI and Vercel CLI

### 4. Git
- Download from: https://git-scm.com/downloads
- Required for version control and cloning the repository

### 5. Firebase CLI
- After installing Node.js, run:
```bash
npm install -g firebase-tools
```

### 6. FlutterFire CLI
- After installing Flutter and Node.js, run:
```bash
dart pub global activate flutterfire_cli
```
- Then add it to your PATH:
```
C:\Users\<YourUsername>\AppData\Local\Pub\Cache\bin
```

### 7. Android Studio (for Android testing only)
- Download from: https://developer.android.com/studio
- Only needed if you want to run the app on an Android device or emulator
- After installing, run: `flutter doctor --android-licenses` and press `y` to accept all

### 8. Visual Studio Code (recommended editor)
- Download from: https://code.visualstudio.com

---

## VS Code Extensions

Install these extensions inside VS Code (`Ctrl+Shift+X`):

| Extension | Publisher | Purpose |
|---|---|---|
| Flutter | Dart Code | Flutter support and debugging |
| Dart | Dart Code | Dart language support |
| Firebase Explorer | Firebase | Firebase integration |
| Pubspec Assist | Jeroen Meijer | Easier pubspec.yaml editing |
| Error Lens | Alexander | Inline error highlighting |
| GitLens | GitKraken | Enhanced Git integration |

---

## Windows-Specific Setup

### Enable Developer Mode
Required for Flutter symlink support:
```
Settings → System → Developer Mode → Toggle ON
```
Or run in PowerShell:
```bash
start ms-settings:developers
```

### Add Flutter and Pub Cache to PATH
Add these to your system PATH environment variable:
```
C:\flutter\bin
C:\Users\<YourUsername>\AppData\Local\Pub\Cache\bin
```

---

## Getting Started

### 1. Clone the repository
```bash
git clone https://github.com/your-username/barangay_waste_app.git
cd barangay_waste_app
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Set up Firebase
```bash
firebase login
flutterfire configure
```
- Select the `barangay-waste-app` Firebase project when prompted
- Select **Web** and **Android** platforms

> **Note:** `lib/firebase_options.dart` is gitignored for security.
> Each developer must run `flutterfire configure` to generate their own copy.

### 4. Run on Chrome (web)
```bash
flutter run -d chrome
```

### 5. Run on Android (requires Android Studio)
```bash
flutter run
```

---

## Firebase Setup

This project uses the following Firebase services:

| Service | Purpose |
|---|---|
| Firebase Authentication | User login and registration |
| Cloud Firestore | Database for users, schedules, announcements, requests |

### Firestore Collections

| Collection | Description |
|---|---|
| `users` | Resident and admin profiles |
| `settings` | Default collection schedule per barangay |
| `exceptions` | Cancelled or rescheduled collection days |
| `announcements` | Barangay announcements |
| `requests` | Resident messages and requests to admin |

### Creating an Admin Account
1. Go to Firebase Console → **Authentication** → **Users** → **Add user**
2. Enter email and password for the admin
3. Copy the generated UID
4. Go to **Firestore** → `users` collection → **Add document**
5. Use the UID as the Document ID and set `role` to `admin`

### Creating a Resident Account
Residents can register directly through the app's Register screen.

---

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Auto-generated Firebase config (gitignored)
├── models/
│   ├── user_model.dart
│   ├── schedule_model.dart      # SettingsModel + ExceptionModel
│   ├── announcement_model.dart
│   └── request_model.dart
├── services/
│   ├── auth_service.dart
│   ├── schedule_service.dart
│   └── announcement_service.dart
├── providers/
│   └── auth_provider.dart
├── router/
│   └── app_router.dart          # Role-based routing
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── resident/
│   │   ├── resident_shell.dart  # Bottom nav shell
│   │   ├── home_screen.dart
│   │   ├── schedule_screen.dart
│   │   ├── announcements_screen.dart
│   │   ├── request_screen.dart
│   │   └── profile_screen.dart
│   └── admin/
│       ├── (still developing...)
```

---

## Building for Web (Deployment)

```bash
flutter build web
git add build/web -f
git commit -m "build: rebuild web"
git push
```

Vercel automatically redeploys on every push.

---

## User Roles

| Role | Access | Platform |
|---|---|---|
| Resident | Mobile app (home, schedule, messages, profile) | Android / Mobile browser |
| Admin | Web dashboard (desktop only, min 900px width) | Desktop browser |

---

## Development Workflow

```
1. Make changes in VS Code
2. Test locally → flutter run -d chrome
3. Build → flutter build web
4. Commit code changes → git add ... → git commit
5. Commit new build → git add build/web -f → git commit
6. Push → git push (Vercel auto-redeploys)
```

---

## Group Members

| Name | Role |
|---|---|
| Eguillos, Jovielyn N. | Project Manager |
| Eusebio, John Jhervy G. | QA Analyst |
| Lerios, Lianne Princess P. | Frontend Developer & UI/UX Designer |
| Sandajan, Josiah B. | Full Stack Developer |
| Sinag, Rash Ian B. | Full Stack Developer |

**Course:** IT Professional Elective 1 — BSIT-2B-M
**Instructor:** Dr. Mary Joy D. Vinas
**School:** Technological University of the Philippines — Manila

---

## Common Issues

### `flutter pub get` fails with permission error
Run PowerShell as Administrator or fix permissions:
```bash
icacls "C:\flutter" /grant "%USERNAME%:F" /T
```

### `flutterfire` not recognized
Add to PATH:
```
C:\Users\<YourUsername>\AppData\Local\Pub\Cache\bin
```

### `firebase` not recognized
Install Firebase CLI:
```bash
npm install -g firebase-tools
```

### App shows blank screen on Chrome
Make sure Firebase is initialized and `firebase_options.dart` exists. Run `flutterfire configure` if missing.


[yoooooo](https://barangay-waste-app.vercel.app/)
