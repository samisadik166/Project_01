# Little Learners

Little Learners is a Flutter preschool learning app built for young children ages 3–6. It combines colorful educational activities with secure account management and a parent-friendly interface.

## Overview

The app is designed to help children practice foundational skills through a playful, low-stress experience. Learners can explore a range of activities including tracing, counting, and interactive play while parents can manage profiles and track progress.

## Key Features

- Kid-friendly login and splash screen experience
- Email/password sign-in and account creation
- Google sign-in support
- Multiple child profiles with parent-controlled learner selection
- Home, Play, Progress, and Profile navigation
- Alphabet tracing and number tracing activities
- Simple educational games and practice screens
- Per-child quiz history, stars, badges, and learning progress
- Support for adding children and managing family accounts

## Tech Stack

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Google Sign-In

## Project Structure

- `lib/main.dart` — app entry point and splash screen
- `lib/login_page.dart` — login flow and Firebase authentication UI
- `lib/sign_up_page.dart` — parent account creation page
- `lib/home_page.dart` — main navigation and app shell
- `lib/features/` — learning features and activity widgets
- `lib/tabs/` — app tabs and related screens
- `lib/model/` — data models
- `lib/utils/` — shared helpers and utilities
- `test/` — widget and app tests

## Prerequisites

Before running the app, make sure you have:

- Flutter SDK installed and added to your PATH
- An IDE such as VS Code or Android Studio
- A Firebase project configured for your app
- Android/iOS/Web Firebase configuration files generated for this project

## Getting Started

1. Clone the repository:

   git clone <repository-url>

2. Change into the project directory:

   cd preschool_learning_app

3. Install dependencies:

   flutter pub get

4. Configure Firebase:
   - Add your Firebase configuration files (for example, `firebase_options.dart`)
   - Enable Authentication methods in the Firebase Console
   - Ensure Firestore access is configured for your project

5. Run the app:

   flutter run

## Running Tests

To run the widget tests:

   flutter test

## Firebase Notes

This application uses Firebase for authentication and user data storage. If you are setting up a fresh environment, make sure the Firebase project and configuration files match your app setup before launching the app on an emulator or device.

## Current Status

The project includes a working learning app foundation with activity screens, profile flows, and authentication support. It is well-suited for continued enhancement with more lessons, polish, and additional educational content.