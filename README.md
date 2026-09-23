<div align="center">

# 🏥 Dorak

### Healthcare Booking & Clinic Management App

**A role-based healthcare platform connecting patients, clinic assistants, and administrators in one unified system.**

Discover Clinics • Book Appointments • Track Queues • Manage Operations • Receive Notifications • Monitor Performance

<br>

**👤 Patient Experience • 🧑‍💼 Assistant Operations • 📊 Admin Management**

</div>

---

## 📖 Overview

**Dorak** is a healthcare booking and clinic management mobile application built with **Flutter** and powered by **Firebase**.

The platform connects the different sides of a clinic through three dedicated user experiences:

| 👤 Patient | 🧑‍💼 Assistant | 📊 Admin |
|---|---|---|
| Discover clinics | Manage appointments | Monitor clinic activity |
| Browse doctors | Manage patients | View analytics |
| Book appointments | Manage daily queues | Track performance |
| Track queue status | Handle patient flow | Manage operations |
| Receive notifications | Support clinic workflow | Access management tools |

Instead of giving every user the same interface, Dorak provides **role-specific screens, navigation, and functionality** according to each user's responsibilities.

Firebase provides the backend services required for **authentication, cloud data storage, and notifications**, while Flutter provides the cross-platform mobile experience.

---

# 📱 App Preview

<p align="center">
  <img src="assets/readme/Screenshot%202026-09-24%20010232.png" width="23%" />
  <img src="assets/readme/Screenshot%202026-09-24%20010312.png" width="23%" />
  <img src="assets/readme/Screenshot%202026-09-24%20010406.png" width="23%" />
  <img src="assets/readme/Screenshot%202026-09-24%20011518.png" width="23%" />
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

The **Patient** experience focuses on simplifying the entire healthcare journey — from finding a clinic to attending an appointment.

Patients can discover clinics and doctors, schedule appointments, track their queue status, receive important updates, and manage their healthcare activity from one application.

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

- 🏥 Discover clinics
- 👨‍⚕️ Browse doctors
- 📅 Book appointments
- ⏳ Track queue status
- 🔔 Receive appointment and queue notifications
- 🗓️ View upcoming appointments
- 🕘 Access appointment history
- 👤 Manage profile information
- 📱 Dedicated patient navigation

---

# 🧑‍💼 Assistant Experience

Clinic assistants are responsible for keeping daily clinic operations organized and patients moving efficiently through the clinic.

Dorak provides assistants with their own operational experience instead of forcing staff to work through patient-facing screens.

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

- 📋 Monitor daily clinic activity
- 📅 Manage appointments
- 👥 Handle patient information
- ⏳ Monitor clinic queues
- 🔄 Update patient flow
- 🏥 Support daily clinic operations
- 📱 Dedicated assistant navigation

---

# 📊 Admin Experience

The **Admin** experience provides a higher-level view of clinic operations.

While assistants focus on daily execution, administrators can monitor activity, analyze performance, and access management-focused information.

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

- 📊 Management dashboard
- 📈 Clinic performance overview
- 🏥 Operational monitoring
- 📉 Analytics and visualizations
- 👥 Activity overview
- 📋 Management information
- 📱 Dedicated admin navigation

---

# 📸 App Screens

<p align="center">
  <img src="assets/readme/Screenshot%202026-09-24%20010232.png" width="30%" />
  <img src="assets/readme/Screenshot%202026-09-24%20010312.png" width="30%" />
  <img src="assets/readme/Screenshot%202026-09-24%20010406.png" width="30%" />
</p>

<p align="center">
  <img src="assets/readme/Screenshot%202026-09-24%20011518.png" width="30%" />
  <img src="assets/readme/Screenshot%202026-09-24%20011609.png" width="30%" />
  <img src="assets/readme/Screenshot%202026-09-24%20011636.png" width="30%" />
</p>

<p align="center">
  <img src="assets/readme/Screenshot%202026-09-24%20011816.png" width="30%" />
  <img src="assets/readme/Screenshot%202026-09-24%20011855.png" width="30%" />
  <img src="assets/readme/Screenshot%202026-09-24%20011944.png" width="30%" />
