<div align="center">

# 🏥 Dorak

### Healthcare Booking & Clinic Management App

**A role-based healthcare platform connecting patients, clinic assistants, and administrators in one unified system.**

Discover clinics • Book appointments • Track queues • Manage operations • Receive notifications • Monitor performance

<br>

**Patient Experience • Assistant Operations • Admin Management**

</div>

---

## 📖 Overview

**Dorak** is a healthcare booking and clinic management mobile application built with **Flutter** and powered by **Firebase**.

The platform connects the different sides of a clinic through three dedicated user experiences:

| 👤 Patient            | 🧑‍💼 Assistant         | 📊 Admin                |
| --------------------- | ----------------------- | ----------------------- |
| Discover clinics      | Manage appointments     | Monitor clinic activity |
| Browse doctors        | Manage patients         | View analytics          |
| Book appointments     | Control daily queues    | Track performance       |
| Track queue status    | Handle patient flow     | Manage operations       |
| Receive notifications | Support clinic workflow | Access management tools |

Instead of giving every user the same interface, Dorak provides **role-specific screens, navigation, and functionality** according to each user's responsibilities.

Firebase provides the backend services required for **authentication, cloud data storage, and notifications**, while Flutter provides the cross-platform mobile experience.

---

# 📱 App Preview

<p align="center">
  <img src="assets/readme/patient-home.png" width="24%" />
  <img src="assets/readme/patient-booking.png" width="24%" />
  <img src="assets/readme/assistant-dashboard.png" width="24%" />
  <img src="assets/readme/admin-dashboard.png" width="24%" />
</p>

<p align="center">
  <b>One healthcare platform. Three connected experiences.</b>
</p>

---

# 👥 Three Roles — One Clinic

Dorak is designed around the real workflow of a clinic.

```text
                           DORAK
                             │
               ┌─────────────┼─────────────┐
               │             │             │
               ▼             ▼             ▼
           👤 Patient   🧑‍💼 Assistant   📊 Admin
               │             │             │
          Healthcare       Clinic       Management
          Experience     Operations      & Insights
```

Each role interacts with the same healthcare ecosystem from a different perspective.

---

# 👤 Patient Experience

The **Patient** side of Dorak focuses on simplifying the journey from searching for healthcare to completing a clinic visit.

Patients can discover clinics and doctors, schedule appointments, follow their queue status, receive important updates, and manage their healthcare activity from one application.

### Patient Journey

```text
Discover Clinic
      ↓
Choose Doctor
      ↓
Book Appointment
      ↓
Track Queue
      ↓
Receive Updates
      ↓
Attend Appointment
```

### ✨ Patient Features

* 🏥 Discover clinics
* 👨‍⚕️ Browse available doctors
* 📅 Book appointments
* ⏳ Track queue status
* 🔔 Receive notifications and updates
* 🗓️ View upcoming appointments
* 🕘 Access appointment history
* 👤 Manage profile information
* 📱 Dedicated patient navigation

### 📸 Patient Screens

<p align="center">
  <img src="assets/readme/patient-home.png" width="30%" />
  <img src="assets/readme/patient-doctor.png" width="30%" />
  <img src="assets/readme/patient-booking.png" width="30%" />
</p>

<p align="center">
  <b>Discover → Choose → Book</b>
</p>

<p align="center">
  <img src="assets/readme/patient-queue.png" width="30%" />
  <img src="assets/readme/patient-appointments.png" width="30%" />
  <img src="assets/readme/patient-profile.png" width="30%" />
</p>

<p align="center">
  <b>Track → Manage → Stay Updated</b>
</p>

---

# 🧑‍💼 Assistant Experience

Clinic assistants are responsible for keeping daily clinic operations organized.

Dorak provides assistants with a dedicated operational experience instead of forcing them to work through patient-facing screens.

The Assistant interface focuses on **appointments, patients, queues, and daily clinic flow**.

### Assistant Workflow

```text
View Daily Activity
        ↓
Manage Appointments
        ↓
Handle Patient Arrival
        ↓
Manage Queue
        ↓
Update Patient Flow
```

### ⚙️ Assistant Features

* 📋 Monitor daily clinic activity
* 📅 Manage appointments
* 👥 Handle patient information
* ⏳ Monitor and manage queues
* 🔄 Update patient flow
* 🏥 Support clinic operations
* 📱 Dedicated assistant navigation

### 📸 Assistant Screens

<p align="center">
  <img src="assets/readme/assistant-dashboard.png" width="30%" />
  <img src="assets/readme/assistant-appointments.png" width="30%" />
  <img src="assets/readme/assistant-queue.png" width="30%" />
