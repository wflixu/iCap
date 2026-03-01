# iCap Architecture

## Overview

iCap 是一个使用 Swift 5.10、SwiftUI 和 ScreenCaptureKit 构建的现代化 macOS 截图应用，提供截图捕获、图片编辑和保存功能。

## Core Architecture

### Application Structure

```
iCap/
├── iCapApp.swift              # 应用入口，窗口管理
├── AppState.swift             # 全局状态管理（@MainActor）
├── AppDelegate.swift           # 应用生命周期，屏幕捕获权限
├── ContentView.swift           # 根视图
│
├── Editor/                    # 图片编辑模块
│   ├── CanvasView.swift       # 画布视图
│   ├── AnnotationView.swift   # 标注渲染
│   ├── ActiveAnnotationView.swift  # 标注编辑
│   ├── AnnotationManager.swift   # 标注管理器
│   ├── EditorView.swift       # 编辑器主视图
│   ├── AnnotationPanel.swift   # 标注列表面板
│   ├── PropertiesPanel.swift   # 属性面板
│   └── ActionBarView.swift    # 工具栏
│
├── OverlayerView.swift        # 覆盖层视图（截图选择）
├── SelectionAreaView.swift     # 选择区域视图
│
├── Shared/                    # 共享工具
│   ├── EventBus.swift         # 事件总线
│   ├── Constants.swift        # 常量定义
│   ├── Extensions.swift       # 扩展
│   ├── Utils.swift            # 工具函数
│   └── AppLogger.swift        # 日志系统
│
├── Settings/                  # 设置界面
│   ├── GeneralTabView.swift   # 通用设置
│   └── AboutTabView.swift      # 关于页面
│
└── StatusBar/                 # 菜单栏功能
    └── StatusMenu.swift        # 状态菜单
```

## Window Management

应用使用多个 WindowGroup 实现不同的窗口：

| 窗口 ID | 用途 | 特性 |
|---------|------|------|
| `AppWinsInfo.main` | 主窗口 | 标准窗口 |
| `AppWinsInfo.overlayer` | 覆盖层 | 全屏选择，`.screenSaver` 级别 |
| `AppWinsInfo.pinboard` | 固定板 | 浮动窗口，`.canJoinAllSpaces` |

## State Management

### AppState (Singleton)

**文件:** [`AppState.swift`](iCap/AppState.swift)

```swift
@MainActor
class AppState: ObservableObject {
    static let share = AppState()

    // 关键状态
    @Published var isShow: Bool = false           // 覆盖层显示状态
    @Published var annotationType: AnnotationType   // 当前标注类型
    @Published var annotations: [Annotation] = []   // 标注数组（兼容层）
    @Published var screenImage: CGImage?           // 截图
    @Published var cropRect: CGRect?               // 选择区域

    // 图片处理
    func getScreenImage() -> NSImage?             // 获取鼠标所在屏幕截图
    func processImageWithEffects()                // 处理图片效果
}
```

### AnnotationManager

**文件:** [`AnnotationManager.swift`](iCap/Editor/AnnotationManager.swift)

```swift
@MainActor
class AnnotationManager: ObservableObject {
    @Published var annotations: [Annotation] = []
    @Published var selectedAnnotationId: UUID?
    @Published var nextNumber: Int = 1             // 序号计数器
    @Published var undoStack: [AnnotationOperation] = []
    @Published var redoStack: [AnnotationOperation] = []

    // CRUD 操作
    func add(_ annotation: Annotation)
    func delete(_ annotationId: UUID)
    func update(_ annotation: Annotation)
    func clear()

    // 选择管理
    func select(_ annotationId: UUID?)
    func toggleSelection(_ annotationId: UUID)

    // 层级管理
    func move(toFront annotationId: UUID)
    func move(toBack annotationId: UUID)

    // 序号管理
    func addNumberAnnotation(at point: CGPoint)
    func updateNumber(_ annotationId: UUID, number: Int)
    func resetNumberCounter()
}
```

## Data Models

### AnnotationType

**文件:** [`Model.swift`](iCap/Editor/Model.swift:19-46)

