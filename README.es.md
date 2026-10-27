<!-- i18n-source: README.md@f321bb38071894405d44819e7cf9ff20c750b9cd status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/banner-light.svg" alt="ARCraft: Hand gestures, jitter filters, surface placement and world anchor persistence for visionOS and iOS apps."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/ARCraft/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/ARCraft/actions/workflows/ci.yml/badge.svg" alt="Estado de CI"></a>
<a href="https://github.com/muhittincamdali/ARCraft/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-version-light.svg" alt="Última versión: v1.1.0"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-platforms-light.svg" alt="Plataformas compatibles: iOS 18+ · macOS 15+ · visionOS 2+"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-language-light.svg" alt="Versión del lenguaje: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-license-light.svg" alt="Licencia: MIT"></picture></a>
</p>

<p align="center">
<a href="#inicio-rápido"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-start-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-start-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-start-es-light.svg" alt="Empezar"></picture></a>
<a href="https://muhittincamdali.github.io/ARCraft/documentation/arcraft/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-docs-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-docs-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-docs-es-light.svg" alt="Documentación"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-examples-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-examples-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-examples-es-light.svg" alt="Ejemplos"></picture></a>
</p>

> Esta es una traducción del README en inglés. Si hay diferencias, la versión en inglés es la vigente.

<!-- brand:end -->

ARCraft es un paquete de Swift para apps de visionOS y iOS que usan seguimiento de manos y world anchors. No envuelve RealityKit: RealityKit ya renderiza, simula y manipula entidades. Cubre el código que queda entre los datos en bruto de ARKit y tu escena, y que cada app espacial acaba escribiendo por su cuenta: reconocer un pellizco sin parpadeos, mantener estable el cursor de la punta del dedo, convertir un toque sobre una mesa en una pose vertical y ajustada a la cuadrícula, y recordar entre un arranque y otro qué contenido pertenece a qué world anchor. El núcleo es Swift puro y `simd`, sin dependencias, así que se ejecuta y se prueba en el Mac, en el simulador y en las previsualizaciones; adaptadores finos lo conectan con ARKit en visionOS, con la pose de manos de Vision en iOS y macOS, y con las entidades de RealityKit.

## Lo más destacado

- **Gestos que no parpadean** — `HandGestureRecognizer` añade antirrebote por fotogramas, una distancia de liberación mayor para los pellizcos y cancelación al perder el seguimiento, todo sobre un clasificador de formas de la mano independiente de la escala (pellizco, señalar, puño, palma abierta) que funciona en metros (ARKit) y en píxeles (Vision).
- **Filtrado de vibración** — `OneEuroFilter` y `PoseFilter` suavizan puntas de los dedos, muñecas y anchors con fuerza en reposo y ligeramente en movimiento, e ignoran las muestras NaN y las marcas de tiempo desordenadas.
- **Colocación en superficies** — `PlacementSolver` mantiene el contenido vertical en las mesas, plano contra las paredes y orientado hacia quien lo mira, con ajuste opcional a una cuadrícula y a pasos de rotación; `SpatialBounds` encaja en un volumen modelos de tamaño desconocido.
- **Contenido que se queda en la habitación** — `AnchoredItem`, `AnchorResolver` y `PlacementStore` registran qué se colocó respecto a qué `WorldAnchor` y leen el archivo de vuelta como entrada no confiable: con límite de tamaño antes de analizarlo, con versión, y un elemento dañado no hace perder el resto.
- **Funciona sin casco** — `SyntheticHand` genera poses de manos para el simulador, las previsualizaciones y las pruebas; `HandPose` es `Codable` para grabar y reproducir.
- **Probado** — 103 pruebas de Swift Testing se ejecutan en macOS y en un simulador de iPhone (105 en el simulador de visionOS, con los adaptadores de ARKit), y el target de pruebas compila y ejecuta cada ejemplo del README que aparece más abajo.

