
# VibeTalk — Modern Flutter Chat App

![VibeTalk Banner](assets/logo.png)

VibeTalk is a modern, dark-themed chat application built with Flutter and Firebase. It showcases a production-like UI (glassmorphism, gradients), modular architecture, and real-time group messaging with Cloud Firestore. This repo is suitable for a portfolio or product demo.

---

## Live Demo / Screenshots

> Add screenshots to `screenshots/` and they will display here. For portfolio use include at least 3 images: Home, Group Chat, Profile.

---

## Highlights

- Polished, professional UI with dark theme and glassmorphism
- Real-time group chat using Firebase Cloud Firestore
- Tabbed Home screen (Chats & Groups) with a modern pill-style TabBar
- Modular architecture: Services, Controllers, Models, Screens
- GetX for state management and navigation
- Ready for extensions: media, typing indicators, push notifications

---

## Features

- Firebase Authentication (Email/Password)
- Group creation and real-time messaging
- Clean UI patterns (cards, pills, avatars)
- Profile and Settings screens
- Easily extendable services for chat and group operations

---

## Project Structure

Key folders:

- `lib/app/services/` — Firebase and backend services
- `lib/app/controllers/` — GetX controllers (state & logic)
- `lib/app/models/` — Data models (User, Chat, Group, Message)
- `lib/screens/` — UI screens
- `lib/app/theme/` — Theme & styling

---

## Quick Setup

1. Clone the repo

```bash
git clone https://github.com/saadnadeem27/VibeTalk.git
cd VibeTalk
```

2. Install dependencies

```bash
flutter pub get
```

3. Configure Firebase

This project expects `lib/firebase_options.dart` to be present. Generate it with the FlutterFire CLI:

```bash
flutterfire configure
```

Enable in Firebase Console:
- Authentication (Email/Password)
- Cloud Firestore

4. Run the app

```bash
flutter run
```

Notes:
- If you run on Android and encounter Gradle plugin warnings, update your Gradle configuration as suggested by Flutter.

---

## Development Notes

- Services: `AuthService`, `ChatService`, and `GroupService` encapsulate Firebase interactions.
- Controllers: `AuthController`, `ChatController`, and `GroupController` use GetX for reactive UI updates.
- UI: Home screen uses a `TabBar` + `TabBarView` with a custom glass-style pill indicator.

---

## Roadmap

- Individual 1:1 real-time messaging (complete wiring of `ChatService`)
- Media upload & preview (images, videos, audio)
- Typing indicators, message reactions, read receipts
- Push notifications

---

## How to Use for Portfolio

- Replace placeholder images in `screenshots/`
- Add a short video/GIF of the app in action to the repo or your portfolio
- Include a short write-up of your design decisions and any metrics (load times, message latency if measured)

---

## License & Contact

Include your license here (e.g., MIT) and contact details.

Saad Nadeem — saad@example.com

GitHub: https://github.com/saadnadeem27/flash_chat

---

If you want, I can:
- Add real screenshots to a `screenshots/` directory and reference them here
- Add a small demo GIF and an `assets/` banner
- Add contribution guidelines and a CODE_OF_CONDUCT
