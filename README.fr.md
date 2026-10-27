<!-- i18n-source: README.md@c964923478924fb650768a0ae2e1614eafd6cf3d status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/banner-light.svg" alt="ARCraft: Hand gestures, jitter filters, surface placement and world anchor persistence for visionOS and iOS apps."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/ARCraft/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/ARCraft/actions/workflows/ci.yml/badge.svg" alt="État de la CI"></a>
<a href="https://github.com/muhittincamdali/ARCraft/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-version-light.svg" alt="Dernière version: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-platforms-light.svg" alt="Plateformes prises en charge: iOS 18+ · macOS 15+ · visionOS 2+"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-language-light.svg" alt="Version du langage: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-license-light.svg" alt="Licence: MIT"></picture></a>
</p>

<p align="center">
<a href="#démarrage-rapide"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-start-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-start-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-start-fr-light.svg" alt="Commencer"></picture></a>
<a href="https://muhittincamdali.github.io/ARCraft/documentation/arcraft/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-docs-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-docs-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-docs-fr-light.svg" alt="Documentation"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-examples-fr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-examples-fr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-examples-fr-light.svg" alt="Exemples"></picture></a>
</p>

> Ceci est une traduction du README anglais. En cas de différence, la version anglaise fait foi.

<!-- brand:end -->

ARCraft est un package Swift pour les apps visionOS et iOS qui utilisent le suivi des mains et les world anchors. Il n’enveloppe pas RealityKit : RealityKit affiche, simule et manipule déjà les entités. Il couvre le code qui se trouve entre les données brutes d’ARKit et votre scène, et que chaque app spatiale finit par écrire de son côté : reconnaître un pincement sans scintillement, garder un curseur au bout du doigt stable, transformer un toucher sur une table en une pose verticale alignée sur la grille, et retenir d’un lancement à l’autre quel contenu appartient à quel world anchor. Le cœur est du Swift pur et `simd`, sans aucune dépendance : il s’exécute et se teste donc sur le Mac, dans le simulateur et dans les aperçus ; de fins adaptateurs le relient à ARKit sur visionOS, à la pose de main de Vision sur iOS et macOS, et aux entités RealityKit.

## Points forts

- **Des gestes qui ne scintillent pas** — `HandGestureRecognizer` ajoute un anti-rebond par image, une distance de relâchement plus large pour les pincements et l’annulation en cas de perte de suivi, au-dessus d’un classificateur de formes de la main indépendant de l’échelle (pincement, pointage, poing, paume ouverte) qui fonctionne en mètres (ARKit) comme en pixels (Vision).
- **Filtrage du jitter** — `OneEuroFilter` et `PoseFilter` lissent fortement au repos et légèrement en mouvement les bouts des doigts, les poignets et les anchors, et ignorent les échantillons NaN et les horodatages dans le désordre.
- **Placement sur les surfaces** — `PlacementSolver` garde le contenu vertical sur les tables, à plat contre les murs et tourné vers l’observateur, avec un magnétisme facultatif sur la grille et sur des pas de rotation ; `SpatialBounds` fait entrer dans un volume des modèles de taille inconnue.
- **Un contenu qui reste dans la pièce** — `AnchoredItem`, `AnchorResolver` et `PlacementStore` enregistrent ce qui a été placé par rapport à quel `WorldAnchor`, et relisent le fichier comme une entrée non fiable : taille limitée avant l’analyse, versionné, et une entrée endommagée ne fait pas perdre les autres.
- **Fonctionne sans casque** — `SyntheticHand` construit des poses de main pour le simulateur, les aperçus et les tests ; `HandPose` est `Codable` pour l’enregistrement et la relecture.
- **Testé** — 100 tests Swift Testing s’exécutent sur macOS et sur un simulateur d’iPhone (102 sur le simulateur visionOS, adaptateurs ARKit compris), et chaque exemple du README ci-dessous est compilé et exécuté par la cible de tests.

### Ce que contient le package

