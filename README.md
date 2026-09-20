# Dukkan

A Flutter store application with customer accounts, products, orders, and an
administrator dashboard backed by Firebase Authentication and Cloud Firestore.

## Local setup

1. Install Flutter and run `flutter pub get`.
2. Use the Firebase CLI and FlutterFire CLI with a Firebase project you control.
   Run `flutterfire configure` to generate `lib/firebase_options.dart` and the
   platform configuration files. Those files are intentionally ignored by Git.
3. Enable Email/Password authentication in Firebase.
4. Review and deploy the Firestore rules to your intended project:
   `firebase deploy --only firestore:rules --project YOUR_PROJECT_ID`.
5. Run `flutter run`.

Firebase CLI configuration may add your project's identifiers to `firebase.json`;
keep its committed version limited to the portable Firestore rules configuration.

## Administrator access

Create your administrator account through Firebase Authentication and assign an
`admin: true` custom claim using the Firebase Admin SDK in a trusted environment.
Preserve any existing custom claims when doing so. Sign out and back in to refresh
the token. The app never creates privileged accounts or stores admin passwords.
The custom claim, enforced by Firestore rules, controls administrator access;
profile fields do not grant privileges.

Do not include service account credentials, signing keys, environment files,
database exports, or backup archives in commits. Keep them outside this repository
where possible. Firebase configuration and old local archives are excluded by
`.gitignore` but remain on the original development machine.

## Before using real customer data

Changes to local rules do not update a deployed Firebase project. Deploy reviewed
rules, replace any previously embedded administrator password, and revoke that
account's existing sessions through a trusted Firebase administration environment.
Grant the custom claim to the intended administrator before relying on admin login.

Restrict Firebase API keys to the required APIs and client applications, configure
App Check where supported, and set appropriate usage quotas and billing alerts.
Firebase client configuration is discoverable in distributed apps; authorization
must be enforced by backend rules, not by hiding configuration.

Order prices, quantities, and totals currently come from the client. They must be
validated/recomputed by a trusted backend before fulfillment or payment. These
repository cleanup changes are not a complete production security audit.

References: [Firebase API keys](https://firebase.google.com/docs/projects/api-keys),
[custom claims](https://firebase.google.com/docs/auth/admin/custom-claims), and
[security checklist](https://firebase.google.com/support/guides/security-checklist).