### Qué incluye

| Área | Tipos |
| --- | --- |
| Manos | `HandPose`, `HandJoint`, `Finger`, `HandShapeClassifier`, `HandShapeReading`, `HandGestureRecognizer`, `HandGestureEvent`, `SyntheticHand` |
| Filtrado | `OneEuroFilter`, `OneEuroConfiguration`, `PoseFilter` |
| Colocación | `PlacementSolver`, `PlacementOptions`, `Placement`, `SurfaceHit`, `SurfaceOrientation`, `SpatialBounds`, `Entity.setPose(_:relativeTo:)`, `Entity.scaleToFit(_:allowsUpscaling:)` |
| Persistencia | `AnchoredItem`, `WorldAnchorState`, `AnchorResolver`, `ItemStatus`, `PlacementArchive`, `PlacementStore` |
| Geometría | `Pose` (posición y cuaternión unitario, `Codable`, rechaza NaN) |
| Adaptadores | `HandPose(_: HandAnchor, timestamp:)`, `WorldAnchorState(_: WorldAnchor)`, `AnchorResolver.apply(_:)` en visionOS; `HandPose(_: HumanHandPoseObservation, imageSize:timestamp:)` con Vision |

## Inicio rápido

**1. Añade el paquete**

En Xcode, elige **File › Add Package Dependencies…** e introduce la URL del repositorio:

```text
https://github.com/muhittincamdali/ARCraft.git
```

Pégala en el campo de búsqueda de la parte superior derecha de la ventana, cambia **Dependency Rule** a **Branch** › `main` y haz clic en **Add Package**. En la ventana siguiente, elige el target de tu app junto a **ARCraft** y haz clic en **Add Package** otra vez.

**2. Importa el módulo**

```swift
import ARCraft
```

Pon esta línea al principio del archivo de Swift donde uses ARCraft.

**3. Úsalo**

Añade esta función a cualquier archivo de Swift de tu app (o a una prueba unitaria) y llama a `print(pinchDemo())`. Cierra y abre una mano sintética a 90 fotogramas por segundo, así que funciona en cualquier dispositivo y en el simulador:

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

