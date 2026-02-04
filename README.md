<p align="center">
  <img src="Assets/logo.png" alt="ARCraft" width="200"/>
</p>

<h1 align="center">ARCraft</h1>

<p align="center">
  <strong>🥽 Declarative AR framework for iOS & visionOS with SwiftUI-style syntax</strong>
</p>

<p align="center">
  <a href="https://github.com/muhittincamdali/ARCraft/actions/workflows/ci.yml">
    <img src="https://github.com/muhittincamdali/ARCraft/actions/workflows/ci.yml/badge.svg" alt="CI Status"/>
  </a>
  <img src="https://img.shields.io/badge/Swift-6.0-FA7343?style=flat-square&logo=swift&logoColor=white" alt="Swift 6.0"/>
  <img src="https://img.shields.io/badge/iOS-17.0+-000000?style=flat-square&logo=apple&logoColor=white" alt="iOS 17.0+"/>
  <img src="https://img.shields.io/badge/visionOS-2.0+-7D4CDB?style=flat-square&logo=apple&logoColor=white" alt="visionOS 2.0+"/>
  <img src="https://img.shields.io/badge/SPM-Compatible-FA7343?style=flat-square&logo=swift&logoColor=white" alt="SPM"/>
  <a href="https://cocoapods.org/pods/ARCraft">
    <img src="https://img.shields.io/badge/CocoaPods-Compatible-EE3322?style=flat-square&logo=cocoapods&logoColor=white" alt="CocoaPods"/>
  </a>
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="License"/>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#quick-start">Quick Start</a> •
  <a href="#documentation">Documentation</a> •
  <a href="#contributing">Contributing</a>
</p>

---

## 📋 Table of Contents