```swift
enum AnnotationType {
    case none       // 无
    case rect       // 矩形
    case arrow      // 箭头
    case text       // 文字
    case number     // 序号（新增）
    case blur       // 马赛克（新增）
    case highlight  // 高亮（新增）
}

enum ArrowStyle {
    case standard    // 标准箭头（空心三角形）
    case filled      // 实心箭头
}
```

### Annotation

**文件:** [`Model.swift`](iCap/Editor/Model.swift:61-77)

```swift
struct Annotation: Identifiable, Equatable {
    let id = UUID()
    let type: AnnotationType
    var frame: CGRect

    // 通用属性
    var color: Color = .red
    var lineWidth: CGFloat = 2
    var opacity: Double = 1.0
    var zIndex: Int = 0
    var isSelected: Bool = false
    var isLocked: Bool = false

    // 矩形专用
    var isFilled: Bool = false
    var dashPattern: [CGFloat]? = nil

    // 箭头专用
    var arrowHeadSize: CGFloat = 10
    var arrowStyle: ArrowStyle = .standard

    // 序号专用
    var number: Int = 1

    // 马赛克专用
    var blurRadius: CGFloat = 10

    // 文字专用
    var text: String = ""
    var fontSize: CGFloat = 16
    var fontName: String = ".SF Pro"

    // 手势相关
    var start: CGPoint = .zero
    var offset: CGSize = .zero
}
```

### CPoint (Control Point)

**文件:** [`Model.swift`](iCap/Editor/Model.swift:79-192)

用于编辑标注时的 8 个控制点：
- `topLeft`, `top`, `topRight`, `left`, `right`, `bottomLeft`, `bottom`, `bottomRight`

## Event System

**文件:** [`Shared/EventBus.swift`](iCap/Shared/EventBus.swift)

类型安全的事件总线，使用 Combine 框架：

```swift
// 发布事件
EventBus.shared.post(SaveAll(data: "data"))

// 订阅事件
.onReceive(EventBus.shared.observe(SaveAll.self)) { event in
    // 处理事件
}
```

### 标准事件

| 事件 | 用途 |
|------|------|
| `StartSaveDrawing` | 开始保存标注 |
| `StartComposeImage` | 开始合成图片 |
| `StartSaveImage` | 开始保存图片 |
| `SaveAll` | 保存全部 |
| `SaveDrawing` | 保存标注 |
| `SavedAnno` | 标注已保存 |

## Annotation System

### 支持的标注类型

| 类型 | 功能 | 属性 |
|------|------|------|
| 矩形 | 矩形框选 | 虚线样式、填充 |
| 箭头 | 指示箭头 | 样式（标准/实心）、大小 |
| 文字 | 文字标注 | 字体、大小、内容 |
| 序号 | 数字标记 | 数字值、颜色 |
| 马赛克 | 模糊隐私 | 模糊半径 |
| 高亮 | 荧光笔 | 颜色、透明度 |

### 标注创建流程

```
用户选择工具 → 在 CanvasView 上拖拽/点击
                    ↓
            创建 Annotation 实例
                    ↓
            AnnotationManager.add()
                    ↓
            保存到 undoStack
                    ↓
            触发 UI 更新
```

### 坐标系统

使用命名坐标空间确保一致的坐标：

```swift
.coordinateSpace(.named(Keys.coordinate))
```

## Gesture Handling

### DragGesture 统一处理

**文件:** [`CanvasView.swift`](iCap/Editor/CanvasView.swift)

```swift
DragGesture(minimumDistance: 0, coordinateSpace: .named(Keys.coordinate))
    .onChanged { value in
        // 处理拖动过程
    }
    .onEnded { value in
        if annotationType == .number {
            // 序号：点击添加
            annotationManager.addNumberAnnotation(at: value.startLocation)
        } else {
            // 其他：添加拖拽创建的标注
            annotationManager.add(newAnnotation)
        }
    }
```

### 两阶段手势处理

1. **onChanged** - 实时更新预览
2. **onEnded** - 完成创建/编辑

## Rendering Pipeline

### 标注渲染

**静态标注:** [`AnnotationView.swift`](iCap/Editor/AnnotationView.swift)
**激活标注:** [`ActiveAnnotationView.swift`](iCap/Editor/ActiveAnnotationView.swift)

### 导出流程

```
CanvasView → ImageRenderer → CGImage
                              ↓
                    合成到原图 (AppState)
                              ↓
                    应用图像效果
                              ↓
                    最终保存
```

