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

## Firestore Structure (High-Level)
```
users/{uid}
  name, email, role, photoUrl, themePreference, createdAt, lastLogin

fields/{fieldId}
  name, description, basePrice, imageUrl, isActive, facilities, createdAt, updatedAt

bookings/{bookingId}
  userId, userName, userEmail, fieldId, fieldName, date, timeSlot,
  basePrice, finalPrice, status, qrCodeData, createdAt

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
