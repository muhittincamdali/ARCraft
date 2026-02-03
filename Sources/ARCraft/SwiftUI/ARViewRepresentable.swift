//
//  ARViewRepresentable.swift
//  ARCraft
//
//  Created by Muhittin Camdali
//  Copyright © 2025 Muhittin Camdali. All rights reserved.
//

import SwiftUI
import Combine

#if canImport(UIKit)
import UIKit
#endif

#if canImport(RealityKit)
import RealityKit
#endif

// MARK: - AR Container View

#if os(iOS)

/// UIKit container view for AR content.
public class ARContainerView: UIView {
    
    /// The AR view being contained
    public let arView: ARCraftView
    
    /// Gesture recognizers
    private var tapGesture: UITapGestureRecognizer?
    private var panGesture: UIPanGestureRecognizer?
    private var pinchGesture: UIPinchGestureRecognizer?
    private var rotationGesture: UIRotationGestureRecognizer?
    private var longPressGesture: UILongPressGestureRecognizer?
    
    /// Creates a container view
    public init(arView: ARCraftView) {
        self.arView = arView
        super.init(frame: .zero)
        setupView()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .black
        isMultipleTouchEnabled = true
    }
    
    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
        tapGesture = tap
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)
        panGesture = pan
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        addGestureRecognizer(pinch)
        pinchGesture = pinch
        
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        addGestureRecognizer(rotation)
        rotationGesture = rotation
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.5
        addGestureRecognizer(longPress)
        longPressGesture = longPress
        
        // Allow simultaneous recognition
        pinch.delegate = self
        rotation.delegate = self
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        
        let touch = TouchPoint(
            id: 0,
            location: location,
            phase: .began
        )
        
        arView.gestureHandler.touchesBegan([touch])
        
        let endTouch = TouchPoint(
            id: 0,
            location: location,
            phase: .ended
        )
        arView.gestureHandler.touchesEnded([endTouch])
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        
        let phase: TouchPoint.TouchPhase
        switch gesture.state {
        case .began:
            phase = .began
        case .changed:
            phase = .moved
        case .ended, .cancelled:
            phase = .ended
        default:
            return
        }
        
        let touch = TouchPoint(id: 0, location: location, phase: phase)
        
        switch gesture.state {
        case .began:
            arView.gestureHandler.touchesBegan([touch])
        case .changed:
            arView.gestureHandler.touchesMoved([touch])
        case .ended:
            arView.gestureHandler.touchesEnded([touch])
        case .cancelled:
            arView.gestureHandler.touchesCancelled([touch])
        default:
            break
        }
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard gesture.numberOfTouches >= 2 else { return }
        
        let location1 = gesture.location(ofTouch: 0, in: self)
        let location2 = gesture.location(ofTouch: 1, in: self)
        
        let phase: TouchPoint.TouchPhase
        switch gesture.state {
        case .began: phase = .began
        case .changed: phase = .moved
        case .ended: phase = .ended
        default: return
        }
        
        let touch1 = TouchPoint(id: 0, location: location1, phase: phase)
        let touch2 = TouchPoint(id: 1, location: location2, phase: phase)
        
        switch gesture.state {
        case .began:
            arView.gestureHandler.touchesBegan([touch1, touch2])
        case .changed:
            arView.gestureHandler.touchesMoved([touch1, touch2])
        case .ended:
            arView.gestureHandler.touchesEnded([touch1, touch2])
        default:
            break
        }
    }
    
    @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        guard gesture.numberOfTouches >= 2 else { return }
        
        let location1 = gesture.location(ofTouch: 0, in: self)
        let location2 = gesture.location(ofTouch: 1, in: self)
        
        let phase: TouchPoint.TouchPhase
        switch gesture.state {
        case .began: phase = .began
        case .changed: phase = .moved
        case .ended: phase = .ended
        default: return
        }
        
        let touch1 = TouchPoint(id: 0, location: location1, phase: phase)
        let touch2 = TouchPoint(id: 1, location: location2, phase: phase)
        
        switch gesture.state {
        case .began:
            arView.gestureHandler.touchesBegan([touch1, touch2])
        case .changed:
            arView.gestureHandler.touchesMoved([touch1, touch2])
        case .ended:
            arView.gestureHandler.touchesEnded([touch1, touch2])
        default:
            break
        }
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let location = gesture.location(in: self)
        let touch = TouchPoint(id: 0, location: location, phase: .stationary)
        arView.gestureHandler.touchesBegan([touch])
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        Task { @MainActor in
            arView.frameSize = bounds.size
        }
    }
}

