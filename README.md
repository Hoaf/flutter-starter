# nt-flutter-starter

A Flutter starter project with a Node.js backend, featuring authentication, product listing, and user profile management.

---

## Table of Contents

- [Project Structure](#project-structure)
- [Mobile (Flutter)](#mobile-flutter)
- [Backend](#backend)
- [Swagger API Docs](#swagger-api-docs)
- [Figma Design](#figma-design)
- [Assignment](#assignment)
- [Submission](#submission)

---

## Project Structure

```
nt-flutter-starter/
├── flutter/  # Flutter app
└── backend/  # Node.js REST API
```

---

## Mobile (Flutter)

Source code for the app lives in the `flutter/` directory. If you are starting from an empty folder, create the project there (for example, `cd flutter && flutter create .`).

See [flutter/README.md](flutter/README.md) for app-specific setup and run instructions.

---

## Backend

Source code is in the `backend/` directory.

See [backend/README.md](backend/README.md) for setup and running instructions.

---

## Swagger API Docs

1. Start the Node.js server from the `backend` folder.
2. Open: http://localhost:3000/swagger/

---

## Figma Design

[Shopping App – Figma](https://www.figma.com/design/sVZN1GBBOniHz5YpBbYQ5E/Shopping-App?node-id=0-1&t=EgHp0ClQnr33840v-1)

---

## Assignment

| #   | Task                                                    | Points |
| --- | ------------------------------------------------------- | ------ |
| 1   | Integrate with the login API                            | 2      |
| 2   | Store token using secure storage after login            | 2      |
| 3   | Display Product List on the Home tab navigation         | 2      |
| 4   | Build a Profile screen to display user profile from API | 2      |
| 5   | Save user profile to a local database                 | 2      |

### References

- **Secure storage:** [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)
- **Local database options:**
  - **SQLite:** [sqflite](https://pub.dev/packages/sqflite)
  - **Drift (SQLite, type-safe):** [drift](https://pub.dev/packages/drift)
  - **Hive (key-value):** [hive](https://pub.dev/packages/hive) / [hive_flutter](https://pub.dev/packages/hive_flutter)
  - **Realm:** [realm](https://pub.dev/packages/realm)

---

## Submission

**Email subject:** `[Mobile][Flutter Assignment] {Your Name} – {Your SD}`

**Email body:**

- **GitHub:** Link to your demo repository.
- **Notes:** List the features you implemented in the demo.

Email your submission to the trainer using the template above.