- [Why ARCraft?](#why-arcraft)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
  - [Swift Package Manager](#swift-package-manager)
  - [CocoaPods](#cocoapods)
- [Quick Start](#quick-start)
- [Documentation](#documentation)
  - [3D Models](#3d-models)
  - [Anchors](#anchors)
  - [Gestures](#gestures)
  - [Materials](#materials)
  - [visionOS Support](#visionos-support)
- [Examples](#examples)
- [Contributing](#contributing)
- [License](#license)
- [Star History](#-star-history)

---

## Why ARCraft?

ARKit and RealityKit are powerful but complex. **ARCraft** provides a SwiftUI-style declarative API for building AR experiences with minimal boilerplate.

```swift
import ARCraft

struct MyARView: View {
    var body: some View {
        ARView {
            // Place 3D model on detected plane
            Model("robot")
                .placement(.horizontal)
                .scale(0.5)
                .onTap { print("Robot tapped!") }
            
            // Add floating text
            Text3D("Hello AR!")
                .position(y: 1.5)
                .billboard()
        }
        .coachingOverlay(true)
    }
}
```

## Features

| Feature | Description |
|---------|-------------|
| 🎯 **Declarative API** | SwiftUI-style syntax for AR |
| 📍 **Plane Detection** | Horizontal & vertical surfaces |
| 🖼️ **Image Tracking** | Recognize and track images |
| 👤 **Face Tracking** | Face mesh and landmarks |
| 🌍 **World Tracking** | 6DOF positioning |
| ✋ **Gestures** | Tap, drag, rotate, scale |
| 🔊 **Spatial Audio** | 3D positional sound |
| 🥽 **visionOS Ready** | Full visionOS 2.0 support |
| ⚡ **Performance** | Optimized rendering pipeline |
| 🧪 **Testable** | Mock AR sessions for testing |

## Requirements

| Platform | Minimum Version |
|----------|-----------------|
| iOS | 17.0+ |
| visionOS | 2.0+ |
| Xcode | 15.0+ |
| Swift | 5.9+ |

## Installation

### Swift Package Manager

Add ARCraft to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/ARCraft.git", from: "1.0.0")
]
```

Or in Xcode: **File → Add Package Dependencies** → Enter the repository URL.

### CocoaPods

Add to your `Podfile`:

```ruby
pod 'ARCraft', '~> 1.0'
```

Then run:

```bash
pod install
```

## Quick Start

### 1. Import the Framework

```swift
import ARCraft
```

### 2. Create Your AR View

```swift
struct ARExperience: View {
    var body: some View {
        ARView {
            // Place furniture on horizontal surfaces
            Model("furniture")
                .placement(.horizontal(.floor))
                .gesture(DragGesture())
            
            // Track a poster image
            ImageAnchor("poster") {
                Video("promo.mp4")
                    .autoPlay()
            }
            
            // Add face filter
            FaceAnchor {
                Model("glasses")
                    .attachment(.eyes)
            }
        }
        .coachingOverlay(true)
    }
}
```

### 3. Run Your App

```bash
# Build and run on device (AR requires physical device)
xcodebuild -scheme MyApp -destination 'platform=iOS,name=My iPhone'
```

## Documentation

### 3D Models

```swift
// From bundle
Model("character")

// From URL
Model(url: modelURL)

// Primitives
Box(size: 0.5)
Sphere(radius: 0.3)
Cylinder(radius: 0.2, height: 0.5)
Plane(width: 1.0, height: 0.5)
```

### Anchors

```swift
// Plane anchor - place on detected surfaces
PlaneAnchor(.horizontal) {
    Model("table")
}

// Image anchor - track reference images
ImageAnchor("marker") {
    Model("product")
        .animation(.rotate)
}

// Face anchor - face tracking
FaceAnchor {
    Model("mask")
        .attachment(.nose)
}

// Body anchor (visionOS)
BodyAnchor {
    Model("avatar")
}

// World anchor - fixed position
WorldAnchor(position: [0, 0, -1]) {
    Model("floating_object")
}
```

### Gestures

```swift
Model("object")
    .gesture(TapGesture().onEnded { location in
        print("Tapped at \(location)")
    })
    .gesture(DragGesture().onChanged { value in
        print("Dragging: \(value.translation)")
    })
    .gesture(RotateGesture().onChanged { angle in
        print("Rotating: \(angle)")
    })
    .gesture(ScaleGesture().onChanged { scale in
        print("Scaling: \(scale)")
    })
```

### Materials

```swift
// PBR Material
Model("object")
    .material(.pbr(
        baseColor: .blue,
        metallic: 0.8,
        roughness: 0.2
    ))

// Simple color
Model("cube")
    .material(.color(.red))

// Texture
Model("sphere")
    .material(.texture("earth_texture"))

// Unlit (no lighting)
Model("sign")
    .material(.unlit(color: .white))
```

### visionOS Support

```swift
// Shared space (default window)
WindowGroup {
    ARView {
        Model("decoration")
            .placement(.table)
    }
}

// Full immersive space
ImmersiveSpace(id: "immersive") {
    ARView {
        Model("environment")
    }
    .immersionStyle(.full)
}

// Mixed immersion
ImmersiveSpace(id: "mixed") {
    ARView {
        Model("virtual_pet")
    }
    .immersionStyle(.mixed)
}
```

## Examples

Check out the [Examples](Examples/) directory for complete sample projects:

- **BasicARExample** - Simple plane detection and model placement
- **ImageTrackingExample** - Track images and overlay content
- **FaceFilterExample** - Face tracking with accessories
- **visionOSExample** - visionOS immersive experience

## Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

ARCraft is released under the MIT License. See [LICENSE](LICENSE) for details.

---

## 📈 Star History

<a href="https://star-history.com/#muhittincamdali/ARCraft&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=muhittincamdali/ARCraft&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=muhittincamdali/ARCraft&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=muhittincamdali/ARCraft&type=Date" />
 </picture>
</a>

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/muhittincamdali">Muhittin Camdali</a>
</p>
