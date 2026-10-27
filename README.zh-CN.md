<!-- i18n-source: README.md@82cfebf386a0495e4dc0d749638d4e7ac6f8f4d0 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/banner-light.svg" alt="ARCraft: Hand gestures, jitter filters, surface placement and world anchor persistence for visionOS and iOS apps."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/ARCraft/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/ARCraft/actions/workflows/ci.yml/badge.svg" alt="CI 状态"></a>
<a href="https://github.com/muhittincamdali/ARCraft/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-version-light.svg" alt="最新版本: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-platforms-light.svg" alt="支持的平台: iOS 18+ · macOS 15+ · visionOS 2+"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-language-light.svg" alt="语言版本: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-license-light.svg" alt="许可证: MIT"></picture></a>
</p>

<p align="center">
<a href="#快速开始"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-start-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-start-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-start-zh-CN-light.svg" alt="开始使用"></picture></a>
<a href="https://muhittincamdali.github.io/ARCraft/documentation/arcraft/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-docs-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-docs-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-docs-zh-CN-light.svg" alt="文档"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-examples-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-examples-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-examples-zh-CN-light.svg" alt="示例"></picture></a>
</p>

> 本文是英文 README 的译文。如两者内容不一致，以英文版为准。

<!-- brand:end -->

ARCraft 是一个 Swift 包，面向使用手部追踪和世界锚点（world anchor）的 visionOS 与 iOS 应用。它并不封装 RealityKit：RealityKit 已经负责渲染、模拟和操作实体。ARCraft 覆盖的是介于 ARKit 原始数据与你的场景之间的那部分代码，每个空间应用原本都要各自重写一遍：无闪烁地识别捏合手势、让指尖光标保持稳定、把桌面上的一次点击变成直立且吸附对齐的位姿，以及在多次启动之间记住哪些内容属于哪个世界锚点。核心部分是纯 Swift 和 `simd`，没有任何依赖，因此可以在 Mac、模拟器和预览中运行并接受测试；轻量的适配层则把它连接到 visionOS 上的 ARKit、iOS 和 macOS 上 Vision 的手部姿态，以及 RealityKit 实体。

## 亮点

- **不闪烁的手势** — `HandGestureRecognizer` 在与尺度无关的手形分类器（捏合、指向、握拳、张开手掌，可处理以米为单位的 ARKit 数据和以像素为单位的 Vision 数据）之上，增加了帧级防抖、更宽的捏合释放距离，以及追踪丢失时自动取消。
- **抖动过滤** — `OneEuroFilter` 和 `PoseFilter` 对指尖、手腕和锚点进行平滑：静止时强力平滑，运动时轻度平滑，并忽略 NaN 样本和乱序时间戳。
- **表面放置** — `PlacementSolver` 让内容在桌面上保持直立、在墙面上贴平并朝向观察者，还可选网格吸附和旋转吸附；`SpatialBounds` 可将尺寸未知的模型缩放进一个体积内。
- **留在房间里的内容** — `AnchoredItem`、`AnchorResolver` 和 `PlacementStore` 记录相对于哪个 `WorldAnchor` 放置了什么，并把读回的文件视为不可信输入：解析前先检查大小限制、带有版本号，且单个损坏的条目不会导致其余条目丢失。
- **没有头显也能用** — `SyntheticHand` 为模拟器、预览和测试生成手部姿态；`HandPose` 支持 `Codable`，可用于录制和回放。
- **经过测试** — 103 个 Swift Testing 测试在 macOS 和 iPhone 模拟器上运行（在 visionOS 模拟器上为 105 个，包含 ARKit 适配层），并且下面每个 README 示例都由测试 target 编译并运行。

### 包含的内容

| 领域 | 类型 |
| --- | --- |
| 手部 | `HandPose`, `HandJoint`, `Finger`, `HandShapeClassifier`, `HandShapeReading`, `HandGestureRecognizer`, `HandGestureEvent`, `SyntheticHand` |
| 过滤 | `OneEuroFilter`, `OneEuroConfiguration`, `PoseFilter` |
| 放置 | `PlacementSolver`, `PlacementOptions`, `Placement`, `SurfaceHit`, `SurfaceOrientation`, `SpatialBounds`, `Entity.setPose(_:relativeTo:)`, `Entity.scaleToFit(_:allowsUpscaling:)` |
| 持久化 | `AnchoredItem`, `WorldAnchorState`, `AnchorResolver`, `ItemStatus`, `PlacementArchive`, `PlacementStore` |
| 几何 | `Pose` （位置和单位四元数，`Codable`，拒绝 NaN） |
| 适配层 | visionOS 上：`HandPose(_: HandAnchor, timestamp:)`, `WorldAnchorState(_: WorldAnchor)`, `AnchorResolver.apply(_:)`；Vision 上：`HandPose(_: HumanHandPoseObservation, imageSize:timestamp:)` |

