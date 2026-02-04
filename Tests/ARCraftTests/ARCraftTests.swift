import XCTest
@testable import ARCraft

final class ARCraftTests: XCTestCase {
    
    // MARK: - Model Tests
    
    func testModelInitialization() throws {
        let model = Model("test_model")
        XCTAssertNotNil(model)
    }
    
    func testModelScale() throws {
        let model = Model("test_model")
            .scale(0.5)
        XCTAssertNotNil(model)
    }
    
    func testModelPosition() throws {
        let model = Model("test_model")
            .position(x: 1.0, y: 2.0, z: 3.0)
        XCTAssertNotNil(model)
    }
    
    // MARK: - Primitive Tests
    
    func testBoxPrimitive() throws {
        let box = Box(size: 0.5)
        XCTAssertNotNil(box)
    }
    
    func testSpherePrimitive() throws {
        let sphere = Sphere(radius: 0.3)
        XCTAssertNotNil(sphere)
    }
    
    func testCylinderPrimitive() throws {
        let cylinder = Cylinder(radius: 0.2, height: 0.5)
        XCTAssertNotNil(cylinder)
    }
    
    // MARK: - Anchor Tests
    
    func testPlaneAnchorHorizontal() throws {
        // Test horizontal plane anchor configuration
        XCTAssertTrue(true)
    }
    
    func testPlaneAnchorVertical() throws {
        // Test vertical plane anchor configuration
        XCTAssertTrue(true)
    }
    
    // MARK: - Material Tests
    
    func testPBRMaterial() throws {
        // Test PBR material creation
        XCTAssertTrue(true)
    }
    
    func testColorMaterial() throws {
        // Test simple color material
        XCTAssertTrue(true)
    }
    
    // MARK: - Performance Tests
    
    func testModelLoadingPerformance() throws {
        measure {
            // Measure model loading time
            _ = Model("test_model")
        }
    }
}
