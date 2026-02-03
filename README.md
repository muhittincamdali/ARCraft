# ARCraft

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2017%2B%20%7C%20visionOS%201%2B-blue.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Build](https://github.com/muhittincamdali/ARCraft/actions/workflows/ci.yml/badge.svg)](https://github.com/muhittincamdali/ARCraft/actions)

A comprehensive AR framework for building immersive augmented reality experiences on iOS and visionOS. ARCraft provides a modern, SwiftUI-native approach to AR development with a component-based architecture.

## Features

- **Session Management** - Easy-to-use AR session lifecycle with automatic state handling
- **Entity System** - Component-based entity architecture for flexible content management
- **Anchor Support** - World, image, plane, and object anchor types with tracking state
- **Gesture Recognition** - Built-in tap, pan, pinch, and rotation gesture handling
- **PBR Materials** - Physically-based rendering material system with full texture support
- **Physics Simulation** - Real-time physics with collision detection and response
- **Animation System** - Flexible animation framework with 20+ easing functions
- **World Persistence** - Save and restore AR experiences across sessions
- **SwiftUI Integration** - Native SwiftUI views and view modifiers

## Requirements

- iOS 17.0+ / visionOS 1.0+ / macOS 14.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add ARCraft to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/ARCraft.git", from: "1.0.0")
]
```

Or in Xcode:
1. Go to **File > Add Package Dependencies**
2. Enter the repository URL: `https://github.com/muhittincamdali/ARCraft.git`
3. Select version **1.0.0** or later

## Quick Start

### Basic AR View

```swift
import SwiftUI
import ARCraft

struct ContentView: View {
    @StateObject private var arView = ARCraftView()
    
    var body: some View {
        ARCraftViewRepresentable(arView: arView)
            .ignoresSafeArea()
            .onAppear {
                Task {
                    try await arView.start()
                    addContent()
                }
            }
    }
    
    func addContent() {
        // Create a cube
        let cube = ModelEntity.box(size: SIMD3<Float>(0.1, 0.1, 0.1))
        cube.transform.position = SIMD3<Float>(0, 0, -0.5)
        arView.addEntity(cube)
    }
}
```

### Working with Anchors

```swift
// Create and manage anchors
let anchorManager = AnchorManager()

// Add a world anchor at a position
let anchor = anchorManager.createWorldAnchor(
    at: SIMD3<Float>(0, 0, -1),
    name: "MyAnchor"
)

// Query anchors
let nearbyAnchors = anchorManager.anchors(within: 2.0, of: cameraPosition)
let planeAnchors = anchorManager.anchors(ofType: .plane)

// Listen to anchor events
anchorManager.eventPublisher
    .sink { event in
        switch event {
        case .added(let anchor):
            print("Anchor added: \(anchor.id)")
        case .updated(let anchor):
            print("Anchor updated: \(anchor.id)")
        case .removed(let anchor):
            print("Anchor removed: \(anchor.id)")
        }
    }
```

### Entity System

```swift
// Create entities
let entity = ARCraftEntity(name: "MyEntity")
entity.transform.position = SIMD3<Float>(0, 1, -2)

// Add child entities
let child = ARCraftEntity(name: "Child")
entity.addChild(child)

// Find entities
if let found = entity.findChild(named: "Child") {
    print("Found: \(found.name)")
}

// Use tags for grouping
entity.addTag("interactive")
entity.addTag("collectible")

if entity.hasTag("interactive") {
    // Handle interaction
}
```

### Model Entities

```swift
// Create primitive shapes
let sphere = ModelEntity.sphere(radius: 0.05)
let box = ModelEntity.box(size: SIMD3<Float>(0.1, 0.1, 0.1))
let cylinder = ModelEntity.cylinder(radius: 0.03, height: 0.1)

// Load models from files
let model = ModelEntity(modelNamed: "robot.usdz")
Task {
    try await model.load()
    arView.addEntity(model)
}

// Clone models
let clone = model.clone()
clone.transform.position.x += 0.5
```

### Materials

```swift
// Use the material builder
let gold = MaterialBuilder("Gold")
    .baseColor(Color4(hex: 0xFFD700))
    .metallic(1.0)
    .roughness(0.3)
    .build()

// Create PBR materials
let carPaint = PBRMaterial.carPaint(color: Color4(hex: 0xCC0000))
let glass = PBRMaterial.glass(color: .white, ior: 1.5)

// Use presets
let metalMaterial = MaterialPresets.metal(color: .gray)
let plasticMaterial = MaterialPresets.plastic(color: .blue)
```

### Gesture Handling

```swift
let gestureHandler = GestureHandler()
gestureHandler.configuration.enabledGestures = [.tap, .pan, .pinch]

gestureHandler.eventPublisher
    .sink { event in
        switch event.type {
        case .tap:
            handleTap(at: event.location)
        case .pan:
            handlePan(translation: event.translation)
        case .pinch:
            handlePinch(scale: event.scale)
        default:
            break
        }
    }
```

### Physics

```swift
// Create a physics world
let physicsWorld = PhysicsWorld()
physicsWorld.gravity = SIMD3<Float>(0, -9.81, 0)

// Add physics bodies
let body = PhysicsBody(entity: cube, type: .dynamic)
body.addShape(.box(SIMD3<Float>(0.1, 0.1, 0.1)))
body.material = .rubber
physicsWorld.addBody(body)

// Apply forces
body.applyForce(SIMD3<Float>(0, 100, 0))
body.applyImpulse(SIMD3<Float>(10, 0, 0))

// Simulate
physicsWorld.simulate(deltaTime: 1/60)
```

### Animations

