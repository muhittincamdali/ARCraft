# Basic AR Example

A simple example demonstrating basic ARCraft features.

## Features

- Plane detection
- Model placement
- Gesture interactions
- Coaching overlay

## Usage

```swift
import ARCraft
import SwiftUI

struct ContentView: View {
    var body: some View {
        ARView {
            // Detect horizontal planes and place a cube
            PlaneAnchor(.horizontal) {
                Box(size: 0.1)
                    .material(.color(.blue))
                    .gesture(TapGesture().onEnded {
                        print("Box tapped!")
                    })
            }
        }
        .coachingOverlay(true)
    }
}
```

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Physical device with ARKit support

## Running the Example

1. Open the project in Xcode
2. Select your physical device
3. Build and run

## Notes

- AR features require a physical device
- Ensure good lighting for plane detection
