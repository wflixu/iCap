# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

iCap is a modern macOS screenshot application built with Swift 5.10, SwiftUI and ScreenCaptureKit. It provides screenshot capture, image editing, and saving capabilities with a native macOS interface.

**Requirements:** macOS 15.0+, Xcode 15+

## Architecture

### Core Components

**Main App Structure:**
- `iCapApp.swift` - Main SwiftUI app entry point with window management
- `AppState.swift` - Centralized state management using ObservableObject
- `AppDelegate.swift` - Handles application lifecycle and screen capture permissions

**Window Management:**
The app uses multiple window groups:
- Main window (`AppWinsInfo.main`) - Primary interface
- Overlay window (`AppWinsInfo.overlayer`) - Full-screen selection and annotation
- Pinboard window (`AppWinsInfo.pinboard`) - Floating pinned images

**State Management:**
- `AppState.shared` - Singleton for global state (marked with `@MainActor` for thread safety)
- `AnnotationManager` - Dedicated manager for annotation CRUD operations with undo/redo support
- Both passed as `@EnvironmentObject` throughout the app
- Combine framework for reactive data flow
- Event bus system (`EventBus.swift`) for decoupled communication

### Key Modules

**Screen Capture:**
- Uses ScreenCaptureKit framework for modern screen capture
- `AppState.getScreenImage()` - Captures current mouse screen
- Handles screen recording permissions

**Image Processing:**
- Core Graphics for image manipulation and effects
- Shadow and corner radius effects (`processImageWithEffects`)
- Image cropping and merging capabilities

**Annotation System:**
- `AnnotationManager` - Manages annotations with CRUD operations and undo/redo stack
- `AnnotationType` enum for different annotation tools
- `Annotation` model for storing annotation data
- Canvas-based drawing and editing
- `EditorView` - Three-panel layout: AnnotationPanel (left), CanvasView (center), PropertiesPanel (right)

**Event System:**
The app uses a custom event bus with these events:
- `StartSaveDrawing`, `StartComposeImage`, `StartSaveImage`
- `SaveAll`, `SaveDrawing`, `SavedAnno`

## Development Commands

### Building
```bash
# Build the project
xcodebuild -project iCap.xcodeproj -scheme iCap -configuration Debug build

# Build for release
xcodebuild -project iCap.xcodeproj -scheme iCap -configuration Release build
```

### Testing
```bash
# Run tests
xcodebuild test -project iCap.xcodeproj -scheme iCap -destination 'platform=macOS'

# Run specific test
xcodebuild test -project iCap.xcodeproj -scheme iCap -destination 'platform=macOS' -only-testing:iCapTests/iCapTests
```

### Code Quality
```bash
# Run periphery (unused code detection)
periphery scan --project iCap.xcodeproj --scheme iCap
```

## Key Dependencies

- `ScreenCaptureKit` - Screen capture functionality
- `KeyboardShortcuts` - Global keyboard shortcut handling
- `Combine` - Reactive programming framework
- `SwiftUI` - Modern UI framework

## File Organization

```
iCap/
├── iCapApp.swift          # Main app entry point
├── AppState.swift         # Global state management
├── Shared/                # Shared utilities
│   ├── EventBus.swift     # Event system
│   ├── Constants.swift    # App constants
│   ├── Extensions.swift   # Extensions
│   ├── Utils.swift        # Utility functions
│   └── AppLogger.swift    # Logging system
├── Settings/              # Settings UI
│   ├── GeneralTabView.swift
│   └── AboutTabView.swift
├── StatusBar/             # Menu bar functionality
│   └── StatusMenu.swift
├── Editor/                # Image editing components
│   ├── CanvasView.swift
│   ├── AnnotationView.swift
│   ├── ActiveAnnotationView.swift
│   ├── AnnotationManager.swift
│   ├── EditorView.swift
│   ├── AnnotationPanel.swift
│   └── PropertiesPanel.swift
└── Assets.xcassets        # App assets and icons
```

## Development Notes

### Event Bus Usage
```swift
// Post events
EventBus.shared.post(SaveAll(data: "data"))

// Subscribe to events
.onReceive(EventBus.shared.observe(SaveAll.self)) { event in
    // Handle event
}
```

### State Management Patterns
- Use `@Published` properties for reactive UI updates
- Access global state via `AppState.shared` and `AnnotationManager`
- Both are passed as `@EnvironmentObject` to views:
  ```swift
  @EnvironmentObject var appState: AppState
  @EnvironmentObject var annotationManager: AnnotationManager
  ```
- `AppState` is marked with `@MainActor` to ensure thread safety
- Handle screen capture asynchronously with proper error handling

### Window Management
- Windows are managed through SwiftUI WindowGroup
- Overlay window uses `.screenSaver` level for full-screen display
- Pinboard windows use `.canJoinAllSpaces` to appear on all desktops

### Gesture Handling
- Uses SwiftUI `DragGesture` for user interactions
- Coordinate space naming via `.coordinateSpace(.named(Keys.coordinate))`
- Two-phase gesture handling: `onChanged` and `onEnded`
- Consistent coordinate system across views for proper positioning

## Localization

The app supports multiple languages:
- English
- Chinese (zh-Hans)

Strings are managed via `Localizable.xcstrings` string catalogs.

## Permissions

The app requires screen recording permissions:
- Handled in `AppDelegate.checkScreenRecordingPermission()`
- Uses `CGPreflightScreenCaptureAccess()` and `CGRequestScreenCaptureAccess()`

## Logging

Uses custom `@AppLog` property wrapper with OSLog:
- `Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Category")`
- Structured logging throughout the app lifecycle