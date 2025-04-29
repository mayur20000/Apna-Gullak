# Apna Gullak

Apna Gullak is a modern savings app built with Flutter, designed to help users achieve financial goals through goal-based savings. With a sleek glassmorphic UI, it integrates Firebase for authentication and data storage, and Razorpay for seamless UPI transactions. The app is scalable, secure, and user-friendly, making it ideal for personal finance management.

## Features

- **Goal Creation & Tracking**: Set savings goals (e.g., buy a phone, plan a trip) and track progress in real-time.
- **UPI Payments**: Add funds to goals securely using Razorpay UPI integration.
- **Wallet Balance**: Manage and view wallet balance stored in Firestore, initialized at ₹0.00.
- **Transaction History**: View detailed transaction history (credits/debits) with timestamps and status.
- **Authentication**: Secure sign-up, sign-in, password reset, and profile editing via Firebase Authentication.
- **Glassmorphic UI**: Modern, visually appealing design with animations for a smooth user experience.
- **Real-Time Updates**: Stream-based updates for goals, balance, and transactions using Firestore.
- **Scalable Architecture**: Organized codebase with Firestore subcollections for goals and transactions.

## Tech Stack

- **Frontend**: Flutter, Glassmorphism, Flutter Animate
- **Backend**: Firebase (Authentication, Firestore)
- **Payments**: Razorpay UPI
- **Dependencies**: `intl` for currency formatting, `google_fonts` for typography
- **Language**: Dart

## Prerequisites

- Flutter SDK (version 3.0.0 or higher)
- Firebase project with Authentication and Firestore enabled
- Razorpay account with test API keys
- Git for version control
- IDE (e.g., VS Code, Android Studio)

## Setup Instructions

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/mayur20000/Apna-Gullak.git
   cd apna-gullak
2. **Install Dependencies**:
    ```bash
    flutter pub get
3. **Configure Firebase**:
- Create a Firebase project at Firebase Console.
- Enable Email/Password Authentication and Firestore.
- Download the google-services.json (Android) and place them in the respective android/app 
- Update Firestore security rules
- ```bash
  rules_version = '2';
  service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      match /goals/{goalId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      match /transactions/{transactionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
  }
4. **Configure Razorpay**:
- Sign up at Razorpay Dashboard.
- Obtain test API keys (Key ID and Key Secret).
- Replace 'YOUR_RAZORPAY_KEY_ID' in lib/screens/goals_screen.dart with your Key ID.

5. ```bash
   flutter run

**Usage**
- Sign Up/Sign In: Create an account or log in using email and password.
- Create Goals: Navigate to the Goals tab, click the floating action button, and set a goal (e.g., "Buy a Phone", ₹30,000).
- Add Funds: Use the "Add Funds" button to pay via UPI (test with success@razorpay in test mode).
- Track Progress: Monitor goal progress and wallet balance on the Home screen.
- View Transactions: Check transaction history (credits/debits) on the Transactions screen.
- Edit Profile: Update your display name or reset your password via the Profile screen.

  **Project Structure**:
  ```bash
    apna-gullak/
  ├── lib/
  │   ├── models/                # Data models (Goal, Transaction)
  │   ├── screens/              # UI screens (Home, Goals, Transactions, etc.)
  │   ├── services/             # Firebase integration (FirebaseService)
  │   ├── main.dart             # App entry point
  ├── pubspec.yaml             # Dependencies and configuration
  ├── README.md                # Project documentation

**Contact**:
For questions or feedback, contact the project maintainer at mayurvish2003@gmail.com or open an issue on GitHub.













   