## UI Components

### NavigationSplitView 布局

**文件:** [`EditorView.swift`](iCap/Editor/EditorView.swift)

```
+---------------+----------------+---------------+
| Annotation   |    Canvas      | Properties     |
| Panel         |    View         | Panel         |
| (左侧)        |    (中心)       | (右侧)        |
+---------------+----------------+---------------+
                    |
            +-------+
            | Tool  | (底部工具栏)
            +-------+
```

### Properties Panel

根据选中标注类型动态显示相应控件：

- **通用:** 颜色选择器、不透明度滑块、锁定开关
- **矩形:** 填充开关、线条样式选择器
- **箭头:** 箭头样式选择器、箭头大小滑块
- **序号:** 数字步进器
- **马赛克:** 模糊半径滑块
- **文字:** 文本输入框、字体大小滑块

## Thread Safety

### @MainActor

关键状态管理类使用 `@MainActor` 确保线程安全：

```swift
@MainActor
class AppState: ObservableObject { ... }

@MainActor
class AnnotationManager: ObservableObject { ... }
```

这确保所有 UI 相关的状态更新都在主线程上执行。

## Key Patterns

### 1. Environment Object Pattern

全局状态通过 EnvironmentObject 注入：

```swift
@EnvironmentObject var appState: AppState
@EnvironmentObject var annotationManager: AnnotationManager
```

### 2. ObservableObject + @Published

响应式状态更新：

```swift
@Published var annotations: [Annotation] = []
```

### 3. Command Pattern (Undo/Redo)

使用栈操作实现撤销/重做：

```swift
enum AnnotationOperation {
    case add(Annotation)
    case delete(Annotation, at: Int)
    case update(old: Annotation, new: Annotation)
    case deleteAll([Annotation])
}
```

### 4. Coordinate Space Naming

确保跨视图的一致坐标：

```swift
.coordinateSpace(.named(Keys.coordinate))
```

### 5. Z-Index Layering

标注层级管理：

```swift
.zIndex(Double(annotation.zIndex))
```

## Dependencies

### Framework Dependencies

| 框架 | 用途 |
|------|------|
| SwiftUI | UI 框架 |
| Combine | 响应式编程 |
| ScreenCaptureKit | 屏幕捕获 |
| Core Graphics | 图像处理 |
| CoreImage | 图像效果（模糊等） |
 

### Package Dependencies

- **KeyboardShortcuts** (2.3.0+) - 快捷键管理

## Permissions

### Screen Recording Permission

**文件:** `AppDelegate.swift`

```swift
CGPreflightScreenCaptureAccess()
CGRequestScreenCaptureAccess()
```

### Entitlements

- App Sandbox: enabled
- Application Groups: group.cn.wflixu.icap
- File Access: Pictures, Downloads, User Selected

## Localization

支持语言：
- English
- 简体中文 (zh-Hans)

**文件:** `Localizable.xcstrings`

## Build Configuration

- **Minimum macOS:** 15.0 (Sequoia)
- **Xcode:** 15.0+
- **Swift:** 5.10

## Development Workflow

### Build Commands

```bash
# Debug build
xcodebuild -project iCap.xcodeproj -scheme iCap -configuration Debug build

# Release build
xcodebuild -project iCap.xcodeproj -scheme iCap -configuration Release build

# Run tests
xcodebuild test -project iCap.xcodeproj -scheme iCap

# Unused code detection
periphery scan --project iCap.xcodeproj --scheme iCap
```

### Git Workflow

```bash
# View status
git status

# Stage files
git add .

# Commit
git commit -m "feat: add feature"

# Push
git push
```

## Future Enhancements

### Planned Features

1. 椭圆/圆形标注
2. 自由画笔工具
3. 多选和批量操作
4. 对齐和分布工具
5. 复制/粘贴标注
6. 旋转功能
7. 分组功能完善

### Technical Debt

- 马赛克导出时的真实模糊效果处理
- 内联文字编辑
- 更好的形状裁剪算法
- 性能优化（大量标注时）

## Related Documentation

- [README.md](README.md) - 项目介绍
- [README_CN.md](README_CN.md) - 中文介绍
- [CLAUDE.md](CLAUDE.md) - 开发指南
