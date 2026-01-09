# Smritim App (Flutter)

Smritim App is a production-grade Flutter application designed for **patient medication adherence**, **adverse drug reaction (ADR) reporting**, and **clinical safety workflows**.

---

## ✨ Core Capabilities

### Patient
- Medication adherence confirmation
- Conversational chatbot
- Symptom reporting with rule-based suggestions
- Dual-language support (English / Malayalam)

### Clinician
- View alerts
- Create PvPI cases from alerts

### Hospital Admin
- Review & submit PvPI cases
- Audit safety events

---

## 🏗 Architecture

Flutter App → REST APIs → Smritim Backend (Node.js + MySQL)

---

## 🚀 Setup

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:3000/api
```

---

## 🔐 Security
- No secrets committed
- `.env` ignored
- Role-based backend enforcement

---

## 📂 Structure

```
lib/
├── api_client.dart
├── screens/
├── widgets/
└── main.dart
```

---

## 📜 License
© Smritim. All rights reserved.
