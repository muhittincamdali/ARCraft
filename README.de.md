<!-- i18n-source: README.md@f321bb38071894405d44819e7cf9ff20c750b9cd status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/banner-light.svg" alt="ARCraft: Hand gestures, jitter filters, surface placement and world anchor persistence for visionOS and iOS apps."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/ARCraft/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/ARCraft/actions/workflows/ci.yml/badge.svg" alt="CI-Status"></a>
<a href="https://github.com/muhittincamdali/ARCraft/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-version-light.svg" alt="Aktuelle Version: v1.1.0"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-platforms-light.svg" alt="Unterstützte Plattformen: iOS 18+ · macOS 15+ · visionOS 2+"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-language-light.svg" alt="Sprachversion: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-license-light.svg" alt="Lizenz: MIT"></picture></a>
</p>

<p align="center">
<a href="#schnellstart"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-start-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-start-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-start-de-light.svg" alt="Loslegen"></picture></a>
<a href="https://muhittincamdali.github.io/ARCraft/documentation/arcraft/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-docs-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-docs-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-docs-de-light.svg" alt="Dokumentation"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-examples-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-examples-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-examples-de-light.svg" alt="Beispiele"></picture></a>
</p>

> Dies ist eine Übersetzung der englischen README. Bei Abweichungen gilt die englische Fassung.

<!-- brand:end -->

ARCraft ist ein Swift-Paket für visionOS- und iOS-Apps, die Handtracking und World Anchors verwenden. Es kapselt RealityKit nicht: RealityKit rendert, simuliert und manipuliert Entities bereits. ARCraft deckt den Code ab, der zwischen den Rohdaten von ARKit und deiner Szene liegt und den jede Spatial-App sonst selbst schreibt: eine Pinch-Geste ohne Flackern erkennen, einen Fingerspitzen-Cursor ruhig halten, einen Tipp auf einen Tisch in eine aufrechte, eingerastete Pose verwandeln und sich über App-Starts hinweg merken, welcher Inhalt zu welchem World Anchor gehört. Der Kern besteht aus reinem Swift und `simd` ohne Abhängigkeiten, daher läuft und wird er auf dem Mac, im Simulator und in Previews getestet; schlanke Adapter verbinden ihn unter visionOS mit ARKit, unter iOS und macOS mit der Handpose von Vision sowie mit RealityKit-Entities.

## Highlights

- **Gesten ohne Flackern** — `HandGestureRecognizer` ergänzt Frame-Entprellung, einen größeren Loslass-Abstand für Pinch-Gesten und den Abbruch bei Tracking-Verlust auf einem skalenunabhängigen Klassifikator für Handformen (Pinch, Zeigen, Faust, offene Handfläche), der mit Metern (ARKit) und Pixeln (Vision) arbeitet.
- **Jitter-Filterung** — `OneEuroFilter` und `PoseFilter` glätten Fingerspitzen, Handgelenke und Anchors im Ruhezustand stark und in Bewegung leicht und ignorieren NaN-Werte sowie Zeitstempel in falscher Reihenfolge.
- **Platzierung auf Oberflächen** — `PlacementSolver` hält Inhalte auf Tischen aufrecht, an Wänden flach anliegend und zum Betrachter gedreht, optional mit Raster- und Drehwinkel-Einrasten; `SpatialBounds` passt Modelle unbekannter Größe in ein Volumen ein.
- **Inhalte, die im Raum bleiben** — `AnchoredItem`, `AnchorResolver` und `PlacementStore` halten fest, was relativ zu welchem `WorldAnchor` platziert wurde, und lesen die Datei als nicht vertrauenswürdige Eingabe wieder ein: mit Größenlimit vor dem Parsen, versioniert, und ein beschädigter Eintrag lässt die übrigen nicht verloren gehen.
- **Funktioniert ohne Headset** — `SyntheticHand` erzeugt Handposen für den Simulator, Previews und Tests; `HandPose` ist `Codable` für Aufnahme und Wiedergabe.
- **Getestet** — 103 Swift-Testing-Tests laufen unter macOS und in einem iPhone-Simulator (105 im visionOS-Simulator, einschließlich der ARKit-Adapter), und jedes README-Beispiel unten wird vom Test-Target kompiliert und ausgeführt.