</p>

<p align="center">
  <img src="assets/readme/Screenshot%202026-09-24%20012010.png" width="30%" />
  <img src="assets/readme/Screenshot%202026-09-24%20012901.png" width="30%" />
  <img src="assets/readme/Screenshot%202026-09-24%20012925.png" width="30%" />
</p>

<p align="center">
  <img src="assets/readme/Screenshot%202026-09-24%20012947.png" width="30%" />
  <img src="assets/readme/Screenshot%202026-09-24%20014532.png" width="30%" />
</p>

---

# 🔄 How Dorak Connects the Clinic

The Patient, Assistant, and Admin experiences are not isolated.

They represent different parts of the same healthcare workflow.

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

This role-based approach keeps every interface focused while allowing the entire clinic workflow to remain connected.

---

# 🔥 Firebase Integration

Firebase acts as Dorak's backend platform and provides the core cloud services needed by the application.

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

After authentication, the user's role determines which application experience they can access.

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

This allows Dorak to maintain a unified authentication system while still providing specialized experiences for each type of user.

---

## ☁️ Cloud Firestore

**Cloud Firestore** provides cloud-based storage for application data.

It acts as a shared data layer connecting Dorak's different workflows.

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

This architecture allows Patient, Assistant, and Admin experiences to work with connected clinic information while presenting that data according to each user's responsibilities.

---

## 🔔 Firebase Cloud Messaging

Dorak uses **Firebase Cloud Messaging (FCM)** for push notifications.

Notifications help users stay informed about important appointment and clinic events without continuously checking the application.

### Notification Use Cases

- 🔔 Appointment updates
- ⏰ Upcoming appointment reminders
- ⏳ Queue updates
- 📅 Booking status changes
- 🏥 Clinic-related notifications

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
         User
```

Notifications are particularly valuable for Dorak's appointment and queue experience, where timely information can improve communication between clinics and patients.

---

# 🏗️ Application Architecture

Dorak follows a structured Flutter architecture that separates navigation, state management, role-specific screens, themes, and reusable components.

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

This role-based organization keeps the project easier to navigate and separates functionality according to responsibility.

---

# 🧠 State Management

Dorak uses **Provider** for application state management.

Provider separates UI components from application state and allows widgets to react to changes without tightly coupling state logic to individual screens.

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

---

# 🧭 Role-Based Navigation

Role-based navigation is a core part of Dorak.

After authentication, users are directed toward the experience associated with their role.

```text
                         Dorak
                           │
                    Authentication
                           │
                     User Role
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

Patients therefore interact with healthcare and booking functionality without being exposed to clinic administration tools.

Likewise, Assistants and Admins receive interfaces designed around their responsibilities.

---

# ⚙️ Technical Architecture

At a high level, Dorak connects the Flutter presentation layer with application state and Firebase services.

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

# 🛠️ Tech Stack

| Technology | Role |
|---|---|
| **Flutter** | Cross-platform mobile application |
| **Dart** | Application programming language |
| **Provider** | State management |
| **Firebase Authentication** | Authentication and user access |
| **Cloud Firestore** | Cloud database |
| **Firebase Cloud Messaging** | Push notifications |
| **fl_chart** | Analytics and data visualization |
| **Google Fonts** | Application typography |
| **Flutter SVG** | SVG asset rendering |
| **Intl** | Date and time formatting |

---

# ✨ Core Features

### 🏥 Clinic Discovery

Patients can explore clinics and doctors before starting the appointment process.

### 👨‍⚕️ Doctor Discovery

Patients can browse doctors and select the healthcare provider that fits their needs.

### 📅 Appointment Booking

Patients can schedule and manage their clinic visits directly from Dorak.

### ⏳ Queue Tracking

Queue-related functionality provides patients with better visibility into their waiting experience.

### 🔔 Push Notifications

Firebase Cloud Messaging keeps users informed about appointment, booking, and queue events.

### 👥 Role-Based Experiences

Patient, Assistant, and Admin interfaces are separated according to each user's responsibilities.

### ☁️ Cloud Data