</p>

<p align="center">
  <b>Appointments → Patients → Queue Management</b>
</p>

---

# 📊 Admin Experience

The **Admin** experience provides a broader view of clinic operations.

While assistants focus on daily execution, administrators need visibility into overall activity and performance.

Dorak provides management-focused interfaces that make clinic information easier to understand and monitor.

### Admin Workflow

```text
Clinic Overview
       ↓
Dashboard
       ↓
Operational Data
       ↓
Analytics
       ↓
Management
```

### 📈 Admin Features

* 📊 Management dashboard
* 📈 Clinic performance overview
* 🏥 Operational monitoring
* 📉 Analytics and visualizations
* 👥 Activity overview
* 📋 Management information
* 📱 Dedicated admin navigation

### 📸 Admin Screens

<p align="center">
  <img src="assets/readme/admin-dashboard.png" width="30%" />
  <img src="assets/readme/admin-analytics.png" width="30%" />
  <img src="assets/readme/admin-management.png" width="30%" />
</p>

<p align="center">
  <b>Monitor → Analyze → Manage</b>
</p>

---

# 🔄 How Dorak Connects the Clinic

The three Dorak experiences are not isolated applications.

They represent different stages of the same clinic workflow.

```text
                     ┌─────────────────┐
                     │     PATIENT     │
                     │                 │
                     │ Search & Book   │
                     └────────┬────────┘
                              │
                              ▼
                     ┌─────────────────┐
                     │   APPOINTMENT   │
                     └────────┬────────┘
                              │
                              ▼
                     ┌─────────────────┐
                     │  CLINIC QUEUE   │
                     └────────┬────────┘
                              │
                              ▼
                     ┌─────────────────┐
                     │    ASSISTANT    │
                     │                 │
                     │ Daily Workflow  │
                     └────────┬────────┘
                              │
                              ▼
                     ┌─────────────────┐
                     │      ADMIN      │
                     │                 │
                     │ Management &    │
                     │ Analytics       │
                     └─────────────────┘
```

This approach keeps each interface focused while allowing the whole clinic workflow to remain connected.

---

# 🔥 Firebase Integration

Firebase acts as the backend platform supporting Dorak's mobile experience.

It provides three major capabilities:

```text
                         Firebase
                            │
             ┌──────────────┼──────────────┐
             │              │              │
             ▼              ▼              ▼
      Authentication    Firestore         FCM
             │              │              │
             ▼              ▼              ▼
        User Access      App Data     Notifications
```

---

## 🔐 Firebase Authentication

**Firebase Authentication** handles user authentication and access to Dorak.

After authentication, the application can provide the appropriate experience according to the user's role.

```text
                       Login
                         │
                         ▼
              Firebase Authentication
                         │
                         ▼
                    User Account
                         │
               ┌─────────┼─────────┐
               │         │         │
               ▼         ▼         ▼
            Patient  Assistant   Admin
               │         │         │
               ▼         ▼         ▼
            Patient    Clinic     Admin
              Flow   Operations Dashboard
```

This allows Dorak to maintain one application while providing different workflows for different types of users.

---

## ☁️ Cloud Firestore

**Cloud Firestore** provides cloud-based storage for application data.

It acts as the shared data layer connecting Dorak's different roles.

```text
                       Cloud Firestore
                              │
           ┌──────────────────┼──────────────────┐
           │                  │                  │
           ▼                  ▼                  ▼
        Patient            Assistant            Admin
           │                  │                  │
     Appointments        Appointments        Clinic Data
     Queue Status        Patient Flow        Analytics
     Profile             Queue Data          Management
```

Because the roles interact with shared clinic information, Firestore allows the application to maintain a connected data flow between the patient-facing and clinic-management experiences.

---

## 🔔 Firebase Cloud Messaging

Dorak uses **Firebase Cloud Messaging (FCM)** to support push notifications.

Notifications help keep patients informed about important changes without requiring them to continuously check the application.

Examples include:

* 🔔 Appointment updates
* ⏰ Upcoming appointment reminders
* ⏳ Queue updates
* 📅 Booking status changes
* 🏥 Clinic-related notifications

### Notification Flow

```text
Application / Clinic Event
           │
           ▼
 Firebase Cloud Messaging
           │
           ▼
    Push Notification
           │
           ▼
        Patient
```

This is especially useful for Dorak's queue experience, where timely information can improve the patient's waiting experience.

---

# 🏗️ Application Architecture

Dorak follows a structured Flutter architecture that separates responsibilities between navigation, state management, screens, themes, and reusable components.

