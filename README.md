# budget

A premium, minimalist expense tracker built with Flutter, designed for security and seamless cloud synchronization.

[![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## ✨ Features

- ☁️ **Cloud Synchronization**: Real-time data backup and cross-device sync powered by **Firebase Firestore**.
- 🔒 **Biometric Security**: Advanced privacy protection using Fingerprint or Face ID authentication.
- 📊 **Dynamic Analytics**: Visualized spending habits through interactive and responsive charts.
- 🌙 **Modern UX**: Smooth, high-performance UI with refined animations and support for both Light and Dark modes.
- 🏛️ **Robust Architecture**: Built with **BLoC** for scalable state management and clean code principles.
- 📁 **Offline Support**: Local data persistence using **Hive** for a fast, offline-first experience.

---

## 📸 Usage & UI

*Please insert your real app screenshots into the `./screenshots/` directory using the filenames specified below:*

| Screen | Live App Screenshot | Description |
| :--- | :--- | :--- |
| **Welcome** | ![Screenshot - Splash Screen](./assets/screenshots/splash_screen.jpeg) | The premium animated entry screen showcasing the 'budget' logo. |
| **Authentication** | ![Screenshot - Sign In Page](./assets/screenshots/auth_page.jpeg) | The secure login and registration interface with Firebase integration. |
| **Dashboard** | ![Screenshot - Main Dashboard](./assets/screenshots/dashboard_page.jpeg) | The overview of current balance, recent expenses, and quick actions. |
| **Analytics** | ![Screenshot - Spending Charts](./assets/screenshots/analytics_page.jpeg) | Visual breakdown of expenses by category with interactive charts. |
| **Operations** | ![Screenshot - Add Transaction](./assets/screenshots/add_transaction.jpeg) | Simple and intuitive transaction logging. |
| **Settings** | ![Screenshot - Profile](./assets/screenshots/setting_page.jpeg) | Personalized settings and biometric security configuration. |

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc)
- **Local Storage**: [Hive](https://pub.dev/packages/hive)
- **Backend Services**: [Firebase Authentication](https://firebase.google.com/docs/auth), [Cloud Firestore](https://firebase.google.com/docs/firestore)
- **Animations**: [flutter_animate](https://pub.dev/packages/flutter_animate)
- **Dependency Injection**: [get_it](https://pub.dev/packages/get_it)

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (v3.0+)
- Firebase CLI (for cloud configuration)
- A Firebase project created in the [Firebase Console](https://console.firebase.google.com/)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/budget.git
   cd budget
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**:
   - Ensure `firebase_options.dart` is correctly configured for your project.
   - For Android, place your `google-services.json` in `android/app/`.
   - For iOS, place `GoogleService-Info.plist` in `ios/Runner/`.

4. **Run the application**:
   ```bash
   flutter run --release
   ```

---

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
<div align="center">
  Built with ❤️ for financial clarity.
</div>
