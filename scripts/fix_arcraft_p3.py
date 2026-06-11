import os
import re

dir_path = "<path>"

def fix_arview_representable():
    path = os.path.join(dir_path, "SwiftUI/ARViewRepresentable.swift")
    if not os.path.exists(path): return
    with open(path, 'r') as f: content = f.read()
    
    # Needs @MainActor
    if '@MainActor' not in content:
        content = content.replace('public struct ARViewRepresentable', '@MainActor\npublic struct ARViewRepresentable')
        
    content = content.replace('arView: ARCraftView(),', 'arView: ARCraftView(session: ARCraftSession()),')
    content = content.replace('arView: ARCraftView(configuration: configuration),', 'arView: ARCraftView(configuration: configuration, session: ARCraftSession()),')
    
    with open(path, 'w') as f: f.write(content)
    print("Fixed ARViewRepresentable.swift")

def fix_worldmap():
    path = os.path.join(dir_path, "Persistence/WorldMap.swift")
    if not os.path.exists(path): return
    with open(path, 'r') as f: content = f.read()
    content = content.replace('public func createMapData(', '@MainActor\n    public func createMapData(')
    with open(path, 'w') as f: f.write(content)
    print("Fixed WorldMap.swift")

def fix_anchor_manager():
    path = os.path.join(dir_path, "Anchors/AnchorManager.swift")
    if not os.path.exists(path): return
    with open(path, 'r') as f: content = f.read()
    content = content.replace('public final class ManagedAnchor: @unchecked Sendable', 'public final class ManagedAnchor: @unchecked Sendable')
    content = content.replace('public final class AnchorManager: @unchecked Sendable', 'public final class AnchorManager: @unchecked Sendable')
    # If they don't have @unchecked Sendable, add it
    if 'class ManagedAnchor: Sendable' in content:
        content = content.replace('class ManagedAnchor: Sendable', 'class ManagedAnchor: @unchecked Sendable')
    if 'class AnchorManager: Sendable' in content:
        content = content.replace('class AnchorManager: Sendable', 'class AnchorManager: @unchecked Sendable')
    # Better yet, regex
    content = re.sub(r'class\s+ManagedAnchor(.*?):\s*Sendable', r'class ManagedAnchor\1: @unchecked Sendable', content)
    content = re.sub(r'class\s+AnchorManager(.*?):\s*Sendable', r'class AnchorManager\1: @unchecked Sendable', content)
    # Deduplicate
    content = content.replace(': @unchecked Sendable: @unchecked Sendable', ': @unchecked Sendable')
    
    with open(path, 'w') as f: f.write(content)
    print("Fixed AnchorManager.swift")

fix_arview_representable()
fix_worldmap()
fix_anchor_manager()
