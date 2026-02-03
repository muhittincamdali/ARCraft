<div align="center">

# 🥽 ARCraft

**Declarative AR framework for iOS & visionOS with SwiftUI-style syntax**

[![Swift](https://img.shields.io/badge/Swift-5.9+-F05138?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-15.0+-000000?style=for-the-badge&logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![visionOS](https://img.shields.io/badge/visionOS-1.0+-007AFF?style=for-the-badge&logo=apple&logoColor=white)](https://developer.apple.com/visionos/)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

</div>

---

## ✨ Features

- 🎯 **Declarative** — SwiftUI-style AR scenes
- 🥽 **visionOS Ready** — RealityKit 4 support
- 📦 **3D Assets** — USDZ/Reality Composer
- 🎮 **Interactions** — Tap, drag, scale gestures
- 🌍 **World Tracking** — Planes, anchors, images

---

## 🚀 Quick Start

```swift
import ARCraft

ARView {
    ARAnchor(.horizontal) {
        Model("robot.usdz")
            .scale(0.1)
            .onTap { entity in
                entity.playAnimation("wave")
            }
    }
    
    ARImageAnchor(named: "poster") {
        VideoPlayer(url: videoURL)
    }
}
```

---

## 📄 License

MIT • [@muhittincamdali](https://github.com/muhittincamdali)
