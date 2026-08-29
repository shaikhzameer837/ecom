# StyleMart — Setup Guide

Flutter e-commerce app (Android + iOS) backed by Firebase Realtime Database,
with GetX state management, Razorpay/UPI payments and en/hi/mr localization.

## 1. Prerequisites

- Flutter (stable, 3.44+), Android Studio / Xcode
- A Firebase project with the **Blaze** plan (Phone Auth + Storage)
- A Razorpay account (test keys are fine to start)

## 2. Firebase wiring

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=<your-firebase-project>
```

This regenerates `lib/firebase_options.dart` (currently a placeholder) and
places `android/app/google-services.json` and
`ios/Runner/GoogleService-Info.plist`. The Android Gradle build applies the
Google Services and Crashlytics plugins automatically once
`google-services.json` exists.

Then in the Firebase console:

1. **Authentication → Sign-in method**: enable *Phone*.
   - Add your debug/release **SHA-1 and SHA-256** fingerprints
     (`cd android && ./gradlew signingReport`) so Android auto-verification
     and the SMS Retriever work.
   - For iOS, upload your APNs key (Messaging is used for silent
     verification).
2. **Realtime Database**: create a database, then paste
   [firebase/database.rules.json](firebase/database.rules.json) into the
   Rules tab. The `.indexOn` entries are required for the category/home
   queries.
3. **Storage**: paste [firebase/storage.rules](firebase/storage.rules).
4. **Import seed data** (optional but recommended for first run): in
   Realtime Database → ⋮ → *Import JSON*, import
   [firebase/seed_data.json](firebase/seed_data.json). Fill the empty
   `images` arrays with Storage download URLs after uploading product
   images to `products/`.
5. **Remote Config**: add parameters
   - `razorpay_key_id` (string) — your Razorpay **Key ID** (publishable;
     the key *secret* must never ship in the app or Remote Config)
   - `free_shipping_threshold` (number, default 999)
   - `flash_sale_enabled` (bool, default true)
6. **Cloud Messaging**: nothing extra for Android; for iOS enable Push
   Notifications + Background Modes (remote notifications) in Xcode.

## 3. Payments (Razorpay + UPI)

- The app reads the key from Remote Config (`razorpay_key_id`), so keys can
  be rotated without a release.
- UPI is offered through Razorpay Checkout with a UPI-only method filter.
- **Important**: payment *verification/capture* must be done server-side
  (Cloud Function or your backend) using the key secret and the
  `paymentId` stored on the order at `orders/{uid}/{orderId}/paymentId`.
  The client never verifies payments.

## 4. Database schema

See the schema comment in
[lib/core/constants/db_paths.dart](lib/core/constants/db_paths.dart).
Highlights:

- `products/{id}` holds listing-weight fields; `productDetails/{id}` holds
  description/specs/offers so listings stay lightweight.
- Carts, wishlists, orders, addresses and notifications are per-user
  subtrees (`{node}/{uid}/...`), matching the security rules.
- `trendingSearches` is a public counter map that powers search
  suggestions.

## 5. Admin panel (future)

- The `admins/{uid}` node is reserved. When you build the panel, grant
  writes to catalog nodes with
  `root.child('admins').child(auth.uid).exists()` in the rules and/or
  custom claims via the Admin SDK. No app-side changes are needed.

## 6. Run

```bash
flutter pub get
flutter run
```

Notes:
- The app boots even before `flutterfire configure` (Firebase init failure
  is caught), but auth/data will not work until it's configured.
- Release builds use minify + the provided
  [proguard-rules.pro](android/app/proguard-rules.pro) (Razorpay-safe).
- Localization lives in `lib/core/localization/langs/` — add a map + locale
  entry to add a language.

## 7. Tests & quality

```bash
flutter analyze   # clean
flutter test      # model/pricing unit tests
```
