# FutsalPro — Futsal Field Reservation System

Modern, SaaS-style futsal field reservation system for Android, iOS, and Web (Chrome debug).

## Features
- Firebase Authentication (Email/Password)
- Cloud Firestore backend
- Role-based dashboards (Admin/User)
- Booking flow with review + QR check-in
- Real-time calendar for admin
- Field management CRUD
- Dark & Light mode (persisted locally)
- Responsive, card-based UI with analytics charts

## Tech Stack
- Flutter (latest stable)
- Firebase Auth, Firestore,
- Provider state management
- fl_chart, table_calendar, mobile_scanner, qr_flutter

## Setup
1. Install dependencies:
   ```bash
   flutter pub get
   ```
2. Configure Firebase:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
3. **Deploy Firestore Rules** (IMPORTANT):
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Select your project
   - Navigate to **Firestore Database** → **Rules**
   - Copy the contents from `firestore.rules` in this project
   - Paste and click **Publish**
   
   Or use Firebase CLI:
   ```bash
   npm install -g firebase-tools
   firebase login
   firebase init firestore
   firebase deploy --only firestore:rules
   ```

4. Run:
   ```bash
   flutter run -d chrome
   ```

## Firestore Structure (High-Level)
```
users/{uid}
  name, email, role, photoUrl, themePreference, createdAt, lastLogin

fields/{fieldId}
  name, description, basePrice, imageUrl, isActive, facilities, createdAt, updatedAt

bookings/{bookingId}
  userId, userName, userEmail, fieldId, fieldName, date, timeSlot,
  basePrice, finalPrice, status, qrCodeData, createdAt

## Auth Flow Notes
- Admin accounts are created manually in Firestore.
```

## Firestore Rules
The complete Firestore rules are in `firestore.rules`. Deploy them to your Firebase project.

**Key security features:**
- Users can only read/write their own documents
- Users can create bookings for themselves
- Users can only cancel their own bookings
- Admins have full access to all collections
- Role field cannot be modified by users (prevents privilege escalation)

## Notes
- Booking slots: 10:00–21:00 WIB, 1-hour duration.
- Weekend pricing: +10% (Saturday & Sunday).
- QR check-in valid only for the booking date/time.