| Domaine | Types |
| --- | --- |
| Mains | `HandPose`, `HandJoint`, `Finger`, `HandShapeClassifier`, `HandShapeReading`, `HandGestureRecognizer`, `HandGestureEvent`, `SyntheticHand` |
| Filtrage | `OneEuroFilter`, `OneEuroConfiguration`, `PoseFilter` |
| Placement | `PlacementSolver`, `PlacementOptions`, `Placement`, `SurfaceHit`, `SurfaceOrientation`, `SpatialBounds`, `Entity.setPose(_:relativeTo:)`, `Entity.scaleToFit(_:allowsUpscaling:)` |
| Persistance | `AnchoredItem`, `WorldAnchorState`, `AnchorResolver`, `ItemStatus`, `PlacementArchive`, `PlacementStore` |
| Géométrie | `Pose` (position et quaternion unitaire, `Codable`, rejette NaN) |
| Adaptateurs | `HandPose(_: HandAnchor, timestamp:)`, `WorldAnchorState(_: WorldAnchor)`, `AnchorResolver.apply(_:)` sur visionOS ; `HandPose(_: HumanHandPoseObservation, imageSize:timestamp:)` avec Vision |

## Démarrage rapide

**1. Ajouter le paquet**

Dans Xcode, choisissez **File › Add Package Dependencies…** et saisissez l’URL du dépôt :

```text
https://github.com/muhittincamdali/ARCraft.git
```

Collez-la dans le champ de recherche en haut à droite de la fenêtre, réglez **Dependency Rule** sur **Branch** › `main`, puis cliquez sur **Add Package**. Dans la fenêtre suivante, choisissez la cible de votre app à côté de **ARCraft** et cliquez de nouveau sur **Add Package**.

**2. Importer le module**

```swift
import ARCraft
```

Placez cette ligne en haut du fichier Swift où vous utilisez ARCraft.

**3. L’utiliser**

Ajoutez cette fonction à n’importe quel fichier Swift de votre app (ou à un test unitaire) et appelez `print(pinchDemo())`. Elle ferme puis ouvre une main synthétique à 90 images par seconde, donc elle fonctionne sur n’importe quel appareil et dans le simulateur :

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