### Was enthalten ist

| Bereich | Typen |
| --- | --- |
| Hände | `HandPose`, `HandJoint`, `Finger`, `HandShapeClassifier`, `HandShapeReading`, `HandGestureRecognizer`, `HandGestureEvent`, `SyntheticHand` |
| Filterung | `OneEuroFilter`, `OneEuroConfiguration`, `PoseFilter` |
| Platzierung | `PlacementSolver`, `PlacementOptions`, `Placement`, `SurfaceHit`, `SurfaceOrientation`, `SpatialBounds`, `Entity.setPose(_:relativeTo:)`, `Entity.scaleToFit(_:allowsUpscaling:)` |
| Persistenz | `AnchoredItem`, `WorldAnchorState`, `AnchorResolver`, `ItemStatus`, `PlacementArchive`, `PlacementStore` |
| Geometrie | `Pose` (Position und Einheitsquaternion, `Codable`, lehnt NaN ab) |
| Adapter | `HandPose(_: HandAnchor, timestamp:)`, `WorldAnchorState(_: WorldAnchor)`, `AnchorResolver.apply(_:)` unter visionOS; `HandPose(_: HumanHandPoseObservation, imageSize:timestamp:)` mit Vision |

## Schnellstart

**1. Paket hinzufügen**

Wähle in Xcode **File › Add Package Dependencies…** und gib die Repository-URL ein:

```text
https://github.com/muhittincamdali/ARCraft.git
```

Füge sie oben rechts im Fenster in das Suchfeld ein, stelle **Dependency Rule** auf **Branch** › `main` und klicke auf **Add Package**. Wähle im nächsten Fenster neben **ARCraft** das Target deiner App aus und klicke erneut auf **Add Package**.

**2. Modul importieren**

```swift
import ARCraft
```

Setze diese Zeile an den Anfang der Swift-Datei, in der du ARCraft verwendest.

**3. Verwenden**

Füge diese Funktion einer beliebigen Swift-Datei deiner App (oder einem Unit-Test) hinzu und rufe `print(pinchDemo())` auf. Sie schließt und öffnet eine synthetische Hand mit 90 Bildern pro Sekunde und läuft deshalb auf jedem Gerät und im Simulator:

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