## 快速开始

**1. 添加软件包**

在 Xcode 中选择 **File › Add Package Dependencies…**，然后输入仓库地址：

```text
https://github.com/muhittincamdali/ARCraft.git
```

把它粘贴到窗口右上角的搜索框中，将 **Dependency Rule** 设为 **Branch** › `main`，然后点击 **Add Package**。在接下来的窗口中，在 **ARCraft** 旁选择你的 app target，再次点击 **Add Package**。

**2. 导入模块**

```swift
import ARCraft
```

把这一行放在你使用 ARCraft 的 Swift 文件顶部。

**3. 开始使用**

把这个函数添加到应用中的任意 Swift 文件（或单元测试）里，然后调用 `print(pinchDemo())`。它以每秒 90 帧的速度合上再张开一只合成手，因此在任何设备和模拟器上都能运行：

```swift
func pinchDemo() -> [String] {
    var pinch = HandGestureRecognizer(configuration: .init(shape: .pinch))
    var log: [String] = []
    let closing: [Float] = [0, 0.3, 0.6, 0.9, 1, 1, 1, 0.6, 0.3, 0.1, 0]
    for (frame, amount) in closing.enumerated() {
        let pose = SyntheticHand.openPalm
            .interpolated(to: .pinch, fraction: amount)
            .pose(timestamp: Double(frame) / 90)
        for event in pinch.update(with: pose) {
            switch event {
            case .began: log.append("pinch began at frame \(frame)")
            case .ended: log.append("pinch ended at frame \(frame)")
            case .changed, .cancelled: break
            }
        }
    }
    return log
}
```