Elle affiche `["pinch began at frame 4", "pinch ended at frame 9"]`. Le pincement commence à la deuxième image fermée et se termine après trois images ouvertes au-delà de la distance de relâchement, ce qui l’empêche de scintiller. Sur l’Apple Vision Pro, vous alimentez le même recognizer avec `HandPose(update.anchor, timestamp: update.timestamp)`, comme le montre la section [Utilisation](#utilisation).

## Installation

### Swift Package Manager

Dans Xcode, choisissez **File › Add Package Dependencies…** et saisissez l’URL du dépôt :

```text
https://github.com/muhittincamdali/ARCraft.git
```

Dans un manifeste `Package.swift`, ajoutez le package et le produit :

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/ARCraft.git", branch: "main")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "ARCraft", package: "ARCraft")
    ])
]
```

L’API décrite ici se trouve sur `main`. Le seul tag à ce jour, `v1.0.0`, a été créé avant l’ajout des sources de la bibliothèque ; dépendez donc de `main` jusqu’à ce que la prochaine version soit taguée (voir le [journal des modifications](CHANGELOG.md)).

## Utilisation

Chaque exemple ci-dessous est copié de l’[app d’exemple](Examples/ARCraftLab), que CI compile pour iOS, macOS et visionOS.

### Reconnaître des pincements sur l’Apple Vision Pro

Extrait de [`LiveSpaceModel.swift`](Examples/ARCraftLab/ARCraftLab/LiveSpaceModel.swift), qui s’exécute dans un `ImmersiveSpace` avec `NSHandsTrackingUsageDescription` dans l’Info.plist :

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

`pinch` est un `HandGestureRecognizer(configuration: .init(shape: .pinch))` ; lorsque la main est perdue plus longtemps que la tolérance, le geste est annulé au lieu d’être terminé, de sorte qu’une main qui quitte le champ de vision ne place jamais rien.

### Lisser le bout d’un doigt

```swift
func smoothFingertip(_ samples: [(time: TimeInterval, position: SIMD3<Float>)]) -> [SIMD3<Float>] {
    var filter = OneEuroFilter<SIMD3<Float>>(configuration: .handJoints)
    return samples.compactMap { filter.filter($0.position, at: $0.time) }
}
```

### Placer du contenu sur une table

```swift
func placeOnTable() throws -> Placement {
    let solver = PlacementSolver(options: .init(gridSize: 0.05, rotationStep: .pi / 4))
    let tap = SurfaceHit(position: SIMD3(0.42, 0.74, -0.81), normal: SIMD3(0, 1, 0))
    return try solver.place(on: tap, facing: SIMD3(0, 1.6, 0))
}
```

Le contenu se tient à la verticale en `(0.40, 0.74, -0.80)`, tourné vers l’observateur par pas de 45°. Sa face avant est son axe +Z, la convention d’USD. Sur un mur, il serait à plat contre le mur, face vers l’extérieur.

### Ajuster un modèle de taille inconnue

```swift
func fitModel() -> Float {
    guard let bounds = SpatialBounds(min: SIMD3(-60, 0, -40), max: SIMD3(60, 90, 40)) else { return 1 }
    return bounds.scaleToFit(SIMD3(repeating: 0.3))
}
```

Renvoie `0.0025` : un modèle conçu avec 120 unités de large fait désormais 30 cm de large. Sur une entité RealityKit, appelez plutôt `entity.scaleToFit(SIMD3(repeating: 0.3))`.

### Enregistrer le contenu placé et le restaurer

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

Sur visionOS, l’anchor provient de `WorldTrackingProvider`. L’espace en direct rattache le nouveau contenu à un anchor suivi situé à moins de 50 cm, ou en crée un :

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

## Démo

Écrans de l’[app d’exemple](Examples/ARCraftLab), capturés depuis le simulateur iOS par [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh). Chacun exécute ARCraft sur des données synthétiques ou enregistrées.

| Gestes de la main | Lissage | Placement | Persistance |
| --- | --- | --- | --- |
| ![Gestes de la main, clair](docs/images/gestures-light.png) | ![Lissage, clair](docs/images/smoothing-light.png) | ![Placement, clair](docs/images/placement-light.png) | ![Persistance, clair](docs/images/persistence-light.png) |
| ![Gestes de la main, sombre](docs/images/gestures-dark.png) | ![Lissage, sombre](docs/images/smoothing-dark.png) | ![Placement, sombre](docs/images/placement-dark.png) | ![Persistance, sombre](docs/images/persistence-dark.png) |

## Documentation

- [Référence de l’API](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/) (DocC, publiée sur GitHub Pages depuis `main`)
- Compilez-la en local dans Xcode avec **Product › Build Documentation**, ou en ligne de commande :

```sh
xcodebuild docbuild -scheme ARCraft -destination 'generic/platform=visionOS Simulator'
```

## Guides

- [Getting Started](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/gettingstarted)
  — ajouter le package, reconnaître un pincement sur des données synthétiques, puis sur des données ARKit
  ([code source](Sources/ARCraft/ARCraft.docc/GettingStarted.md)).
- [Recognizing Hand Gestures](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/recognizinghandgestures)
  — comment les formes sont mesurées, anti-rebond, hystérésis, perte de suivi, deux mains et Vision sur iOS
  ([code source](Sources/ARCraft/ARCraft.docc/RecognizingHandGestures.md)).
- [Smoothing Tracking Data](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/smoothingtrackingdata)
  — régler le filtre One Euro et lisser les poses
  ([code source](Sources/ARCraft/ARCraft.docc/SmoothingTrackingData.md)).
- [Placing Content on Surfaces](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/placingcontentonsurfaces)
  — sols, murs, magnétisme et ajustement des modèles
  ([code source](Sources/ARCraft/ARCraft.docc/PlacingContentOnSurfaces.md)).
- [Persisting Placed Content](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/persistingplacedcontent)
  — world anchors, restauration au lancement, nettoyage et limites du format de fichier
  ([code source](Sources/ARCraft/ARCraft.docc/PersistingPlacedContent.md)).
- [Testing Without a Headset](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/testingwithoutaheadset)
  — mains synthétiques et enregistrées, et anchors dans les tests unitaires
  ([code source](Sources/ARCraft/ARCraft.docc/TestingWithoutAHeadset.md)).

## Prérequis

| Plateforme | Version minimale |
| --- | --- |
| iOS | 18 |
| macOS | 15 |
| visionOS | 2 |
| Chaîne d’outils | Swift 6.2 · Xcode 26+ |

Le suivi des mains et du monde nécessite l’Apple Vision Pro ; les adaptateurs ARKit ne se compilent que pour visionOS. CI compile avec le Xcode par défaut de l’image de runner `macos-26` de GitHub. Le package est développé avec Xcode 27, avec les SDK d’iOS 27 et de visionOS 27.

## Quand utiliser autre chose

- **Déplacer, faire pivoter et redimensionner des entités avec les gestes standard :** le `ManipulationComponent` de RealityKit (visionOS 26) et `GestureComponent` le font sans code supplémentaire.
- **Comparer par similarité des poses de main statiques personnalisées :** [HandVector](https://github.com/XanderXu/HandVector) compare les vecteurs d’articulations de toute la main à des modèles enregistrés ; ARCraft classe quatre formes fixes avec des seuils explicites.
- **Gestes sémantiques sous forme de modificateurs SwiftUI (applaudir, claquer des doigts, coup de poing) :** [HandGesture](https://github.com/johnhaney/HandGesture).
- **Contrôles d’interface 3D (interrupteurs, curseurs, boutons sous forme d’entités) :** [RealityUI](https://github.com/maxxfrazer/RealityUI).

## Architecture

- `Sources/ARCraft/Math`, `Filtering`, `Hands`, `Placement` et `Persistence` sont des types valeur qui n’utilisent que Foundation et `simd`. `PlacementStore` est le seul type référence (un actor qui sérialise l’accès aux fichiers).
- `Sources/ARCraft/Platform` contient les adaptateurs : `ARKit+ARCraft.swift` (visionOS uniquement) et `Vision+ARCraft.swift`. `Placement/Entity+ARCraft.swift` ajoute les utilitaires RealityKit.
- Tout type qui accepte des données extérieures les valide à la frontière : les matrices et les nombres décodés doivent être finis, les valeurs de configuration sont bornées, les collections et les fichiers ont des limites de taille, et les noms de fichier ne peuvent pas sortir du dossier de l’app.
- Les tests se trouvent dans `Tests/ARCraftTests` (Swift Testing). Le classificateur de mains est testé avec des articulations saisies à la main ainsi qu’avec des mains synthétiques, afin que les deux ne soient pas seulement d’accord entre eux.

Lancez les tests en local :

```sh
swift test                                    # macOS
xcodebuild test -scheme ARCraft \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
xcodebuild test -scheme ARCraft \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

## Feuille de route

- Taguer la version 2.0.0 et ajouter le package au Swift Package Index ; `.spi.yml` est déjà dans le dépôt.
- Gestes à deux mains (redimensionner et pivoter entre les deux pincements) au-dessus de `HandGestureRecognizer`.
- Placement selon l’étendue des plane anchors, pour que le contenu reste à l’intérieur des bords d’une table détectée.

## Contribuer

Les contributions sont les bienvenues. Lisez le [guide de contribution](https://github.com/muhittincamdali/ARCraft/blob/main/CONTRIBUTING.md) et le [code de conduite](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) avant d’ouvrir une pull request. Signalez les problèmes de sécurité en privé, comme indiqué dans la [politique de sécurité](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md).

## Licence

Publié sous licence MIT. Voir [LICENSE](LICENSE).
