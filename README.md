
![](iCap/Assets.xcassets/AppIcon.appiconset/icon_128x128.png)

# iCap - macOS Screenshot Tool

[![Swift 5.9](https://img.shields.io/badge/Swift-5.10-ED523F.svg?style=flat)](https://swift.org/) [![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-orange)](https://developer.apple.com/xcode/swiftui/) [![macOS 15](https://img.shields.io/badge/macOS15-Compatible-green)](https://www.apple.com/macos/monterey/)

[中文版](README_CN.md)

A modern macOS screenshot application built with Swift 5.10, SwiftUI and ScreenCaptureKit.

## Features

- [x] Screenshot capture
  - [x] Keyboard shortcut support
  - [x] Screen area selection
  - [ ] Window selection
- [x] Image editing
  - [x] Basic annotations
  - [x] Crop and resize
- [x] Saving options
  - [x] Save to local
  - [x] Copy to clipboard
  - [x] Custom save locations
- [x] UI Enhancements
  - [x] Border shadow effects
  - [ ] Customizable UI themes

## Requirements

- macOS 15 or later
- Xcode 15+
- Swift 5.10

## Installation

1. Download the latest release from [Releases](https://github.com/wflixu/iCap/releases)

## preview
![](public/images/preview.png)


## Contributing
Contributions are welcome! Please submit a pull request or open an issue for any bugs or feature requests.

## Feedback & Support
If you encounter any issues or have suggestions, please open an [issue](https://github.com/wflixu/iCap/issues) on GitHub.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

发布事件
```swift
CombineEventBus.shared.post(SaveAll(data: "123456"))
```
订阅事件

```swift
import Combine

var cancellables = Set<AnyCancellable>()

CombineEventBus.shared
    .observe(SaveAll(data: "123456").self)
    .receive(on: RunLoop.main)
    .sink { event in
        print("用户登录: \(event.data)")
    }
    .store(in: &cancellables)
```

