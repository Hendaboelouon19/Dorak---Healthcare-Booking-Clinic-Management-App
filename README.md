# Dorak

Dorak is a modern healthcare and clinic booking app built with Flutter. It is designed to help patients discover clinics, book doctor appointments, track live queue status, receive notifications, and manage personal healthcare information in a simple and premium mobile experience.

## Project Title

Dorak - Healthcare Booking & Clinic Management App

## Overview

This project focuses on a polished UI experience for a healthcare platform with multiple user roles:

- Patient flow for clinics, bookings, queue tracking, and profile
- Assistant flow for clinic-side operations
- Admin flow for performance and management dashboards
- Mock data and provider-based state management for a realistic front-end prototype

## Features

- Role-based landing and navigation
- Clinic discovery and doctor selection
- Appointment booking flow
- Live queue and waiting status
- Appointment history and upcoming visits
- Push-style notification center
- Patient profile and account information
- Premium blue medical branding and responsive UI design

## Tech Stack

- Flutter
- Dart
- Provider for state management
- Google Fonts
- fl_chart for analytics visuals
- Intl for formatting
- Flutter SVG for branding assets

## Project Structure

```bash
lib/
├── app.dart
├── main.dart
├── routes/
├── providers/
├── screens/
│   ├── admin/
│   ├── assistant/
│   ├── patient/
│   └── shared/
├── theme/
└── widgets/
```

## Getting Started

### Prerequisites

- Flutter SDK installed
- Android Studio / VS Code with Flutter support
- Emulator or physical device

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

### Analyze the project

```bash
flutter analyze
```

## Current Status

This repository is currently a UI-focused healthcare prototype with mock data and simulated app interactions. It does not include real backend authentication or real-time healthcare integrations.

## Notes

The app is designed as a front-end experience for a clinic management system, with emphasis on user experience, clean information architecture, and role-driven healthcare flows.

## License

This project is for educational and demo purposes.