输出为 `["pinch began at frame 4", "pinch ended at frame 9"]`。捏合在第二个闭合帧开始，并在连续三帧张开并超过释放距离后结束，这正是它不会闪烁的原因。在 Apple Vision Pro 上，你用 `HandPose(update.anchor, timestamp: update.timestamp)` 为同一个 recognizer 提供数据，详见[使用方法](#使用方法)一节。

## 安装

### Swift Package Manager

在 Xcode 中选择 **File › Add Package Dependencies…**，然后输入仓库地址：

```text
https://github.com/muhittincamdali/ARCraft.git
```

在 `Package.swift` 清单中添加该包及其 product：

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/ARCraft.git", branch: "main")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "ARCraft", package: "ARCraft")
    ])
]
```

这里描述的 API 位于 `main` 分支。目前唯一的标签 `v1.0.0` 创建于库源码加入之前，因此在下一个版本打上标签之前，请依赖 `main`（参见[更新日志](CHANGELOG.md)）。

## 使用方法

下面的每个示例都复制自[示例应用](Examples/ARCraftLab)，CI 会为 iOS、macOS 和 visionOS 构建它。

### 在 Apple Vision Pro 上识别捏合

摘自 [`LiveSpaceModel.swift`](Examples/ARCraftLab/ARCraftLab/LiveSpaceModel.swift)，它运行在 `ImmersiveSpace` 中，且 Info.plist 里包含 `NSHandsTrackingUsageDescription`：

```swift
private func processHands() async {
    for await update in handTracking.anchorUpdates where update.anchor.chirality == .right {
        guard let pose = HandPose(update.anchor, timestamp: update.timestamp) else {
            if pinch.trackingLost(at: update.timestamp) == .cancelled { isPinching = false }
            fingertip = nil
            fingertipFilter.reset()
            continue
        }
        fingertip = pose[.indexFingerTip].flatMap { fingertipFilter.filter($0, at: update.timestamp) }
        for event in pinch.update(with: pose) {
            await handle(event)
        }
    }
}
```

`pinch` 是一个 `HandGestureRecognizer(configuration: .init(shape: .pinch))`；当手丢失的时间超过容差时，手势会被取消而不是结束，因此手移出视野时绝不会放置任何东西。

### 平滑指尖

```swift
func smoothFingertip(_ samples: [(time: TimeInterval, position: SIMD3<Float>)]) -> [SIMD3<Float>] {
    var filter = OneEuroFilter<SIMD3<Float>>(configuration: .handJoints)
    return samples.compactMap { filter.filter($0.position, at: $0.time) }
}
```

### 把内容放到桌面上

```swift
func placeOnTable() throws -> Placement {
    let solver = PlacementSolver(options: .init(gridSize: 0.05, rotationStep: .pi / 4))
    let tap = SurfaceHit(position: SIMD3(0.42, 0.74, -0.81), normal: SIMD3(0, 1, 0))
    return try solver.place(on: tap, facing: SIMD3(0, 1.6, 0))
}
```

内容直立于 `(0.40, 0.74, -0.80)`，并以 45° 为步长朝向观察者。它的正面是其 +Z 轴，这是 USD 的约定。如果放在墙上，它会贴平墙面，朝外。

### 适配未知尺寸的模型

```swift
func fitModel() -> Float {
    guard let bounds = SpatialBounds(min: SIMD3(-60, 0, -40), max: SIMD3(60, 90, 40)) else { return 1 }
    return bounds.scaleToFit(SIMD3(repeating: 0.3))
}
```

返回 `0.0025`：原本宽 120 个单位的模型会变成 30 厘米宽。对于 RealityKit 实体，请改为调用 `entity.scaleToFit(SIMD3(repeating: 0.3))`。

### 保存已放置的内容并恢复

```swift
func saveAndRestore(in folder: URL) async throws -> [ItemStatus] {
    let store = PlacementStore(fileURL: folder.appendingPathComponent("room.json"))
    let anchor = WorldAnchorState(id: UUID(), pose: Pose(position: SIMD3(0, 0.8, -1)))
    let lamp = AnchoredItem(kind: "lamp", worldPose: Pose(position: SIMD3(0.2, 0.8, -1.1)), anchor: anchor)
    try await store.save([lamp])

    // Next launch: ARKit reports the anchor again and the store returns the items.
    var resolver = AnchorResolver()
    resolver.update(anchor)
    let restored = try await store.load().items
    return restored.map { resolver.status(of: $0) }
}
```

在 visionOS 上，锚点来自 `WorldTrackingProvider`。实时空间会把新内容挂到 50 厘米范围内一个已追踪的锚点上，或者新建一个锚点：

```swift
private func place(kind: String, at worldPose: Pose) async {
    let anchor: WorldAnchorState
    if let nearby = resolver.nearestTrackedAnchor(to: worldPose.position, within: 0.5) {
        anchor = nearby
    } else {
        let worldAnchor = WorldAnchor(originFromAnchorTransform: worldPose.matrix)
        do {
            try await worldTracking.addAnchor(worldAnchor)
        } catch {
            status = .failed(error.localizedDescription)
            return
        }
        guard let state = WorldAnchorState(worldAnchor) else { return }
        resolver.update(state)
        anchor = state
    }
    items.append(AnchoredItem(kind: kind, worldPose: worldPose, anchor: anchor))
    do {
        try await store?.save(items)
    } catch {
        status = .failed(error.localizedDescription)
    }
}
```

## 演示

[示例应用](Examples/ARCraftLab)的界面，由 [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) 从 iOS 模拟器截取。每个界面都使用合成数据或录制数据运行 ARCraft。

| 手势 | 平滑 | 放置 | 持久化 |
| --- | --- | --- | --- |
| ![手势, 浅色](docs/images/gestures-light.png) | ![平滑, 浅色](docs/images/smoothing-light.png) | ![放置, 浅色](docs/images/placement-light.png) | ![持久化, 浅色](docs/images/persistence-light.png) |
| ![手势, 深色](docs/images/gestures-dark.png) | ![平滑, 深色](docs/images/smoothing-dark.png) | ![放置, 深色](docs/images/placement-dark.png) | ![持久化, 深色](docs/images/persistence-dark.png) |

## 文档

- [API 参考](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/) （DocC，从 `main` 分支发布到 GitHub Pages）
- 在 Xcode 中通过 **Product › Build Documentation** 在本地构建，或在命令行中构建：

```sh
xcodebuild docbuild -scheme ARCraft -destination 'generic/platform=visionOS Simulator'
```

## 指南

- [Getting Started](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/gettingstarted) — 添加该包，先在合成数据上识别捏合，再在 ARKit 数据上识别 （[源码](Sources/ARCraft/ARCraft.docc/GettingStarted.md)）。
- [Recognizing Hand Gestures](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/recognizinghandgestures) — 手形如何测量、防抖、迟滞、追踪丢失、双手，以及 iOS 上的 Vision （[源码](Sources/ARCraft/ARCraft.docc/RecognizingHandGestures.md)）。
- [Smoothing Tracking Data](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/smoothingtrackingdata) — 调节 One Euro 过滤器并平滑位姿 （[源码](Sources/ARCraft/ARCraft.docc/SmoothingTrackingData.md)）。
- [Placing Content on Surfaces](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/placingcontentonsurfaces) — 地面、墙面、吸附，以及缩放模型使其适配 （[源码](Sources/ARCraft/ARCraft.docc/PlacingContentOnSurfaces.md)）。
- [Persisting Placed Content](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/persistingplacedcontent) — 世界锚点、启动时恢复、清理，以及文件格式的限制 （[源码](Sources/ARCraft/ARCraft.docc/PersistingPlacedContent.md)）。
- [Testing Without a Headset](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/testingwithoutaheadset) — 合成手与录制手，以及单元测试中的锚点 （[源码](Sources/ARCraft/ARCraft.docc/TestingWithoutAHeadset.md)）。

## 系统要求

| 平台 | 最低版本 |
| --- | --- |
| iOS | 18 |
| macOS | 15 |
| visionOS | 2 |
| 工具链 | Swift 6.2 · Xcode 26+ |

手部追踪和世界追踪需要 Apple Vision Pro；ARKit 适配层只为 visionOS 编译。CI 使用 GitHub 的 `macos-26` runner 镜像中默认的 Xcode 进行构建。该包使用 Xcode 27 开发，面向 iOS 27 和 visionOS 27 SDK。

## 何时选择其他方案

- **用标准手势移动、旋转和缩放实体：** RealityKit 的 `ManipulationComponent`（visionOS 26）和 `GestureComponent` 无需额外代码即可完成。
- **按相似度匹配自定义静态手部姿态：** [HandVector](https://github.com/XanderXu/HandVector) 将整只手的关节向量与录制好的模板进行比较；ARCraft 则用明确的阈值对四种固定手形进行分类。
- **以 SwiftUI modifier 形式提供的语义手势（拍手、打响指、出拳）：** [HandGesture](https://github.com/johnhaney/HandGesture)。
- **3D 界面控件（以实体形式呈现的开关、滑块、按钮）：** [RealityUI](https://github.com/maxxfrazer/RealityUI)。

## 架构

- `Sources/ARCraft/Math`、`Filtering`、`Hands`、`Placement` 和 `Persistence` 是只使用 Foundation 和 `simd` 的值类型。`PlacementStore` 是唯一的引用类型（一个对文件访问进行串行化的 actor）。
- `Sources/ARCraft/Platform` 存放适配层：`ARKit+ARCraft.swift`（仅 visionOS）和 `Vision+ARCraft.swift`。`Placement/Entity+ARCraft.swift` 添加了 RealityKit 辅助方法。
- 每个接受外部输入的类型都会在边界处进行校验：矩阵和解码得到的数字必须是有限值，配置值会被限制在范围内，集合和文件有大小限制，文件名不能跳出应用的文件夹。
- 测试位于 `Tests/ARCraftTests`（Swift Testing）。手形分类器既用合成手测试，也用手工录入的关节数据测试，因此二者并不只是彼此吻合。

在本地运行测试：

```sh
swift test                                    # macOS
xcodebuild test -scheme ARCraft \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
xcodebuild test -scheme ARCraft \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

## 路线图

- 为 2.0.0 版本打标签，并将该包添加到 Swift Package Index；`.spi.yml` 已经在仓库中。
- 基于 `HandGestureRecognizer` 实现双手手势（在两个捏合点之间缩放和旋转）。
- 按平面锚点的范围进行放置，使内容保持在检测到的桌面边缘之内。

## 参与贡献

欢迎参与贡献。提交 pull request 之前，请先阅读[贡献指南](https://github.com/muhittincamdali/ARCraft/blob/main/CONTRIBUTING.md)和[行为准则](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md)。如发现安全问题，请按照[安全策略](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md)私下报告。

## 许可证

基于 MIT 许可证发布。详见 [LICENSE](LICENSE)。
