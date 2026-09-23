# Little Learners — Preschool Learning App

A Flutter-based preschool learning app designed for children ages 3–6. The app combines playful learning activities with Firebase-backed authentication and child progress tracking.

## Features

- Kid-friendly splash screen and onboarding flow
- Email/password sign-in and sign-up with Firebase Authentication
- Google sign-in support
- Parent and child profile management
- Bottom navigation for Home, Play, Progress, and Profile
- Alphabet tracing activities
- Number tracing and counting activities
- Play tab with interactive games, drawing, and quizzes
- Progress tracking with stars, badges, reports, and certificates
- Profile tools for managing children and settings

## Tech Stack

- Flutter
- Dart
- Firebase Auth
- Cloud Firestore
- Google Sign-In

## Project Structure

- lib/main.dart — app entry point
- lib/login_page.dart — sign-in and sign-up UI
- lib/home_page.dart — main app shell and navigation
- lib/features/ — learning modules and activities
- lib/tabs/ — tab screens
- lib/model/ — data models
- lib/utils/ — shared helpers, colors, and utilities
- test/ — widget and feature tests

## Getting Started

1. Install Flutter and ensure it is available on your PATH.
2. Clone the project.
3. Open the project folder in your editor.
4. Install dependencies:

   flutter pub get

5. Configure Firebase for your project if needed:
   - add Firebase config files for Android/iOS/Web
   - ensure firebase_options.dart matches your project
   - enable Authentication providers in Firebase Console

6. Run the app:

   flutter run

## Firebase Notes

This project uses Firebase for authentication and user data storage. Make sure the Firebase configuration files are correctly generated and included before running the app on a device or emulator.

## Current Status

The app includes a complete learning experience with multiple educational modules, authentication, and progress tracking. Additional polish and feature expansion can continue from this baseline.