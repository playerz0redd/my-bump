# My-Bump

My-Bump is a real-time geolocation-based social iOS application (inspired by Zenly) that allows users to share their live location with friends, manage relationships (friend requests, blocks), and customize their privacy levels dynamically on an interactive map.

## 📱 Features

* **Real-time Geolocation Sync:** Background location tracking using `CoreLocation` and instant coordinate synchronization with friends via **Firebase Realtime Database**.
* **Interactive Map View:** Custom annotations on `MapKit` displaying friends' profile pictures with native bouncing keyframe animations.
* **Friendship Management (Social Graph):** Firestore-backed system for sending, receiving, accepting, and declining friend requests, as well as removing friendships.
* **Privacy Playground:** Custom dynamic privacy controls:
  * *Ghost Mode:* Freeze your location on the map for other users while continuing to move.
  * *Precise Ghosting (Blurring):* Blur your precise location to a 500m radius for security.
* **Secure Authentication:** Complete authentication flow supporting Email/Password sign-up/sign-in, secure password reset, and **Google Sign-In** integration.
* **Media Handling & Caching:** Profile avatar upload to **Cloudinary** cloud storage, dynamically requested with fills/crops, and loaded/cached on the client using **Kingfisher**.

## 🛠 Tech Stack

* **Language:** Swift 5.0+
* **UI Framework:** SwiftUI (PhaseAnimator, KeyframeAnimator, custom components)
* **Location & Maps:** CoreLocation, MapKit
* **Backend & Database:** Firebase Auth, Cloud Firestore, Firebase Realtime Database
* **Image Management:** Cloudinary SDK, Kingfisher
* **Architecture:** MVVM-C with Dependency Injection Containers, Observation

## 📐 Architecture & Code Structure

The project strictly follows the **MVVM** pattern combined with a service-oriented layer to decouple UI components from business logic and database managers.

### Directory Structure Highlight:

* `/Core` — Network clients, database managers, and location wrappers.
  * `LocationManager.swift` - Wrapper for `CLLocationManager` handling background updates.
  * `LocationSyncManager.swift` - Real-time database synchronizer.
  * `SocialManager.swift` - Firestore transaction layer for relationships.
  * `CloudinaryManager.swift` - Image upload and URL transform engine.
* `/Services` — Service protocols executing domain business logic.
  * `MapService.swift` - Orchestrates location updates and maps pipelines.
  * `SocialService.swift` - Manages relationships states (liked, requesting, responsing).
* `/Features` — UI views, ViewModels, and data models grouped by features (Auth, Map, Profile, FriendsManagement).
* `/Shared` — Custom modifiers, UI elements, extensions, and utilities.

## 🚀 Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/playerz0redd/my-bump.git
   cd my-bump