```text
lib/
│
├── main.dart
├── app.dart
│
├── routes/
│   └── Application navigation
│
├── providers/
│   └── State management
│
├── screens/
│   │
│   ├── patient/
│   │   └── Patient experience
│   │
│   ├── assistant/
│   │   └── Assistant operations
│   │
│   ├── admin/
│   │   └── Admin management
│   │
│   └── shared/
│       └── Shared screens
│
├── theme/
│   └── Application design system
│
└── widgets/
    └── Reusable UI components
```

The role-based organization makes the codebase easier to navigate and keeps features belonging to different users logically separated.

---

# 🧠 State Management

Dorak uses **Provider** for application state management.

Provider separates UI components from application state and allows widgets to react when that state changes.

```text
                User Interaction
                       │
                       ▼
                      UI
                       │
                       ▼
                   Provider
                       │
                       ▼
               Application State
                       │
                       ▼
                  Updated UI
```

This approach keeps state-related logic outside individual presentation widgets and supports cleaner separation between different application responsibilities.

---

# 🧭 Role-Based Navigation

One of Dorak's core design decisions is separating navigation according to user roles.

```text
                         Dorak
                           │
                    Authentication
                           │
                    Role Resolution
                           │
              ┌────────────┼────────────┐
              │            │            │
              ▼            ▼            ▼
           Patient     Assistant       Admin
              │            │            │
              ▼            ▼            ▼
           Patient       Clinic       Admin
          Navigation    Navigation   Navigation
```

A patient should not need to navigate through clinic-management tools, while an assistant does not need patient-oriented discovery screens.

Role-based navigation keeps each experience focused on what that user needs.

---

# 🛠️ Tech Stack

| Technology                   | Role                              |
| ---------------------------- | --------------------------------- |
| **Flutter**                  | Cross-platform mobile application |
| **Dart**                     | Application programming language  |
| **Provider**                 | State management                  |
| **Firebase Authentication**  | Authentication and user access    |
| **Cloud Firestore**          | Cloud database                    |
| **Firebase Cloud Messaging** | Push notifications                |
| **fl_chart**                 | Analytics and data visualization  |
| **Google Fonts**             | Typography                        |
| **Flutter SVG**              | SVG asset rendering               |
| **Intl**                     | Date and time formatting          |

---

# ⚙️ Technical Flow

At a high level, Dorak connects its Flutter interface with application state and Firebase services.

```text
                     Flutter UI
                         │
                         ▼
                      Screens
                         │
                         ▼
                     Provider
                         │
                         ▼
                Application Logic
                         │
                         ▼
                 Firebase Services
                         │
          ┌──────────────┼──────────────┐
          │              │              │
          ▼              ▼              ▼
        Auth         Firestore         FCM
          │              │              │
          └──────────────┼──────────────┘
                         │
                         ▼
                Dorak Experience
```

---

# ✨ Core Features

## 🏥 Clinic Discovery

Patients can explore clinics and doctors before starting the appointment process.

## 📅 Appointment Booking

Patients can move from selecting healthcare services to scheduling their clinic visit.

## ⏳ Queue Experience

Queue-related interfaces give patients better visibility into their clinic waiting experience.

## 🔔 Push Notifications

Firebase Cloud Messaging keeps users informed about important appointment and queue events.

## 👥 Role-Based Access

Dorak separates Patient, Assistant, and Admin experiences according to their responsibilities.

## ☁️ Cloud Data

Cloud Firestore provides shared application data across Dorak's role-based workflows.

## 📊 Analytics

Admin interfaces provide visual representations of clinic activity and performance.

## 🎨 Reusable Design

Shared themes and reusable widgets help maintain a consistent experience throughout the application.

---

# 🎨 UI & UX

Dorak follows a clean healthcare-oriented visual direction.

The UI focuses on:

* 💙 Medical-inspired visual identity
* 📱 Mobile-first layouts
* 🧭 Clear navigation
* 🧩 Reusable components
* 📊 Easy-to-read dashboards
* 🏥 Healthcare-focused information hierarchy
* 👥 Role-specific interfaces
* ✨ Clean cards and surfaces
* 🔤 Consistent typography
* 📐 Consistent spacing

The goal is to present healthcare information clearly without overwhelming the user.

---

# 📂 Project Structure

```text
Dorak/
│
├── lib/
│   │
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── routes/
│   │
│   ├── providers/
│   │
│   ├── screens/
│   │   ├── patient/
│   │   ├── assistant/
│   │   ├── admin/
│   │   └── shared/
│   │
│   ├── theme/
│   │
│   └── widgets/
│
├── assets/
│   └── readme/
│
├── android/
├── ios/
│
├── pubspec.yaml
└── README.md
```

