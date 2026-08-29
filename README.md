# StyleMart

Production-ready Flutter clothing e-commerce app for Android & iOS.

- **Stack**: Flutter (Material 3) · GetX · GetStorage · Firebase (Auth,
  Realtime Database, Storage, Messaging, Analytics, Crashlytics, Remote
  Config) · Razorpay/UPI · Cached Network Image
- **Languages**: English · हिन्दी · मराठी (every string localized)
- **Architecture**: clean layering — `core` (constants/theme/utils/i18n) →
  `data` (models + repositories) → `services` → `presentation`
  (controllers/screens/widgets), wired with GetX bindings and routes.

## Features

OTP login (auto-read on Android) · home feed with banners, flash sale,
new arrivals, best sellers, recommendations, recently viewed and continue
shopping · nested categories · listings with grid/list, filters (price,
brand, color, size, discount, availability), sorting and infinite scroll ·
product details with zoomable gallery, variants, offers, reviews with
photos and helpful votes · realtime cart with save-for-later and coupons ·
multi-address checkout with delivery options and Razorpay/UPI/COD ·
order history with live tracking, cancel/return/reorder and invoice view ·
wishlist sync · search with suggestions, recent + trending terms ·
FCM notifications · full analytics event funnel · dark mode ·
offline-aware UI with shimmer/empty/error states.

## Project layout

```
lib/
├── app/            # routes, bindings (DI graph)
├── core/           # constants, theme, utils, localization
├── data/           # models, Firebase repositories
├── services/       # analytics, FCM, payments, connectivity, config, storage
└── presentation/   # controllers, screens, reusable widgets
firebase/           # security rules + seed data
```

## Getting started

See **[SETUP.md](SETUP.md)** for Firebase/Razorpay configuration, database
schema, security rules and seed data. Quick start:

```bash
flutter pub get
flutterfire configure --project=<your-project>
flutter run
```
"# ecom" 
"# ecom" 