```swift
let animationController = AnimationController()

// Animate position
animationController.animatePosition(
    of: entity,
    to: SIMD3<Float>(0, 1, 0),
    duration: 0.5,
    easing: .easeInOut
)

// Animate scale
animationController.animateScale(
    of: entity,
    to: SIMD3<Float>(2, 2, 2),
    duration: 0.3,
    easing: .easeOutBack
)

// Custom animations
let fadeIn = Animation(name: "FadeIn", duration: 0.5, easing: .easeIn)
fadeIn.loops = true
fadeIn.onUpdate = { progress in
    entity.opacity = progress
}
fadeIn.play()
```

### World Persistence

```swift
let worldMapManager = WorldMapManager()

// Save current experience
let mapData = worldMapManager.createMapData(
    from: session,
    coordinator: coordinator,
    name: "LivingRoom"
)
try worldMapManager.save(map: mapData)

// Load and restore
if let savedMap = try worldMapManager.load(name: "LivingRoom") {
    for anchor in savedMap.anchors {
        // Restore anchors
    }
    for entity in savedMap.entities {
        // Restore entities
    }
}

// List saved maps
let maps = try worldMapManager.listSavedMaps()
```

## Architecture

```
ARCraft/
├── Core/
│   ├── ARSession.swift        # Session management
│   ├── ARConfiguration.swift  # Configuration options
│   └── ARCoordinator.swift    # Main coordinator
├── Anchors/
│   ├── AnchorManager.swift    # Anchor management
│   ├── PlaneAnchor.swift      # Plane detection
│   ├── ImageAnchor.swift      # Image tracking
│   └── ObjectAnchor.swift     # Object tracking
├── Entities/
│   ├── Entity.swift           # Base entity class
│   ├── ModelEntity.swift      # 3D models
│   └── LightEntity.swift      # Lighting
├── Gestures/
│   ├── GestureHandler.swift   # Gesture recognition
│   ├── TapGesture.swift       # Tap handling
│   └── PanGesture.swift       # Pan/drag handling
├── Materials/
│   ├── MaterialBuilder.swift  # Material creation
│   └── PBRMaterial.swift      # PBR materials
├── Physics/
│   ├── PhysicsWorld.swift     # Physics simulation
│   └── CollisionComponent.swift # Collision detection
├── Rendering/
│   └── Renderer.swift         # Rendering pipeline
├── SwiftUI/
│   ├── ARView.swift           # Main AR view
│   └── ARViewRepresentable.swift # SwiftUI wrapper
├── Animations/
│   └── AnimationController.swift # Animation system
├── Persistence/
│   └── WorldMap.swift         # World persistence
└── Utilities/
    ├── ARMath.swift           # Math utilities
    └── Extensions.swift       # Swift extensions
```

## Tracking Modes

ARCraft supports multiple tracking modes:

| Mode | Description | Platform |
|------|-------------|----------|
| World | 6DOF world tracking | iOS, visionOS |
| Image | Reference image tracking | iOS |
| Face | Face tracking | iOS |
| Body | Full body pose | iOS |
| Object | 3D object detection | iOS |
| Hand | Hand tracking | visionOS |

## Easing Functions

The animation system includes 20+ easing functions:

- `linear` - Constant speed
- `easeIn`, `easeOut`, `easeInOut` - Cubic easing
- `easeInQuad`, `easeOutQuad`, `easeInOutQuad` - Quadratic
- `easeInCubic`, `easeOutCubic`, `easeInOutCubic` - Cubic
- `easeInExpo`, `easeOutExpo`, `easeInOutExpo` - Exponential
- `easeInBack`, `easeOutBack`, `easeInOutBack` - Back overshoot
- `easeInElastic`, `easeOutElastic`, `easeInOutElastic` - Elastic bounce
- `easeInBounce`, `easeOutBounce`, `easeInOutBounce` - Bouncing

## Configuration Options

```swift
let config = ARCraftConfiguration()

// Tracking
config.trackingMode = .world
config.planeDetection = [.horizontal, .vertical]
config.worldAlignment = .gravity

// Environment
config.environmentTexturing = .automatic
config.lightEstimation = .environmentalHDR

// Features
config.peopleOcclusion = true
config.sceneReconstruction = [.mesh]
config.collaborationEnabled = true

// Performance
config.targetFrameRate = 60
config.reducedProcessing = false
```

## Render Options

```swift
let options = RenderOptions()

options.quality = .high
options.shadowsEnabled = true
options.bloomEnabled = true
options.bloomIntensity = 0.5
options.aoEnabled = true
options.antiAliasingEnabled = true
options.toneMapping = .aces
```

## Best Practices

### Performance

1. **Use LOD** - Implement level-of-detail for complex models
2. **Pool Objects** - Reuse entities instead of creating/destroying
3. **Batch Materials** - Minimize unique material count
4. **Cull Aggressively** - Use frustum and occlusion culling

### Memory

1. **Release Resources** - Call `stop()` when AR session ends
2. **Compress Textures** - Use compressed formats for textures
3. **Limit Anchors** - Set reasonable anchor limits

### User Experience

1. **Coach Users** - Guide users to scan environment
2. **Handle Tracking Loss** - Gracefully handle tracking issues
3. **Provide Feedback** - Visual/haptic feedback for interactions

## Contributing

Contributions are welcome! Please read the contributing guidelines before submitting pull requests.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

ARCraft is available under the MIT License. See the [LICENSE](LICENSE) file for more information.

## Author

**Muhittin Camdali**

- GitHub: [@muhittincamdali](https://github.com/muhittincamdali)

## Acknowledgments

- Apple ARKit and RealityKit teams
- The Swift community
- All contributors

---

Built with ❤️ for the AR community