---

# 🚀 Getting Started

## Prerequisites

Make sure the following are installed:

* Flutter SDK
* Dart SDK
* Android Studio or VS Code
* Flutter & Dart IDE extensions
* Android Emulator, iOS Simulator, or physical device

Verify the Flutter installation:

```bash
flutter doctor
```

---

## 1️⃣ Clone the Repository

```bash
git clone https://github.com/Hendaboelouon19/Dorak---Healthcare-Booking-Clinic-Management-App.git
```

Then enter the project directory:

```bash
cd Dorak---Healthcare-Booking-Clinic-Management-App
```

---

## 2️⃣ Install Dependencies

```bash
flutter pub get
```

---

## 3️⃣ Configure Firebase

Dorak requires Firebase configuration for its backend services.

Create or configure the Firebase project and connect the required Android/iOS application before running Firebase-dependent functionality.

The application uses Firebase for:

```text
Firebase
├── Authentication
├── Cloud Firestore
└── Cloud Messaging
```

Firebase project credentials and other sensitive configuration should **never be committed publicly** when they contain secrets.

---

## 4️⃣ Run the Application

```bash
flutter run
```

---

## 5️⃣ Analyze the Code

```bash
flutter analyze
```

---

# 📸 README Screenshot Setup

For the visual sections in this README, place screenshots inside:

```text
assets/
└── readme/
```

Recommended filenames:

```text
assets/readme/
│
├── patient-home.png
├── patient-doctor.png
├── patient-booking.png
├── patient-queue.png
├── patient-appointments.png
├── patient-profile.png
│
├── assistant-dashboard.png
├── assistant-appointments.png
├── assistant-queue.png
│
├── admin-dashboard.png
├── admin-analytics.png
└── admin-management.png
```

This organization keeps README media separate from assets used directly by the Flutter application.

---

# 🔒 Security & Role Separation

Dorak's role-based design separates application experiences according to user responsibilities.

```text
                 Authenticated User
                         │
                         ▼
                       Role
                         │
          ┌──────────────┼──────────────┐
          │              │              │
       Patient        Assistant        Admin
          │              │              │
      Patient UI     Operations UI   Management UI
```

Role separation improves both usability and maintainability by ensuring each user sees functionality relevant to their responsibilities.

For a production healthcare environment, role separation should also be enforced at the backend/database security-rule level rather than relying only on UI navigation.

---

# 🚧 Current Scope

Dorak demonstrates a complete role-oriented healthcare application experience built around:

* 👤 Patient workflows
* 🧑‍💼 Assistant workflows
* 📊 Admin workflows
* 🔐 Firebase Authentication
* ☁️ Cloud Firestore
* 🔔 Firebase Cloud Messaging
* 📅 Appointment experiences
* ⏳ Queue management
* 📊 Analytics interfaces
* 🧠 Provider state management
* 🎨 Healthcare-focused UI/UX

The application demonstrates how different clinic users can interact through one connected digital platform.

---

# 🔮 Future Improvements

Dorak can be expanded further with:

* 🔐 More advanced authorization rules
* 🔄 Expanded real-time synchronization
* 🔔 Advanced notification preferences
* 🔎 Advanced clinic and doctor search
* 🎯 Search filters
* 📍 Location-based clinic discovery
* 📝 Patient medical records
* 📊 Advanced clinic reports
* 👥 Staff permission management
* 🏥 Multi-clinic support
* 📅 Calendar integration
* 🌐 Backend service expansion
* 🧪 Automated testing
* 📈 Advanced analytics
* 🛡️ Production healthcare security and privacy controls

---

# 💡 Project Vision

Healthcare appointments involve more than choosing a time slot.

There is an entire journey between the patient, the clinic staff, and clinic management.

Dorak brings those experiences together:

```text
Discover
   ↓
Choose
   ↓
Book
   ↓
Arrive
   ↓
Queue
   ↓
Visit
   ↓
Manage
```

The platform is designed from three perspectives:

### 👤 Patient Convenience

A simpler way to discover healthcare, book appointments, and understand the waiting process.

### 🧑‍💼 Assistant Efficiency

A dedicated workflow for managing patients, appointments, and daily clinic operations.

### 📊 Administrative Visibility

A management experience for understanding clinic activity and performance.

---

<div align="center">

# 🏥 Dorak

### Patient Convenience • Assistant Efficiency • Administrative Visibility

**Your appointment. Your queue. Your turn.**

</div>
