# 🏠 Home Services App — Flutter

A pixel-perfect Flutter implementation of the Home Services UI for Android.

## 📁 Project Structure

```
lib/
├── main.dart                    ← App entry point + bottom navigation
├── theme/
│   └── app_theme.dart           ← Colors, typography, ThemeData
├── models/
│   └── models.dart              ← Data models
├── screens/
│   ├── home_screen.dart         ← Main home screen (matches the design)
│   ├── bookings_screen.dart     ← Bookings tab
│   └── other_screens.dart      ← Wallet, Notifications, Profile
└── widgets/
    ├── category_card.dart       ← Service category grid card
    ├── provider_card.dart       ← Provider list card
    └── custom_bottom_nav_bar.dart ← Animated bottom navigation
```

## 🚀 Setup in Android Studio

### 1. Create a new Flutter project
```
File → New → New Flutter Project → Flutter Application
```
Name it `home_services_app`

### 2. Replace files
Copy all files from this project into your Flutter project, replacing defaults.

### 3. Add dependencies to `pubspec.yaml`
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  google_fonts: ^6.1.0
```

### 4. Install packages
```bash
flutter pub get
```

### 5. Run the app
```bash
flutter run
```
Or press the ▶ Run button in Android Studio.

## 🎨 Design Details

- **Primary Color**: Orange `#F97316`
- **Font**: Poppins (via google_fonts)
- **Theme**: Light, card-based layout
- **Bottom Nav**: 5 tabs — Home, Bookings, Wallet, Notifications, Profile

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| google_fonts | ^6.1.0 | Poppins font |
| cupertino_icons | ^1.0.6 | iOS-style icons |

## 📱 Features Implemented

- ✅ Location header with dropdown
- ✅ Notification bell
- ✅ Search bar with settings button
- ✅ Hero banner card
- ✅ 3×2 category grid (Electricity, Plumber, Cleaning, Laundry, AC Repair, More)
- ✅ Popular Providers list with ratings & pricing
- ✅ Animated bottom navigation bar (5 tabs)
- ✅ Wallet screen with balance card
- ✅ Notifications screen
- ✅ Profile screen with menu items
- ✅ Bookings screen

## 💡 To Add Real Images

Replace the icon containers in `home_screen.dart` with actual `Image.asset()` or `Image.network()` widgets. Add your assets to the `assets/images/` folder and declare them in `pubspec.yaml`.