Imprime `["pinch began at frame 4", "pinch ended at frame 9"]`. El pellizco empieza en el segundo fotograma cerrado y termina cuando la mano lleva tres fotogramas abierta más allá de la distancia de liberación, y eso es lo que evita que parpadee. En Apple Vision Pro alimentas el mismo recognizer con `HandPose(update.anchor, timestamp: update.timestamp)`, como se muestra en [Uso](#uso).

## Instalación

### Swift Package Manager

En Xcode, elige **File › Add Package Dependencies…** e introduce la URL del repositorio:

```text
https://github.com/muhittincamdali/ARCraft.git
```

En un manifiesto `Package.swift`, añade el paquete y el producto:

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

La API descrita aquí se publica en 1.1.0, la primera versión con código fuente de la biblioteca. La etiqueta anterior, `v1.0.0`, no contiene ninguno (consulta el [registro de cambios](CHANGELOG.md)).

## Uso

Cada ejemplo de abajo está copiado de la [app de ejemplo](Examples/ARCraftLab), que CI compila para iOS, macOS y visionOS.

### Reconocer pellizcos en Apple Vision Pro

Fragmento de [`LiveSpaceModel.swift`](Examples/ARCraftLab/ARCraftLab/LiveSpaceModel.swift), que se ejecuta dentro de un `ImmersiveSpace` con `NSHandsTrackingUsageDescription` en el Info.plist:

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

`pinch` es un `HandGestureRecognizer(configuration: .init(shape: .pinch))`; cuando la mano se pierde durante más tiempo que la tolerancia, el gesto se cancela en lugar de terminar, así que una mano que sale del campo de visión nunca coloca nada.

### Suavizar la punta de un dedo

```swift
func smoothFingertip(_ samples: [(time: TimeInterval, position: SIMD3<Float>)]) -> [SIMD3<Float>] {
    var filter = OneEuroFilter<SIMD3<Float>>(configuration: .handJoints)
    return samples.compactMap { filter.filter($0.position, at: $0.time) }
}
```

### Colocar contenido sobre una mesa

```swift
func placeOnTable() throws -> Placement {
    let solver = PlacementSolver(options: .init(gridSize: 0.05, rotationStep: .pi / 4))
    let tap = SurfaceHit(position: SIMD3(0.42, 0.74, -0.81), normal: SIMD3(0, 1, 0))
    return try solver.place(on: tap, facing: SIMD3(0, 1.6, 0))
}
```

El contenido queda vertical en `(0.40, 0.74, -0.80)`, orientado hacia quien mira en pasos de 45°. Su frente es su eje +Z, la convención de USD. En una pared quedaría plano contra ella, mirando hacia fuera.

### Ajustar un modelo de tamaño desconocido

```swift
func fitModel() -> Float {
    guard let bounds = SpatialBounds(min: SIMD3(-60, 0, -40), max: SIMD3(60, 90, 40)) else { return 1 }
    return bounds.scaleToFit(SIMD3(repeating: 0.3))
}
```

Devuelve `0.0025`: un modelo creado con 120 unidades de ancho pasa a medir 30 cm de ancho. En una entidad de RealityKit, llama en su lugar a `entity.scaleToFit(SIMD3(repeating: 0.3))`.

### Guardar el contenido colocado y restaurarlo

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

En visionOS el anchor viene de `WorldTrackingProvider`. El espacio en vivo asocia el contenido nuevo a un anchor rastreado que esté a menos de 50 cm, o crea uno:

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

Capturas de la [app de ejemplo](Examples/ARCraftLab), tomadas en el simulador de iOS con [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh). Cada una ejecuta ARCraft con datos sintéticos o grabados.

| Gestos de manos | Suavizado | Colocación | Persistencia |
| --- | --- | --- | --- |
| ![Gestos de manos, claro](docs/images/gestures-light.png) | ![Suavizado, claro](docs/images/smoothing-light.png) | ![Colocación, claro](docs/images/placement-light.png) | ![Persistencia, claro](docs/images/persistence-light.png) |
| ![Gestos de manos, oscuro](docs/images/gestures-dark.png) | ![Suavizado, oscuro](docs/images/smoothing-dark.png) | ![Colocación, oscuro](docs/images/placement-dark.png) | ![Persistencia, oscuro](docs/images/persistence-dark.png) |

## Documentación

- [Referencia de la API](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/) (DocC, publicada en GitHub Pages desde `main`)
- Compílala en local en Xcode con **Product › Build Documentation**, o desde la línea de comandos:

```sh
xcodebuild docbuild -scheme ARCraft -destination 'generic/platform=visionOS Simulator'
```

## Guías

- [Getting Started](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/gettingstarted)
  — añade el paquete y reconoce un pellizco con datos sintéticos y después con datos de ARKit
  ([código fuente](Sources/ARCraft/ARCraft.docc/GettingStarted.md)).
- [Recognizing Hand Gestures](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/recognizinghandgestures)
  — cómo se miden las formas, antirrebote, histéresis, pérdida de seguimiento, dos manos y Vision en iOS
  ([código fuente](Sources/ARCraft/ARCraft.docc/RecognizingHandGestures.md)).
- [Smoothing Tracking Data](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/smoothingtrackingdata)
  — ajustar el filtro One Euro y suavizar poses
  ([código fuente](Sources/ARCraft/ARCraft.docc/SmoothingTrackingData.md)).
- [Placing Content on Surfaces](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/placingcontentonsurfaces)
  — suelos, paredes, ajuste a la cuadrícula y encaje de modelos
  ([código fuente](Sources/ARCraft/ARCraft.docc/PlacingContentOnSurfaces.md)).
- [Persisting Placed Content](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/persistingplacedcontent)
  — world anchors, restauración al arrancar, limpieza y los límites del formato de archivo
  ([código fuente](Sources/ARCraft/ARCraft.docc/PersistingPlacedContent.md)).
- [Testing Without a Headset](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/testingwithoutaheadset)
  — manos sintéticas y grabadas, y anchors en pruebas unitarias
  ([código fuente](Sources/ARCraft/ARCraft.docc/TestingWithoutAHeadset.md)).

## Requisitos

| Plataforma | Versión mínima |
| --- | --- |
| iOS | 18 |
| macOS | 15 |
| visionOS | 2 |
| Herramientas | Swift 6.2 · Xcode 26+ |

El seguimiento de manos y del mundo requiere Apple Vision Pro; los adaptadores de ARKit solo compilan para visionOS. CI compila con el Xcode predeterminado de la imagen de runner `macos-26` de GitHub. El paquete se desarrolla con Xcode 27 y los SDK de iOS 27 y visionOS 27.

## Cuándo usar otra cosa

- **Mover, rotar y escalar entidades con los gestos estándar:** el `ManipulationComponent` de RealityKit (visionOS 26) y `GestureComponent` lo hacen sin código adicional.
- **Comparar poses estáticas de la mano personalizadas por similitud:** [HandVector](https://github.com/XanderXu/HandVector) compara vectores de las articulaciones de toda la mano con plantillas grabadas; ARCraft clasifica cuatro formas fijas con umbrales explícitos.
- **Gestos semánticos como modificadores de SwiftUI (aplaudir, chasquear, puñetazo):** [HandGesture](https://github.com/johnhaney/HandGesture).
- **Controles de interfaz 3D (interruptores, controles deslizantes, botones como entidades):** [RealityUI](https://github.com/maxxfrazer/RealityUI).

## Arquitectura

- `Sources/ARCraft/Math`, `Filtering`, `Hands`, `Placement` y `Persistence` son tipos de valor que solo usan Foundation y `simd`. `PlacementStore` es el único tipo de referencia (un actor que serializa el acceso a los archivos).
- `Sources/ARCraft/Platform` contiene los adaptadores: `ARKit+ARCraft.swift` (solo visionOS) y `Vision+ARCraft.swift`. `Placement/Entity+ARCraft.swift` añade las utilidades de RealityKit.
- Todo tipo que acepta datos de fuera los valida en el límite: las matrices y los números decodificados deben ser finitos, los valores de configuración se acotan, las colecciones y los archivos tienen límites de tamaño y los nombres de archivo no pueden salir de la carpeta de la app.
- Las pruebas están en `Tests/ARCraftTests` (Swift Testing). El clasificador de manos se prueba con articulaciones escritas a mano y también con manos sintéticas, de modo que ambas no solo coinciden entre sí.

Ejecuta las pruebas en local:

```sh
swift test                                    # macOS
xcodebuild test -scheme ARCraft \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
xcodebuild test -scheme ARCraft \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

## Hoja de ruta

- Etiquetar la versión 2.0.0 y añadir el paquete al Swift Package Index; `.spi.yml` ya está en el repositorio.
- Gestos con dos manos (escalar y rotar entre ambos pellizcos) sobre `HandGestureRecognizer`.
- Colocación según la extensión de los plane anchors, para que el contenido se mantenga dentro de los bordes de una mesa detectada.

## Contribuir

Las contribuciones son bienvenidas. Lee la [guía de contribución](https://github.com/muhittincamdali/ARCraft/blob/main/CONTRIBUTING.md) y el [código de conducta](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) antes de abrir una pull request. Informa de los problemas de seguridad de forma privada, como se describe en la [política de seguridad](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md).

## Licencia

Publicado bajo la licencia MIT. Consulta [LICENSE](LICENSE).
