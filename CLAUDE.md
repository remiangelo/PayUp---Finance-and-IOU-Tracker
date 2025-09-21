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
- **Premium Subscriptions**: Tiered subscription model with StoreKit integration
- **Receipt Scanning**: OCR-powered receipt scanning with Vision framework
- **Payment Integration**: Framework for direct payments through popular services

### Data Models
- `User`: Tracks participants with unique device IDs
- `Transaction`: Records payments with payer, beneficiaries, and amounts
- `Session`: Container for users and transactions with unique session keys
- `SessionManager`: ObservableObject managing app state
- `Subscription`: Premium tier system (Free, Premium, Pro, Business)
- `SubscriptionManager`: Handles StoreKit purchases and subscription status
- `EnhancedTransaction`: Extended transaction model with categories and receipts

## Design System - LiquidGlassUI (iOS 26 Style)

### Color Theme (Liquid Glass - iOS 26 Apple Music Style)
- **Deep Ocean** (#000814) - Base background
- **Midnight Blue** (#001D3D) - Secondary background
- **Neon Cyan** (#00F0FF) - Primary accent
- **Neon Blue** (#3366FF) - Secondary accent  
- **Neon Purple** (#9933FF) - Tertiary accent
- **Pure White** - Primary text on dark surfaces

### UI Components
- **LiquidGlassBackground**: Multi-layered animated liquid flow effect
- **LiquidGlassNavigationBar**: iOS 26 Apple Music-style frosted navigation
- **PremiumGlassCard**: Multi-layer glass cards with shimmer effects
- **GlassTabBar**: iOS 26-style tab bar with liquid indicator
- **LiquidButton**: Buttons with ripple animations and dynamic fills
- **GlassTextField**: Text fields with focus glow states

### Visual Features (iOS 26)
- Ultra-thin material base layers
- Multi-layered liquid glass effects
- Subtle shimmer and glow animations
- Matched geometry effects for smooth transitions
- Frosted glass with proper blur layers
- iOS 26 separator lines with animated glows

## Premium Features & Monetization

### Subscription Tiers
1. **Free**: 3 sessions, 10 members max, basic features
2. **Premium ($4.99/mo)**: Unlimited sessions, cloud sync, analytics, receipt scanning
3. **Pro ($9.99/mo)**: Payment integration, AI features, multi-currency
4. **Business ($29.99/mo)**: Team management, accounting integration

### Key Premium Features
- **Receipt Scanner**: OCR text extraction using Vision framework
- **Advanced Analytics**: Spending insights and trends
- **Cloud Sync**: Cross-device synchronization
- **Payment Integration**: Direct settlement through payment apps
- **Custom Themes**: Personalization options
- **Multi-Currency**: Real-time exchange rates

## Project Structure
```
PayUp/
├── Models/
│   ├── User.swift
│   ├── Transaction.swift
│   ├── Session.swift
│   ├── Subscription.swift
│   ├── EnhancedTransaction.swift
│   ├── Budget.swift
│   ├── Category.swift
│   └── Receipt.swift
├── ViewModels/
│   ├── SessionManager.swift
│   └── SubscriptionManager.swift
├── Views/
│   ├── WelcomeView.swift
│   ├── SessionDashboardView.swift
│   ├── PaywallView.swift
│   ├── ReceiptScannerView.swift
│   ├── TransactionsListView.swift
│   ├── BalancesView.swift
│   ├── SettlementsView.swift
│   ├── AddTransactionView.swift
│   ├── CreateSessionView.swift
│   ├── JoinSessionView.swift
│   ├── SessionInfoView.swift
│   ├── BudgetView.swift
│   └── AnalyticsView.swift
├── Components/
│   └── LiquidGlassUI.swift
├── Extensions/
│   └── Color+Hex.swift (removed - exists in ColorTheme.swift)
└── Theme/
    └── ColorTheme.swift
```

## Recent Updates (December 2024)

### iOS 26 Liquid Glass UI Implementation
- **Navigation Bar**: Matches iOS 26 Apple Music style with ultra-thin materials
- **Tab Bar**: Liquid indicator with matched geometry effects
- **Glass Effects**: Multi-layered frosted glass throughout
- **Animations**: Subtle liquid flow and shimmer effects

### Monetization Implementation
- **StoreKit Integration**: Complete in-app purchase system
- **Subscription Management**: Usage tracking and feature gates
- **Premium Paywall**: Beautiful upgrade flow
- **Receipt Scanner**: Fully functional OCR implementation

### Bug Fixes
- Fixed `ReceiptItem` naming conflicts (renamed to `ScannedReceiptItem`)
- Resolved StoreKit Transaction type conflicts
- Fixed deprecated UIScreen.main usage
- Replaced all ProfessionalDesignSystem references with LiquidGlassUI
- Fixed missing color references (primaryBlue → neonBlue, cardBackground → deepOcean)
- Added Color+Hex extension functionality

## Development Notes
- Built with SwiftUI and iOS 17+ features
- Uses @MainActor for SessionManager to ensure UI updates on main thread
- NavigationStack for modern navigation
- TabView with custom liquid glass tab bar
- Bundle identifier: com.payup.PayUp
- StoreKit 2 for subscriptions
- Vision framework for OCR
- Minimum deployment target: iOS 17.0

## Testing Considerations
- Test session creation and joining flows
- Verify balance calculations with multiple transactions
- Check settlement algorithm optimization
- Test subscription purchase flow
- Verify receipt scanner accuracy
- Ensure feature gates work properly
- Test with various numbers of participants

## Build Status
✅ **BUILD SUCCESSFUL** - All compilation errors resolved

## Important Instructions
- Always use LiquidGlassUI design system for consistency
- Maintain iOS 26 liquid glass aesthetic throughout
- Follow established patterns for new features
- Test premium feature gates before release
- Ensure proper error handling for purchases
- Never expose subscription keys or secrets