extension ARContainerView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // Allow pinch and rotation to work together
        if gestureRecognizer is UIPinchGestureRecognizer && otherGestureRecognizer is UIRotationGestureRecognizer {
            return true
        }
        if gestureRecognizer is UIRotationGestureRecognizer && otherGestureRecognizer is UIPinchGestureRecognizer {
            return true
        }
        return false
    }
}

#endif

// MARK: - SwiftUI Representable

#if os(iOS)

/// SwiftUI wrapper for ARCraftView.
///
/// Use this view to embed AR content in your SwiftUI hierarchy.
///
/// ## Example
///
/// ```swift
/// struct ContentView: View {
///     @StateObject private var arView = ARCraftView()
///     
///     var body: some View {
///         ARCraftViewRepresentable(arView: arView)
///             .ignoresSafeArea()
///             .onAppear {
///                 Task {
///                     try await arView.start()
///                 }
///             }
///     }
/// }
/// ```
public struct ARCraftViewRepresentable: UIViewRepresentable {
    
    /// The AR view to display
    @ObservedObject public var arView: ARCraftView
    
    /// Configuration for the view
    public var configuration: ARViewConfiguration
    
    /// Creates the representable
    public init(
        arView: ARCraftView,
        configuration: ARViewConfiguration = ARViewConfiguration()
    ) {
        self.arView = arView
        self.configuration = configuration
    }
    
    public func makeUIView(context: Context) -> ARContainerView {
        let container = ARContainerView(arView: arView)
        return container
    }
    
    public func updateUIView(_ uiView: ARContainerView, context: Context) {
        // Update configuration if needed
        arView.configuration = configuration
    }
    
    public static func dismantleUIView(_ uiView: ARContainerView, coordinator: ()) {
        uiView.arView.stop()
    }
}

#endif

// MARK: - macOS Representable

#if os(macOS)

import AppKit

/// AppKit container view for AR content (placeholder).
public class ARContainerView: NSView {
    public let arView: ARCraftView
    
    public init(arView: ARCraftView) {
        self.arView = arView
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// SwiftUI wrapper for macOS (placeholder).
public struct ARCraftViewRepresentable: NSViewRepresentable {
    @ObservedObject public var arView: ARCraftView
    public var configuration: ARViewConfiguration
    
    public init(
        arView: ARCraftView,
        configuration: ARViewConfiguration = ARViewConfiguration()
    ) {
        self.arView = arView
        self.configuration = configuration
    }
    
    public func makeNSView(context: Context) -> ARContainerView {
        ARContainerView(arView: arView)
    }
    
    public func updateNSView(_ nsView: ARContainerView, context: Context) {}
}

#endif

// MARK: - Convenience Initializers

public extension ARCraftViewRepresentable {
    /// Creates with default session
    init() {
        self.init(
            arView: ARCraftView(),
            configuration: ARViewConfiguration()
        )
    }
    
    /// Creates with custom configuration
    init(configuration: ARViewConfiguration) {
        self.init(
            arView: ARCraftView(configuration: configuration),
            configuration: configuration
        )
    }
}

// MARK: - Preview Provider

#if DEBUG
struct ARCraftViewRepresentable_Previews: PreviewProvider {
    static var previews: some View {
        ARCraftViewRepresentable()
            .ignoresSafeArea()
    }
}
#endif
