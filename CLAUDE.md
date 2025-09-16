# PayUp Swift App - Project Context

## Overview
PayUp is an iOS app built with SwiftUI for tracking IOUs between friends during nights out. The app uses a session-based system where users can create or join sessions using 6-character codes.

## Architecture

### Core Features
- **Session Management**: Create/join sessions with unique 6-character keys
- **IOU Tracking**: Track who paid for what and automatic split calculations
- **Balance Calculation**: Real-time balance tracking showing who owes whom
- **Smart Settlements**: Optimized payment suggestions to settle all debts with minimum transactions
- **Local Persistence**: Data saved using UserDefaults

### Data Models
- `User`: Tracks participants with unique device IDs
- `Transaction`: Records payments with payer, beneficiaries, and amounts
- `Session`: Container for users and transactions with unique session keys
- `SessionManager`: ObservableObject managing app state

## Design System

### Color Theme (Blue Liquid Wallpaper)
- **Space Black** (#000000) - Deep background
- **Bright Cyan** (#00BFFF) - Primary accent color
- **Electric Blue** (#0080FF) - Secondary accent
- **Dark Navy** (#001840) - Card surfaces
- **Spark Orange** (#FF6B35) - Danger/debt color
- **Pure White** - High contrast text on dark surfaces

### UI Components
- **WallpaperBackground**: Simulated liquid flow effect with wave shapes
- **GlassCard**: Semi-transparent cards with blur effects
- **ReadableGlassCard**: Enhanced glass cards with better text contrast

### Visual Features
- Glassmorphism effects with semi-transparent overlays
- Animated wave backgrounds mimicking liquid flow
- Pulsing animations for important elements
- Gradient text for numbers and titles
- Dark theme with high contrast for readability

## Project Structure
```
PayUp/
├── Models/
│   ├── User.swift
│   ├── Transaction.swift
│   └── Session.swift
├── ViewModels/
│   └── SessionManager.swift
├── Views/
│   ├── WelcomeView.swift
│   ├── SessionDashboardView.swift
│   ├── TransactionsListView.swift
│   ├── BalancesView.swift
│   ├── SettlementsView.swift
│   ├── AddTransactionView.swift
│   ├── CreateSessionView.swift
│   ├── JoinSessionView.swift
│   └── SessionInfoView.swift
├── Components/
│   ├── WallpaperBackground.swift
│   └── GlassBackground.swift
└── Theme/
    └── ColorTheme.swift
```

## Key Implementation Details

### Session Keys
- 6-character alphanumeric codes (e.g., "ABC123")
- Generated randomly when creating sessions
- Case-insensitive for joining

### Balance Calculation Algorithm
- Tracks net balance for each user
- Positive balance = money owed to user
- Negative balance = user owes money
- Automatic settlement optimization to minimize transactions

### UI/UX Principles
- Dark theme with bright cyan accents for visibility
- White text on dark surfaces for maximum readability
- Glass effects subtle enough not to interfere with content
- Smooth animations with spring physics
- Cards with strong shadows for depth perception

## Development Notes
- Built with SwiftUI and iOS 17+ features
- Uses @MainActor for SessionManager to ensure UI updates on main thread
- Imports UIKit for UIDevice access (device ID generation)
- NavigationStack for modern navigation
- TabView for main dashboard navigation
- Bundle identifier: com.payup.PayUp

## Recent Updates
- **Launch Screen**: Animated LaunchScreenView with liquid edge effects
  - 1-second duration with cyclical animations
  - Glowing cyan/blue edges that slide in from all sides
  - Pulsing center logo with continuous rotation
  - Corner accent decorations with spring animations
- **App Icon**: Configured for App Store submission
  - Must be RGB format without alpha channel (no transparency)
  - 1024x1024 PNG required for App Store
- **Bug Fixes**:
  - Fixed gradient stop location ordering in LiquidGlassEffects
  - Added bounds checking and sorting to ensure gradients render correctly

## Testing Considerations
- Test session creation and joining flows
- Verify balance calculations with multiple transactions
- Check settlement algorithm optimization
- Ensure data persistence across app launches
- Test with various numbers of participants

## Future Enhancements (Potential)
- Cloud sync using CloudKit or Firebase
- Real-time updates between devices
- Payment integration (Venmo, PayPal, etc.)
- Transaction history and receipts
- Group expense categories
- Currency conversion support