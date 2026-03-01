<div align="center">

![](iCap/Assets.xcassets/AppIcon.appiconset/icon_128x128.png)

# iCap

**A modern macOS screenshot tool built with pure Swift**

[![Swift Version](https://img.shields.io/badge/Swift-5.10-ED523F.svg?style=flat&logo=swift)](https://swift.org/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-orange.svg?style=flat)](https://developer.apple.com/xcode/swiftui/)
[![macOS](https://img.shields.io/badge/macOS-15.0%2B-blue.svg?style=flat&logo=apple)](https://www.apple.com/macos/)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=flat)](LICENSE)

[English](README.md) | [中文文档](README_CN.md)

</div>

## ✨ Features

- **📸 Screen Capture**
  - Full screen and custom area selection
  - Global keyboard shortcut support
  - High-quality screenshot capture using ScreenCaptureKit

- **✏️ Image Editing**
  - Multiple annotation tools (text, shapes, arrows, blur, etc.)
  - Crop and resize functionality
  - Border and shadow effects

- **💾 Flexible Saving**
  - Save to local disk with custom paths
  - Copy to clipboard
  - Pin screenshots to floating windows

- **🎨 Modern UI**
  - Native SwiftUI interface
  - Smooth animations and transitions
  - Dark mode support

## 📋 Requirements

- **OS:** macOS 15.0 (Sequoia) or later
- **Xcode:** 15.0 or later
- **Swift:** 5.10 or later

## 🚀 Installation

### Download Release

1. Visit the [Releases](https://github.com/wflixu/iCap/releases) page
2. Download the latest `.dmg` file
3. Open the file and drag iCap to your Applications folder
4. Grant screen recording permission when prompted

### Build from Source

```bash
# Clone the repository
git clone https://github.com/wflixu/iCap.git
cd iCap

# Open in Xcode
open iCap.xcodeproj

# Build and run (⌘R)
```

## 📖 Usage

### Quick Start

1. **Launch iCap** - Grant screen recording permission when prompted
2. **Take a screenshot** - Use the global shortcut (default: `⌘⇧X`)
3. **Select area** - Drag to select the screen region
4. **Annotate** - Use tools from the left panel to annotate
5. **Save** - Choose your preferred save option

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘⇧X` | Take screenshot |
| `Esc` | Cancel selection |
| `⌘Z` | Undo annotation |
| `⌘⇧Z` | Redo annotation |

### Screenshots

<div align="center">
  <img src="public/images/preview.png" alt="iCap Preview" width="800">
</div>

## 🛠️ Development

### Build Commands

```bash
# Debug build
xcodebuild -project iCap.xcodeproj -scheme iCap -configuration Debug build

# Release build
xcodebuild -project iCap.xcodeproj -scheme iCap -configuration Release build

# Run tests
xcodebuild test -project iCap.xcodeproj -scheme iCap -destination 'platform=macOS'
```

### Project Structure

```
iCap/
├── iCapApp.swift          # Main app entry point
├── AppState.swift         # Global state management
├── Editor/                # Image editing components
│   ├── CanvasView.swift
│   ├── AnnotationManager.swift
│   └── EditorView.swift
├── Shared/                # Shared utilities
│   ├── EventBus.swift     # Event system
│   ├── Constants.swift
│   └── Utils.swift
└── Assets.xcassets        # App assets
```

### Key Technologies

- **SwiftUI** - Modern UI framework
- **ScreenCaptureKit** - Screen capture API
- **Combine** - Reactive programming
- **KeyboardShortcuts** - Global hotkeys

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please read our [Contributing Guidelines](CONTRIBUTING.md) for details.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- Uses [ScreenCaptureKit](https://developer.apple.com/documentation/screencapturekit) for screen capture
- Icons from [SF Symbols](https://developer.apple.com/sf-symbols/)
- Keyboard shortcuts managed by [KeyboardShortcuts](https://github.com/soffes/KeyboardShortcuts)

## 📮 Contact & Support

- **Issues:** [GitHub Issues](https://github.com/wflixu/iCap/issues)
- **Discussions:** [GitHub Discussions](https://github.com/wflixu/iCap/discussions)

---

<div align="center">
  <sub>Built with ❤️ by <a href="https://github.com/wflixu">@wflixu</a></sub>
</div>
