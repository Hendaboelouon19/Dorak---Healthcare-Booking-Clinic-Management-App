# 🔥 Firebase Integration

Dorak uses **Firebase** as its backend platform to support authentication, cloud data storage, and notifications across the Patient, Assistant, and Admin experiences.

### 🔐 Firebase Authentication

**Firebase Authentication** handles user authentication and provides secure access to the application.

After authentication, Dorak uses the user's role to direct them to the appropriate experience:

```text
                    Authentication
                          │
                          ▼
                  Firebase Authentication
                          │
                          ▼
                     User Account
                          │
                  ┌───────┼───────┐
                  │       │       │
                  ▼       ▼       ▼
               Patient Assistant Admin
                  │       │       │
                  ▼       ▼       ▼
               Patient   Clinic   Admin
                 App      Panel  Dashboard
```

This allows Dorak to maintain separate interfaces and workflows for different types of users while using a centralized authentication system.

---

### ☁️ Cloud Firestore

**Cloud Firestore** provides cloud-based data storage for the application.

It supports the data required by Dorak's healthcare workflow, allowing different parts of the application to work with shared, synchronized information.

```text
Patient
   │
   ├── Appointments ──┐
   ├── Queue Status   │
   └── Profile        │
                      ▼
               Cloud Firestore
                      ▲
                      │
   ┌──────────────────┴──────────────────┐
   │                                     │
Assistant                              Admin
   │                                     │
   ├── Patients                           ├── Clinic Data
   ├── Appointments                       ├── Statistics
   └── Queue                              └── Management
```

Firestore allows the Patient, Assistant, and Admin experiences to interact with the same underlying clinic data while presenting it differently according to each role.

---

### 🔔 Firebase Cloud Messaging

Dorak uses **Firebase Cloud Messaging (FCM)** to support push notifications.

Notifications are particularly important in a healthcare booking system because patients need timely information about appointments and clinic activity.

FCM can be used to notify users about events such as:

* Appointment updates
* Booking status changes
* Queue updates
* Upcoming appointments
* Clinic-related announcements

```text
Clinic / Application Event
            │
            ▼
      Firebase / FCM
            │
            ▼
     Push Notification
            │
            ▼
         Patient
```

This helps connect actions happening inside the clinic workflow with the patient's mobile experience.

---

# 🛠️ Tech Stack

| Technology                   | Role in Dorak                          |
| ---------------------------- | -------------------------------------- |
| **Flutter**                  | Cross-platform mobile application      |
| **Dart**                     | Application programming language       |
| **Provider**                 | Application state management           |
| **Firebase Authentication**  | User authentication and access         |
| **Cloud Firestore**          | Cloud database and application data    |
| **Firebase Cloud Messaging** | Push notifications                     |
| **fl_chart**                 | Admin analytics and data visualization |
| **Google Fonts**             | Application typography                 |
| **Flutter SVG**              | SVG asset rendering                    |
| **Intl**                     | Date and time formatting               |

---

## 🔥 Firebase Architecture

```text
                         DORAK
                           │
                ┌──────────┼──────────┐
                │          │          │
                ▼          ▼          ▼
             Patient   Assistant    Admin
                │          │          │
                └──────────┼──────────┘
                           │
                           ▼
                       Provider
                           │
                           ▼
                  Firebase Services
                           │
             ┌─────────────┼─────────────┐
             │             │             │
             ▼             ▼             ▼
      Authentication   Firestore        FCM
             │             │             │
             ▼             ▼             ▼
        User Access    App Data    Notifications
```

Firebase acts as the backend layer connecting Dorak's three role-based experiences while Flutter provides the user-facing application.
