# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application for managing student and staff attendance at CPB (College) through QR code scanning. The app is designed for mobile use and connects to a Laravel backend API.

## Key Technologies

- **Flutter**: 3.32.5 (Dart 3.8.1)
- **Backend**: Laravel API at `http://192.168.1.119:8001`
- **Database**: SQLite for local storage, MySQL backend
- **Authentication**: JWT tokens
- **Main Dependencies**:
  - `sqflite` for local database
  - `dio` and `http` for API calls
  - `mobile_scanner` for QR code scanning
  - `flutter_dotenv` for environment configuration
  - `table_calendar` for calendar views

## Development Commands

### Flutter Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Analyze code for issues
flutter analyze

# Run tests
flutter test

# Build for production
flutter build apk  # Android
flutter build ios  # iOS
```

### Testing Scripts

```bash
# Test login functionality
./test_login.sh

# Check and fix common issues
./check_and_fix.sh

# Apply fixes
./apply_fix.sh
```

## Architecture Structure

### Frontend (Flutter)

```
lib/
├── main.dart                # Application entry point
├── models/                  # Data models
│   ├── student.dart         # Student model
│   ├── attendance.dart      # Attendance tracking
│   ├── staff_member.dart    # Staff models
│   └── api_response.dart    # API response handling
├── screens/                 # UI screens
│   ├── login_screen.dart    # Authentication
│   ├── scanner_screen.dart  # QR code scanning
│   ├── home_screen.dart     # Main navigation
│   └── student/             # Student-specific screens
└── services/                # Business logic
    ├── student_api_service.dart     # Student API calls
    ├── attendance_api_service.dart  # Attendance management
    └── database_service.dart        # Local database
```

### API Integration

The app communicates with a Laravel backend. Key API endpoints needed:

**Navigation Hierarchy:**

- `GET /api/mobile/sections/{id}/levels` - Get levels for a section
- `GET /api/mobile/levels/{id}/classes` - Get classes for a level
- `GET /api/mobile/classes/{id}/series` - Get series for a class
- `GET /api/mobile/students/series/{id}` - Get students in a series

**Attendance Management:**

- `POST /api/attendance/students/submit` - Submit bulk attendance
- `GET /api/attendance/students/stats` - Get attendance statistics

### Data Flow

1. **Authentication**: User logs in → JWT token stored → Used for all API calls
2. **Navigation**: Section → Level → Class → Series → Students
3. **Attendance**: Scan QR code → Mark attendance → Submit to backend
4. **Sync**: Local SQLite database syncs with backend API

## Important Configuration

### Environment Variables (.env)

- `API_BASE_URL`: Backend API URL
- `API_TIMEOUT`: Request timeout in milliseconds
- `JWT_EXPIRATION`: Token expiration time
- `DEBUG_MODE`: Enable/disable debug logging

### User Roles & Permissions

- **Teacher**: Access to assigned classes only
- **Bibliothecaire**: QR scanning only
- **Surveillant Général**: Full access
- **Admin**: Complete system control

## Key Implementation Notes

### API Authentication

All API calls require JWT token in headers:

```dart
headers['Authorization'] = 'Bearer $_authToken';
```

### Data Model Compatibility

The backend uses both old and new field names:

- Old: `name`/`subname`
- New: `first_name`/`last_name`
  Always implement fallback handling for backwards compatibility.

### QR Code Scanning

The app uses `mobile_scanner` package for QR code functionality. Scanner is implemented in `scanner_screen.dart` with attendance submission logic.

### Local Database

SQLite database stores:

- User session data
- Cached student lists
- Offline attendance records for later sync

## Common Issues & Solutions

1. **API Connection Issues**: Check `.env` file for correct `API_BASE_URL`
2. **Authentication Failures**: Verify JWT token is being sent in headers
3. **Scanner Not Working**: Ensure camera permissions are granted
4. **Build Failures**: Run `flutter clean` then `flutter pub get`
