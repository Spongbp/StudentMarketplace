# UFV Student Marketplace

A Flutter-based mobile marketplace application designed for students at the University of the Fraser Valley (UFV) to buy and sell items within their campus community.

## 📱 Overview

The UFV Student Marketplace is a cross-platform mobile application that enables students to:
- List items for sale (books, electronics, furniture, rentals, etc.)
- Browse and search for items from other students
- Communicate with sellers through in-app messaging
- Manage their listings and saved favorites
- Filter items by price, condition, location, and category

## ✨ Features

### User Authentication
- Email/password authentication with Firebase Auth
- Email verification required for account activation
- Secure sign-in and sign-up flow

### Product Listings
- **Create Listings**: Post items with multiple images (up to 5), descriptions, pricing, and categorization
- **Image Upload**: Upload product images to Cloudinary for reliable storage
- **Categories**: Books, Electronics, Furniture, Renting, Other
- **Conditions**: New, Fairly New, Used, Heavily Used
- **Campus Locations**: Abbotsford, Chilliwack, Mission, Hope

### Search & Discovery
- Real-time search by product title or category
- Advanced filtering options:
  - Price range slider ($0 - $10,000)
  - Condition filter
  - Campus location filter
- Grid view of available listings
- Excludes sold items from search results

### Product Details
- Carousel slider for multiple product images
- Detailed product information (title, price, description, condition, location)
- Seller information display
- Favorite/unfavorite functionality
- Direct messaging with seller

### Messaging System
- Real-time chat between buyers and sellers
- Conversation list with unread message indicators
- Automatic conversation creation
- Message history persistence

### User Profile
- **Profile Management**: Edit name, campus location, and profile picture
- **My Listings Tab**: View and manage all posted items
  - Toggle sold/available status
  - Quick navigation to product details
- **Saved Items Tab**: Access favorited items
  - Remove items from favorites
- Sign out functionality

### Additional Features
- Favorite items for quick access
- Real-time data synchronization with Firebase
- Cached network images for better performance
- Material Design 3 UI with green theme
- Responsive layout for various screen sizes

## 🛠️ Tech Stack

### Frontend
- **Flutter** (SDK ^3.1.1)
- **Dart** programming language
- **Material Design 3** UI components

### Backend & Services
- **Firebase Authentication** - User authentication and management
- **Cloud Firestore** - Real-time database for listings, users, and conversations
- **Firebase Storage** - File storage (configured but using Cloudinary for images)
- **Firebase App Check** - Security and abuse prevention
- **Cloudinary** - Image hosting and management

### Key Dependencies
```yaml
- firebase_core: ^3.8.0
- firebase_auth: ^5.3.3
- cloud_firestore: ^5.5.0
- firebase_storage: ^12.3.6
- firebase_app_check: ^0.3.1+6
- image_picker: ^1.1.2
- carousel_slider: ^5.0.0
- cached_network_image: ^3.4.1
- provider: ^6.0.0
- http: ^1.0.0
```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point and routing
├── models/
│   ├── user_model.dart      # User data model
│   └── ufv_app_state.dart   # App state management
└── pages/
    ├── home_page.dart        # Main home screen with listings
    ├── signin_page.dart      # User sign-in
    ├── signup_page.dart      # User registration
    ├── add_item_page.dart    # Create new listing
    ├── product_page.dart     # Product details view
    ├── messages_page.dart    # Conversations list
    ├── chat_screen.dart      # Individual chat interface
    └── profile_page.dart      # User profile and settings
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.1.1 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Firebase account
- Cloudinary account (for image hosting)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd thecodearchitects
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android/iOS apps to your Firebase project
   - Download configuration files:
     - Android: `google-services.json` → `android/app/`
     - iOS: `GoogleService-Info.plist` → `ios/Runner/`
   - Enable Authentication (Email/Password)
   - Create Firestore database
   - Enable Firebase App Check

4. **Cloudinary Setup**
   - Create a Cloudinary account at [Cloudinary](https://cloudinary.com/)
   - Create an upload preset named `flutter_preset`
   - Update Cloudinary credentials in `lib/pages/add_item_page.dart` and `lib/pages/profile_page.dart`:
     ```dart
     final String cloudName = 'your_cloud_name';
     final String uploadPreset = 'flutter_preset';
     ```

5. **Firebase App Check Configuration**
   - Update the debug token in `lib/main.dart` with your Firebase App Check debug token
   - For production, configure proper App Check providers

6. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Firebase Configuration

### Firestore Collections Structure

#### `users` Collection
```javascript
{
  uid: string,
  name: string,
  email: string,
  location: string, // Campus name
  profilePictureUrl: string,
  favorites: [string] // Array of listing IDs
}
```

#### `listings` Collection
```javascript
{
  title: string,
  price: number,
  description: string,
  location: string, // Campus name
  category: string,
  condition: string,
  images: [string], // Array of image URLs
  userId: string,
  isSold: boolean,
  createdAt: timestamp
}
```

#### `conversations` Collection
```javascript
{
  participants: [string], // Array of user IDs
  lastMessage: string,
  lastMessageTime: timestamp,
  unreadBy: [string] // Array of user IDs with unread messages
}
```

#### `messages` Collection (subcollection of conversations)
```javascript
{
  text: string,
  senderId: string,
  timestamp: timestamp
}
```

### Security Rules

Ensure your Firestore security rules are properly configured to protect user data:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Listings: read all, write own
    match /listings/{listingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
    }
    
    // Conversations: read/write if participant
    match /conversations/{conversationId} {
      allow read, write: if request.auth != null && request.auth.uid in resource.data.participants;
    }
  }
}
```

## 📱 Usage

### For Sellers
1. Sign up or sign in with your email
2. Navigate to the "Sell" tab (bottom navigation)
3. Fill in product details:
   - Product name
   - Price
   - Description
   - Select campus location
   - Choose category
   - Select condition
   - Upload up to 5 images
4. Tap "Post Item" to publish your listing

### For Buyers
1. Browse listings on the home page
2. Use the search bar to find specific items
3. Apply filters (price, condition, location) using the filter icon
4. Tap on any listing to view details
5. Favorite items for quick access later
6. Message sellers directly from the product page
7. View your saved items in the Profile tab

### Managing Your Listings
1. Go to Profile tab
2. View "Listings" tab to see all your posted items
3. Toggle "SOLD" / "AVAILABLE" status
4. Tap any listing to view/edit details

## 🎨 UI/UX Features

- **Material Design 3** with green color scheme
- **Responsive Grid Layout** for product listings
- **Image Carousel** for multiple product photos
- **Real-time Updates** using Firestore streams
- **Cached Images** for improved performance
- **Bottom Navigation** for easy app navigation
- **Search & Filter** functionality for quick discovery

## 🔒 Security

- Firebase Authentication for secure user management
- Firebase App Check for API abuse prevention
- Email verification required for account activation
- Firestore security rules for data protection
- Secure image uploads via Cloudinary

## 🐛 Known Issues / Future Improvements

- Profile picture upload functionality could be enhanced
- Add image deletion from Cloudinary when listings are removed
- Implement push notifications for new messages
- Add rating/review system for sellers
- Implement payment integration
- Add report/flag functionality for inappropriate content
- Enhance search with full-text search capabilities

## 📝 License

This project is created for educational purposes at the University of the Fraser Valley.

## 👥 Contributing

This is a student project. For contributions or suggestions, please contact the development team.

## 📞 Support

For issues or questions, please create an issue in the repository or contact the development team.

---

**Note**: Make sure to configure all Firebase services and Cloudinary credentials before running the app. The app requires an active internet connection to function properly.
