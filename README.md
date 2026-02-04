<p align="center">
  <img src="Assets/logo.png" alt="ARCraft" width="200"/>
</p>

<h1 align="center">ARCraft</h1>

<p align="center">
  <strong>🥽 Declarative AR framework for iOS & visionOS with SwiftUI-style syntax</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Swift-6.0-orange.svg" alt="Swift"/>
  <img src="https://img.shields.io/badge/iOS-17.0+-blue.svg" alt="iOS"/>
  <img src="https://img.shields.io/badge/visionOS-2.0+-purple.svg" alt="visionOS"/>
</p>

---

## Why ARCraft?

ARKit and RealityKit are powerful but complex. **ARCraft** provides a SwiftUI-style declarative API for building AR experiences.

```swift
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
```

## Features

| Feature | Description |
|---------|-------------|
| 🎯 **Declarative** | SwiftUI-style syntax |
| 📍 **Plane Detection** | Horizontal & vertical surfaces |
| 🖼️ **Image Tracking** | Recognize and track images |
| 👤 **Face Tracking** | Face mesh and landmarks |
| 🌍 **World Tracking** | 6DOF positioning |
| ✋ **Gestures** | Tap, drag, rotate, scale |
| 🔊 **Spatial Audio** | 3D positional sound |

## Quick Start

```swift
import ARCraft

struct ARExperience: View {
    var body: some View {
        ARView {
            // Place on horizontal surfaces
            Model("furniture")
                .placement(.horizontal(.floor))
                .gesture(DragGesture())
            
            // Track image
            ImageAnchor("poster") {
                Video("promo.mp4")
                    .autoPlay()
            }
            
            // Face filter
            FaceAnchor {
                Model("glasses")
                    .attachment(.eyes)
            }
        }
        .coachingOverlay(true)
    }
}
```

## 3D Models

```swift
// From bundle
Model("character")

// From URL
Model(url: modelURL)

// Primitives
Box(size: 0.5)
Sphere(radius: 0.3)
Cylinder(radius: 0.2, height: 0.5)
```

## Anchors

```swift
// Plane anchor
PlaneAnchor(.horizontal) {
    Model("table")
}

// Image anchor
ImageAnchor("marker") {
    Model("product")
}

// Face anchor
FaceAnchor {
    Model("mask")
}

// Body anchor (visionOS)
BodyAnchor {
    Model("avatar")
}
```

## Gestures

```swift
Model("object")
    .gesture(TapGesture().onTap { ... })
    .gesture(DragGesture().onDrag { ... })
    .gesture(RotateGesture().onRotate { ... })
    .gesture(ScaleGesture().onScale { ... })
```

## Materials

```swift
Model("object")
    .material(.pbr(
        baseColor: .blue,
        metallic: 0.8,
        roughness: 0.2
    ))
```

## visionOS Support

```swift
// Shared space
WindowGroup {
    ARView { ... }
}

// Immersive space
ImmersiveSpace {
    ARView { ... }
        .immersionStyle(.full)
}
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT License
