
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
  - [ ] Basic annotations
  - [ ] Crop and resize
- [x] Saving options
  - [x] Save to local
  - [s] Copy to clipboard
  - [x] Custom save locations
- [x] UI Enhancements
  - [ ] Border shadow effects
  - [ ] Customizable UI themes

## Requirements

- macOS 15 or later
- Xcode 15+
- Swift 5.10

## Installation

1. Download the latest release from [Releases](https://github.com/wflixu/iCap/releases)
2. Clone this repository
3. Open in Xcode
4. Build and run

## Contributing
Contributions are welcome! Please submit a pull request or open an issue for any bugs or feature requests.

## Feedback & Support
If you encounter any issues or have suggestions, please open an [issue](https://github.com/wflixu/iCap/issues) on GitHub.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.



背景：这是一个macOS 截图工具，基于Swift 5.10，SwiftUI和ScreenCaptureKit。
现在这个app已经 实现了快捷键开始截图，可以选择截图区域，还可以保存到本地，或者复制到剪贴板。
现在要开发，截图后，保存前，给选择区域呢添加 矩形框，箭头和文字的功能。
 - 我们开始在 ActionBarView 中添加三个按钮，分别是矩形框，箭头和文字。