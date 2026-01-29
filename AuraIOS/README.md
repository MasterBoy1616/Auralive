# Aura iOS App

This is the iOS version of the Aura app, built to be compatible with the Android version for cross-platform BLE communication.

## Features

- **Cross-platform BLE communication** with Android Aura app
- **Gender-based matching system** with male/female themes
- **Real-time chat** via BLE advertising/scanning
- **Background operation** for message reception
- **Modern dark UI** with neon blue/pink accents
- **Turkish localization** for all UI elements

## Architecture

### Core Components

1. **BLEManager.swift** - Core Bluetooth management and BLE packet handling
2. **BLEPacket.swift** - Binary packet protocol compatible with Android version
3. **Models/** - User, Match, and ChatMessage data models
4. **ViewControllers/** - All UI screens and navigation

### BLE Protocol

The app uses the same BLE packet protocol as the Android version:
- Company ID: 0xFFFF for manufacturer data
- Packet types: Presence, Match Request/Response, Chat, Unmatch, Block
- Binary framing with chunking support for long messages
- 4-byte user hash for identity

### Key Features

- **Presence Broadcasting**: Advertises user name and gender
- **Match System**: Two-way confirmation with gender display
- **Chat System**: Reliable message delivery via BLE
- **Background Scanning**: Continues receiving messages in background
- **Device Compatibility**: Works with all iOS devices supporting BLE

## File Structure

```
AuraIOS/
├── AppDelegate.swift                    # App lifecycle and BLE initialization
├── BLE/
│   ├── BLEManager.swift                # Core Bluetooth management
│   └── BLEPacket.swift                 # Binary packet protocol
├── Models/
│   ├── User.swift                      # User preferences and gender enum
│   └── Match.swift                     # Match, ChatMessage, and storage classes
├── ViewControllers/
│   ├── SplashViewController.swift      # Splash screen with animation
│   ├── GenderSelectionViewController.swift # Gender selection onboarding
│   ├── MainTabBarController.swift     # Main tab navigation
│   ├── DiscoverViewController.swift    # Main discovery screen with radar
│   ├── MatchesViewController.swift     # Match list and management
│   ├── ChatViewController.swift        # Real-time chat interface
│   └── ProfileViewController.swift     # User profile and settings
└── Info.plist                         # App configuration and permissions
```

## Setup Requirements

1. **iOS 13.0+** for Core Bluetooth features
2. **Bluetooth permissions** in Info.plist
3. **Background modes** for BLE operation
4. **UserNotifications** for match/message alerts

## Cross-Platform Compatibility

This iOS app is fully compatible with the Android Aura app:
- Same BLE packet protocol and binary format
- Same user hash generation (SHA-256 first 4 bytes)
- Same match ID generation for deterministic pairing
- Same message chunking and reassembly logic

## Usage

1. **First Launch**: Select gender (Male/Female)
2. **Discovery**: Tap scan button to find nearby users
3. **Matching**: Tap users to send match requests
4. **Chatting**: Accept matches to start real-time chat
5. **Profile**: Customize name and visibility settings

## Technical Notes

- Uses manufacturer data (0xFFFF) for BLE communication
- Implements packet rotation for reliable delivery
- Background scanning ensures message reception
- Gender-specific UI themes (blue for male, pink for female)
- Automatic cleanup of old users and message chunks