Cloud Firestore connects the different parts of Dorak through shared cloud-based data.

### 📊 Analytics

Admin-facing interfaces provide visual representations of clinic activity and performance.

### 🎨 Reusable Design

Shared themes and reusable Flutter widgets help maintain a consistent user experience throughout the application.

---

# 🎨 UI & UX

Dorak follows a clean, healthcare-oriented visual direction.

The interface focuses on:

- 💙 Medical-inspired visual identity
- 📱 Mobile-first layouts
- 🧭 Clear navigation hierarchy
- 🧩 Reusable components
- 📊 Easy-to-read dashboards
- 🏥 Healthcare-focused information architecture
- 👥 Role-specific experiences
- ✨ Clean cards and surfaces
- 🔤 Consistent typography
- 📐 Consistent spacing and layouts

The goal is to present healthcare information clearly while keeping each workflow simple and focused.

---

# 🔒 Security & Role Separation

Dorak separates application experiences according to user roles.

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

Role separation helps ensure each type of user interacts with functionality relevant to their responsibilities.

For production healthcare environments, access control should always be enforced at both the application and backend/database security-rule levels.

---

# 🚀 Getting Started

## Prerequisites

Make sure you have:

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- Flutter and Dart IDE extensions
- Android Emulator, iOS Simulator, or physical device
- Firebase project configuration

Verify your Flutter installation:

```bash
flutter doctor
```

---

## 1️⃣ Clone the Repository

```bash
git clone https://github.com/Hendaboelouon19/Dorak---Healthcare-Booking-Clinic-Management-App.git
```

Enter the project directory:

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

Dorak uses Firebase for:

```text
Firebase
├── Authentication
├── Cloud Firestore
└── Firebase Cloud Messaging
```

Connect the application to your Firebase project and provide the required platform configuration before using Firebase-dependent functionality.

Never commit private service-account keys, API secrets, `.env` secrets, or other sensitive credentials to the repository.

---

## 4️⃣ Run Dorak

```bash
flutter run
```

---

## 5️⃣ Analyze the Project

```bash
flutter analyze
```

---

# 🚧 Project Scope

Dorak demonstrates a role-oriented healthcare platform built around:

- 👤 Patient workflows
- 🧑‍💼 Assistant workflows
- 📊 Admin workflows
- 🔐 Firebase Authentication
- ☁️ Cloud Firestore
- 🔔 Firebase Cloud Messaging
- 📅 Appointment booking
- ⏳ Queue management
- 📊 Analytics interfaces
- 🧠 Provider state management
- 🎨 Healthcare-focused UI/UX

The application demonstrates how different clinic users can interact through one connected digital platform.

---

# 🔮 Future Improvements

Dorak can be expanded with:

- 🔐 Advanced authorization rules
- 🔄 Expanded real-time synchronization
- 🔔 Advanced notification preferences
- 🔎 Advanced clinic and doctor search
- 🎯 Search and filtering
- 📍 Location-based clinic discovery
- 📝 Patient medical records
- 📊 Advanced clinic reports
- 👥 Staff permission management
- 🏥 Multi-clinic support
- 📅 Calendar integration
- 🧪 Automated testing
- 📈 Advanced analytics
- 🛡️ Production healthcare security and privacy controls

---

# 💡 Project Vision

Healthcare appointments involve more than selecting a time slot.

There is an entire journey connecting the patient, clinic staff, and clinic management.

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

### 👤 Patient Convenience

A simpler way to discover healthcare, book appointments, receive updates, and understand the waiting process.

### 🧑‍💼 Assistant Efficiency

A dedicated workflow for managing patients, appointments, queues, and daily clinic operations.

### 📊 Administrative Visibility

A management experience for monitoring clinic activity and understanding performance.

---

# 🤝 Contributing

Contributions and suggestions are welcome.

1. Fork the repository.
2. Create a feature branch.
3. Make your changes.
4. Commit your changes.
5. Push the branch.
6. Open a Pull Request.

---

<div align="center">

# 🏥 Dorak

### Patient Convenience • Assistant Efficiency • Administrative Visibility

**Your appointment. Your queue. Your turn.**

</div>