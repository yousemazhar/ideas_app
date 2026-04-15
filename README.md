# Ideas App

A Flutter university lab project for **Software Mobile Development - Spring 2026, Lab 5**.

This application implements an **Ideas Board** where users can:

- view all ideas
- add a new idea
- delete an idea
- refresh ideas from the server
- load cached ideas first, then sync with Firebase Realtime Database

The project is intentionally kept simple and student-friendly, following the lab requirements closely:

- `provider` for app-wide state management
- `http` for Firebase Realtime Database REST requests
- `shared_preferences` for local caching
- two main screens:
  - `Ideas Screen`
  - `Add Idea Screen`

## Lab Goals Covered

This project covers the main concepts required in the lab:

- state management using Provider
- Firebase Realtime Database over HTTP
- asynchronous network operations
- JSON serialization and deserialization
- local caching using SharedPreferences
- error handling
- pull-to-refresh
- data synchronization between local cache and remote storage

## Features

- Displays ideas in a scrollable list
- Each idea contains:
  - `id`
  - `title`
  - `description`
- Adds new ideas to Firebase Realtime Database
- Deletes ideas from Firebase and from the local app state
- Refreshes ideas manually using pull-to-refresh
- Loads cached ideas immediately on app startup
- Fetches the latest ideas from Firebase after loading cache
- Saves the latest list back to local cache
- Shows loading indicators during initial loading and saving
- Shows user-friendly error messages for failed requests

## Project Structure

```text
lib/
  main.dart
  core/
    app_config.dart
  models/
    idea.dart
  providers/
    ideas_provider.dart
  screens/
    ideas_screen.dart
    add_idea_screen.dart
  services/
    ideas_cache_service.dart
  widgets/
    idea_item.dart
```

## Architecture Overview

### 1. Provider

`IdeasProvider` is the main app-wide state manager.

It is responsible for:

- storing the list of ideas
- loading cached ideas
- fetching data from Firebase
- adding new ideas
- deleting ideas
- updating cache after changes
- notifying the UI when data changes

The provider is placed at the root of the app in `main.dart`, so all screens can access the same state.

### 2. Model

The `Idea` model represents a single idea object.

Fields:

- `id`
- `title`
- `description`

It also includes helper methods for:

- converting local cache data from JSON
- converting Firebase response data into `Idea` objects
- converting app data into JSON for saving

### 3. Firebase Realtime Database

The app uses **Firebase Realtime Database REST API** through the `http` package.

This project does **not** use:

- Firestore
- Firebase database SDK
- Firebase storage SDK

Only raw HTTP requests are used, as required by the lab.

### 4. Local Caching

Local caching is implemented using `SharedPreferences`.

The app stores the current list of ideas locally as a JSON string.

This cache is used to:

- show data immediately when the app starts
- reduce startup waiting time
- preserve the last fetched ideas when internet is slow or unavailable

## Firebase Configuration

Firebase configuration is centralized in:

`lib/core/app_config.dart`

Current values:

```dart
class AppConfig {
  static const String firebaseBaseUrl =
      'https://yousef-project1-v3-default-rtdb.firebaseio.com';

  static const String ideasCollectionPath = '/ideas';
  static const String ideasCacheKey = 'cached_ideas';
}
```

### Important

If you want to switch to another Firebase Realtime Database project later, you only need to change:

```dart
firebaseBaseUrl
```

in `lib/core/app_config.dart`.

## Firebase Endpoints Used

The app uses these REST endpoints:

- `GET /ideas.json`
- `POST /ideas.json`
- `DELETE /ideas/{id}.json`

Example full URL:

```text
https://yousef-project1-v3-default-rtdb.firebaseio.com/ideas.json
```

## Initialization Flow

The startup flow follows the lab exactly:

1. Load cached ideas from `SharedPreferences`
2. Display cached ideas immediately
3. Fetch latest ideas from Firebase
4. Update the UI with fresh data
5. Save the fresh data back to local cache

This logic is triggered when `IdeasScreen` opens.

## Data Flow

### Fetch Ideas

When the Ideas screen opens or the user refreshes:

1. The provider sends a `GET` request to Firebase
2. The Firebase response is received as JSON
3. The app converts the response `Map` into `Idea` objects
4. The current local list is cleared first
5. The fresh ideas are added to the provider list
6. The cache is updated
7. The UI rebuilds automatically

This prevents duplicate entries.

### Add Idea

When the user saves a new idea:

1. The form validates title and description
2. The app sends a `POST` request to Firebase
3. Firebase returns an auto-generated ID in the `name` field
4. The app creates a local `Idea` object with that generated ID
5. The idea is added to the provider list
6. The cache is updated
7. The screen returns only after saving completes successfully

### Delete Idea

When the user deletes an idea:

1. The app sends a `DELETE` request to Firebase
2. If the request succeeds, the idea is removed locally
3. The cache is updated
4. The UI rebuilds immediately

## Offline and Caching Behavior

It is important to understand what local caching means in this project.

### What works offline

- previously cached ideas can still be displayed
- if the app was opened before and ideas were cached, those ideas appear immediately on the next startup

### What does not work offline

- adding a brand new idea while offline
- deleting an idea while offline
- syncing new server data while offline

This is expected for this lab because:

- Firebase is the main data source
- saving a new idea must complete on the backend
- local cache reflects the latest successful server state

So if the device is offline and the user tries to save a new idea, the app correctly shows an error message such as:

```text
Could not save the idea. Please try again.
```

That behavior is correct for the lab requirements.

## UI Overview

The UI is intentionally simple and appropriate for a university lab submission.

### Ideas Screen

- orange app bar
- error banner when needed
- list of ideas
- delete icon for each item
- floating action button to add a new idea
- pull-to-refresh support
- loading indicator for initial load
- friendly empty-state message when no ideas are available

### Add Idea Screen

- title input field
- description input field
- validation for empty fields
- save button
- loading indicator while saving
- back navigation blocked while save is in progress

## Packages Used

Dependencies from `pubspec.yaml`:

- `provider`
- `http`
- `shared_preferences`
- `cupertino_icons`

## Setup Instructions

### 1. Clone or open the project

Open the Flutter project in Android Studio, VS Code, or your preferred IDE.

### 2. Install dependencies

Run:

```bash
flutter pub get
```

### 3. Configure Firebase Realtime Database

Make sure your Firebase Realtime Database:

- exists
- is in test mode or has rules that allow your lab operations
- uses the correct base URL in `lib/core/app_config.dart`

### 4. Run the app

```bash
flutter run
```

## Verification Commands

To check the project:

```bash
flutter analyze
flutter test
```

## Expected Behavior Checklist

- Provider is at the app root
- Ideas are stored in a central provider
- UI rebuilds when provider data changes
- Ideas screen fetches data when opened
- Cached ideas load first
- Cached ideas display immediately
- Firebase sync runs after cache load
- Latest data is saved back to cache
- Add screen waits for saving before returning
- Delete removes from Firebase first, then locally
- Pull-to-refresh works
- Duplicate entries are prevented during fetch
- Errors are caught and shown to the user
- Firebase base URL is easy to change in one place

## Notes About `google-services.json`

This project uses Firebase Realtime Database through **HTTP only**.

That means:

- `google-services.json` is **not required** for the database logic in this implementation
- no Firebase SDK is used for storage
- no Firestore is used

If you still want to keep `google-services.json` in the Android project as a file artifact, it should be placed under:

```text
android/app/google-services.json
```

But the app logic itself does not depend on it.

## Limitations

This project intentionally does not include:

- offline queueing for new ideas
- offline delete queueing
- swipe-to-delete bonus feature
- advanced architecture layers such as Bloc, Riverpod, or Clean Architecture

These are excluded on purpose to stay aligned with the lab requirements and keep the code simple.

## Submission Notes

This project is written to be:

- easy to read
- easy to explain in a lab or viva
- close to the required lab structure
- suitable as a university lab submission

## Author

Ideas App Flutter Lab Project  
Software Mobile Development  
Faculty of Informatics and Computer Science  
Spring 2026