Die Ausgabe lautet `["pinch began at frame 4", "pinch ended at frame 9"]`. Die Pinch-Geste beginnt im zweiten geschlossenen Frame und endet, nachdem die Hand drei Frames lang über den Loslass-Abstand hinaus geöffnet war; genau das verhindert das Flackern. Auf der Apple Vision Pro speist du denselben Recognizer mit `HandPose(update.anchor, timestamp: update.timestamp)`, wie unter [Verwendung](#verwendung) gezeigt.

## Installation

### Swift Package Manager

Wähle in Xcode **File › Add Package Dependencies…** und gib die Repository-URL ein:

```text
https://github.com/muhittincamdali/ARCraft.git
```

Füge in einem `Package.swift`-Manifest das Paket und das Produkt hinzu:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/ARCraft.git", from: "1.1.0")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "ARCraft", package: "ARCraft")
    ])
]
```

Die hier beschriebene API erscheint in 1.1.0, dem ersten Release mit Quellcode der Bibliothek. Das frühere Tag `v1.0.0` enthält keinen (siehe das [Änderungsprotokoll](CHANGELOG.md)).

## Verwendung

Jedes Beispiel unten stammt aus der [Beispiel-App](Examples/ARCraftLab), die CI für iOS, macOS und visionOS baut.

### Pinch-Gesten auf der Apple Vision Pro erkennen

Aus [`LiveSpaceModel.swift`](Examples/ARCraftLab/ARCraftLab/LiveSpaceModel.swift), das in einem `ImmersiveSpace` läuft, wobei `NSHandsTrackingUsageDescription` in der Info.plist steht:

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

`pinch` ist ein `HandGestureRecognizer(configuration: .init(shape: .pinch))`; geht die Hand für länger als die Toleranz verloren, wird die Geste abgebrochen statt beendet, sodass eine Hand, die das Sichtfeld verlässt, nie etwas platziert.

### Eine Fingerspitze glätten

```swift
func smoothFingertip(_ samples: [(time: TimeInterval, position: SIMD3<Float>)]) -> [SIMD3<Float>] {
    var filter = OneEuroFilter<SIMD3<Float>>(configuration: .handJoints)
    return samples.compactMap { filter.filter($0.position, at: $0.time) }
}
```

### Inhalt auf einem Tisch platzieren

```swift
func placeOnTable() throws -> Placement {
    let solver = PlacementSolver(options: .init(gridSize: 0.05, rotationStep: .pi / 4))
    let tap = SurfaceHit(position: SIMD3(0.42, 0.74, -0.81), normal: SIMD3(0, 1, 0))
    return try solver.place(on: tap, facing: SIMD3(0, 1.6, 0))
}
```

Der Inhalt steht aufrecht bei `(0.40, 0.74, -0.80)` und ist in 45°-Schritten zum Betrachter gedreht. Seine Vorderseite ist die +Z-Achse, wie in USD üblich. An einer Wand würde er flach an der Wand anliegen und nach außen zeigen.

### Ein Modell unbekannter Größe einpassen

```swift
func fitModel() -> Float {
    guard let bounds = SpatialBounds(min: SIMD3(-60, 0, -40), max: SIMD3(60, 90, 40)) else { return 1 }
    return bounds.scaleToFit(SIMD3(repeating: 0.3))
}
```

Gibt `0.0025` zurück: Ein Modell, das 120 Einheiten breit angelegt wurde, ist danach 30 cm breit. Bei einer RealityKit-Entity rufst du stattdessen `entity.scaleToFit(SIMD3(repeating: 0.3))` auf.

### Platzierten Inhalt speichern und wiederherstellen

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

Unter visionOS stammt der Anchor von `WorldTrackingProvider`. Der Live-Space hängt neuen Inhalt an einen getrackten Anchor im Umkreis von 50 cm oder legt einen neuen an:

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

## Demo

Screenshots der [Beispiel-App](Examples/ARCraftLab), aufgenommen im iOS-Simulator mit [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh). Jeder Screen führt ARCraft mit synthetischen oder aufgezeichneten Daten aus.

| Handgesten | Glättung | Platzierung | Persistenz |
| --- | --- | --- | --- |
| ![Handgesten, hell](docs/images/gestures-light.png) | ![Glättung, hell](docs/images/smoothing-light.png) | ![Platzierung, hell](docs/images/placement-light.png) | ![Persistenz, hell](docs/images/persistence-light.png) |
| ![Handgesten, dunkel](docs/images/gestures-dark.png) | ![Glättung, dunkel](docs/images/smoothing-dark.png) | ![Platzierung, dunkel](docs/images/placement-dark.png) | ![Persistenz, dunkel](docs/images/persistence-dark.png) |

## Dokumentation

- [API-Referenz](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/) (DocC, von `main` auf GitHub Pages veröffentlicht)
- Baue sie lokal in Xcode über **Product › Build Documentation** oder über die Kommandozeile:

```sh
xcodebuild docbuild -scheme ARCraft -destination 'generic/platform=visionOS Simulator'
```

## Anleitungen

- [Getting Started](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/gettingstarted)
  — das Paket hinzufügen und eine Pinch-Geste erst mit synthetischen Daten, dann mit ARKit-Daten erkennen
  ([Quellcode](Sources/ARCraft/ARCraft.docc/GettingStarted.md)).
- [Recognizing Hand Gestures](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/recognizinghandgestures)
  — wie Formen gemessen werden, Entprellung, Hysterese, Tracking-Verlust, zwei Hände und Vision unter iOS
  ([Quellcode](Sources/ARCraft/ARCraft.docc/RecognizingHandGestures.md)).
- [Smoothing Tracking Data](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/smoothingtrackingdata)
  — den One-Euro-Filter abstimmen und Posen glätten
  ([Quellcode](Sources/ARCraft/ARCraft.docc/SmoothingTrackingData.md)).
- [Placing Content on Surfaces](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/placingcontentonsurfaces)
  — Böden, Wände, Einrasten und das Einpassen von Modellen
  ([Quellcode](Sources/ARCraft/ARCraft.docc/PlacingContentOnSurfaces.md)).
- [Persisting Placed Content](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/persistingplacedcontent)
  — World Anchors, Wiederherstellen beim Start, Aufräumen und die Grenzen des Dateiformats
  ([Quellcode](Sources/ARCraft/ARCraft.docc/PersistingPlacedContent.md)).
- [Testing Without a Headset](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/testingwithoutaheadset)
  — synthetische und aufgezeichnete Hände sowie Anchors in Unit-Tests
  ([Quellcode](Sources/ARCraft/ARCraft.docc/TestingWithoutAHeadset.md)).

## Voraussetzungen

| Plattform | Mindestversion |
| --- | --- |
| iOS | 18 |
| macOS | 15 |
| visionOS | 2 |
| Toolchain | Swift 6.2 · Xcode 26+ |

Hand- und World-Tracking benötigen die Apple Vision Pro; die ARKit-Adapter werden nur für visionOS kompiliert. CI baut mit dem Standard-Xcode des `macos-26`-Runner-Images von GitHub. Das Paket wird mit Xcode 27 gegen die SDKs von iOS 27 und visionOS 27 entwickelt.

## Wann etwas anderes besser passt

- **Entities mit den Standardgesten verschieben, drehen und skalieren:** Dafür genügen `ManipulationComponent` (visionOS 26) und `GestureComponent` von RealityKit, ganz ohne zusätzlichen Code.
- **Eigene statische Handposen anhand von Ähnlichkeit abgleichen:** [HandVector](https://github.com/XanderXu/HandVector) vergleicht die Gelenkvektoren der ganzen Hand mit aufgezeichneten Vorlagen; ARCraft klassifiziert vier feste Formen mit expliziten Schwellenwerten.
- **Semantische Gesten als SwiftUI-Modifier (Klatschen, Schnipsen, Faustschlag):** [HandGesture](https://github.com/johnhaney/HandGesture).
- **3D-Bedienelemente (Schalter, Schieberegler, Buttons als Entities):** [RealityUI](https://github.com/maxxfrazer/RealityUI).

## Architektur

- `Sources/ARCraft/Math`, `Filtering`, `Hands`, `Placement` und `Persistence` sind Werttypen, die nur Foundation und `simd` verwenden. `PlacementStore` ist der einzige Referenztyp (ein Actor, der Dateizugriffe serialisiert).
- `Sources/ARCraft/Platform` enthält die Adapter: `ARKit+ARCraft.swift` (nur visionOS) und `Vision+ARCraft.swift`. `Placement/Entity+ARCraft.swift` fügt die RealityKit-Helfer hinzu.
- Jeder Typ, der Eingaben von außen annimmt, validiert sie an der Grenze: Matrizen und dekodierte Zahlen müssen endlich sein, Konfigurationswerte werden begrenzt, Sammlungen und Dateien haben Größenlimits, und Dateinamen können den Ordner der App nicht verlassen.
- Die Tests liegen in `Tests/ARCraftTests` (Swift Testing). Der Hand-Klassifikator wird sowohl mit von Hand eingegebenen Gelenk-Fixtures als auch mit synthetischen Händen getestet, damit beide nicht nur untereinander übereinstimmen.

Die Tests lokal ausführen:

```sh
swift test                                    # macOS
xcodebuild test -scheme ARCraft \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
xcodebuild test -scheme ARCraft \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

## Roadmap

- Das Release 2.0.0 taggen und das Paket zum Swift Package Index hinzufügen; `.spi.yml` liegt bereits im Repository.
- Zweihandgesten (Skalieren und Drehen zwischen beiden Pinch-Gesten) auf Basis von `HandGestureRecognizer`.
- Platzierung anhand der Ausdehnung von Plane Anchors, damit Inhalte innerhalb der Kanten eines erkannten Tisches bleiben.

## Mitwirken

Beiträge sind willkommen. Lies vor einem Pull Request den [Leitfaden für Beiträge](https://github.com/muhittincamdali/ARCraft/blob/main/CONTRIBUTING.md) und den [Verhaltenskodex](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md). Sicherheitsprobleme meldest du vertraulich, wie in der [Sicherheitsrichtlinie](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md) beschrieben.

## Lizenz

Veröffentlicht unter der MIT-Lizenz. Siehe [LICENSE](LICENSE).
