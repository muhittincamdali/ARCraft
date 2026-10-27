<!-- i18n-source: README.md@f321bb38071894405d44819e7cf9ff20c750b9cd status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/banner-light.svg" alt="ARCraft: Hand gestures, jitter filters, surface placement and world anchor persistence for visionOS and iOS apps."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/ARCraft/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/ARCraft/actions/workflows/ci.yml/badge.svg" alt="CI durumu"></a>
<a href="https://github.com/muhittincamdali/ARCraft/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-version-light.svg" alt="Son sürüm: v1.1.0"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-platforms-light.svg" alt="Desteklenen platformlar: iOS 18+ · macOS 15+ · visionOS 2+"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-language-light.svg" alt="Dil sürümü: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-license-light.svg" alt="Lisans: MIT"></picture></a>
</p>

<p align="center">
<a href="#hızlı-başlangıç"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-start-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-start-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-start-tr-light.svg" alt="Başlayın"></picture></a>
<a href="https://muhittincamdali.github.io/ARCraft/documentation/arcraft/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-docs-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-docs-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-docs-tr-light.svg" alt="Dokümantasyon"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-examples-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-examples-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-examples-tr-light.svg" alt="Örnekler"></picture></a>
</p>

> Bu belge İngilizce README'nin çevirisidir. İkisi arasında fark varsa güncel olan İngilizce sürümdür.

<!-- brand:end -->

ARCraft, el takibi ve world anchor kullanan visionOS ve iOS uygulamaları için bir Swift paketidir. RealityKit'i sarmalamaz: RealityKit entity'leri zaten çizer, simüle eder ve yönetir. ARCraft, ARKit'in ham verisi ile sahneniz arasında kalan ve her mekânsal uygulamanın normalde kendi başına yazdığı kodu kapsar: pinch hareketini titremeden tanımak, parmak ucu imlecini sabit tutmak, bir masaya yapılan dokunuşu dik ve ızgaraya oturmuş bir poza çevirmek ve hangi içeriğin hangi world anchor'a ait olduğunu uygulama yeniden açıldığında da hatırlamak. Çekirdek, bağımlılığı olmayan düz Swift ve `simd` ile yazılmıştır; bu yüzden Mac'te, simülatörde ve önizlemelerde çalışır ve test edilir. İnce adaptörler çekirdeği visionOS'ta ARKit'e, iOS ve macOS'ta Vision'ın el pozuna ve RealityKit entity'lerine bağlar.

## Öne çıkanlar

- **Titremeyen jestler** — `HandGestureRecognizer`, ölçekten bağımsız bir el şekli sınıflandırıcısının (pinch, işaret, yumruk, açık avuç; metre (ARKit) ve piksel (Vision) ile çalışır) üzerine kare debounce'u, pinch için daha geniş bir bırakma mesafesi ve takip kaybında iptal ekler.
- **Titreşim filtreleme** — `OneEuroFilter` ve `PoseFilter`, parmak uçlarını, bilekleri ve anchor'ları durağanken güçlü, hareket halindeyken hafif yumuşatır; NaN örnekleri ve sırası bozuk zaman damgalarını yok sayar.
- **Yüzey yerleştirme** — `PlacementSolver`, içeriği masalarda dik, duvarlarda yüzeye yatık ve izleyiciye dönük tutar; isteğe bağlı ızgara ve dönüş adımı ile oturtma da sunar. `SpatialBounds`, boyutu bilinmeyen modelleri bir hacme sığdırır.
- **Odada kalan içerik** — `AnchoredItem`, `AnchorResolver` ve `PlacementStore`, neyin hangi `WorldAnchor`'a göre yerleştirildiğini kaydeder ve dosyayı güvenilmeyen girdi olarak geri okur: ayrıştırmadan önce boyut sınırı uygular, sürümlüdür ve tek bir bozuk kayıt diğerlerinin kaybolmasına yol açmaz.
- **Headset olmadan çalışır** — `SyntheticHand`, simülatör, önizlemeler ve testler için el pozları üretir; `HandPose`, kayıt ve yeniden oynatma için `Codable`'dır.
- **Test edilmiş** — 103 Swift Testing testi macOS'ta ve bir iPhone simülatöründe çalışır (visionOS simülatöründe ARKit adaptörleri dahil 105), ayrıca aşağıdaki her README örneği test hedefi tarafından derlenir ve çalıştırılır.

### Neler dahil

| Alan | Türler |
| --- | --- |
| El | `HandPose`, `HandJoint`, `Finger`, `HandShapeClassifier`, `HandShapeReading`, `HandGestureRecognizer`, `HandGestureEvent`, `SyntheticHand` |
| Filtreleme | `OneEuroFilter`, `OneEuroConfiguration`, `PoseFilter` |
| Yerleştirme | `PlacementSolver`, `PlacementOptions`, `Placement`, `SurfaceHit`, `SurfaceOrientation`, `SpatialBounds`, `Entity.setPose(_:relativeTo:)`, `Entity.scaleToFit(_:allowsUpscaling:)` |
| Kalıcılık | `AnchoredItem`, `WorldAnchorState`, `AnchorResolver`, `ItemStatus`, `PlacementArchive`, `PlacementStore` |
| Geometri | `Pose` (konum ve birim kuaterniyon, `Codable`, NaN değerleri reddeder) |
| Adaptörler | `HandPose(_: HandAnchor, timestamp:)`, `WorldAnchorState(_: WorldAnchor)`, `AnchorResolver.apply(_:)` visionOS'ta; `HandPose(_: HumanHandPoseObservation, imageSize:timestamp:)` Vision ile |

## Hızlı başlangıç

**1. Paketi ekleyin**

Xcode'da **File › Add Package Dependencies…** menüsünü seçin ve depo adresini girin:

```text
https://github.com/muhittincamdali/ARCraft.git
```

Pencerenin sağ üstündeki arama alanına yapıştırın, **Dependency Rule** seçeneğini **Branch** › `main` olarak ayarlayın ve **Add Package**'a tıklayın. Açılan pencerede **ARCraft**'ın yanından uygulama hedefinizi seçin ve yeniden **Add Package**'a tıklayın.

**2. Modülü içe aktarın**

```swift
import ARCraft
```

Bu satırı, ARCraft'ı kullandığınız Swift dosyasının en üstüne koyun.

**3. Kullanın**

Bu fonksiyonu uygulamanızdaki herhangi bir Swift dosyasına (ya da bir birim testine) ekleyin ve `print(pinchDemo())` çağrısını yapın. Sentetik bir eli saniyede 90 karede kapatıp açar; bu yüzden her cihazda ve simülatörde çalışır:

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

Çıktı `["pinch began at frame 4", "pinch ended at frame 9"]` olur. Pinch, kapalı olan ikinci karede başlar ve üç kare boyunca bırakma mesafesinin ötesinde açık kaldıktan sonra biter; titremeyi önleyen de budur. Apple Vision Pro'da aynı recognizer'ı `HandPose(update.anchor, timestamp: update.timestamp)` ile beslersiniz; bunu [Kullanım](#kullanım) bölümünde görebilirsiniz.

## Kurulum

### Swift Package Manager

Xcode'da **File › Add Package Dependencies…** menüsünü seçin ve depo adresini girin:

```text
https://github.com/muhittincamdali/ARCraft.git
```

Paketi ve ürünü `Package.swift` dosyanıza ekleyin:

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

Burada anlatılan API, kütüphane kaynaklarını içeren ilk sürüm olan 1.1.0 ile yayımlanır. Önceki `v1.0.0` etiketi kaynak içermez ([değişiklik günlüğüne](CHANGELOG.md) bakın).

## Kullanım

Aşağıdaki her örnek, CI'ın iOS, macOS ve visionOS için derlediği [örnek uygulamadan](Examples/ARCraftLab) alınmıştır.

### Apple Vision Pro'da pinch hareketini tanıma

[`LiveSpaceModel.swift`](Examples/ARCraftLab/ARCraftLab/LiveSpaceModel.swift) dosyasından; bu kod, Info.plist'inde `NSHandsTrackingUsageDescription` bulunan bir `ImmersiveSpace` içinde çalışır:

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

`pinch`, bir `HandGestureRecognizer(configuration: .init(shape: .pinch))` örneğidir; el tolerans süresinden uzun süre kaybolursa jest sonlandırılmak yerine iptal edilir. Böylece görüş alanından çıkan bir el hiçbir şey yerleştirmez.

### Parmak ucunu yumuşatma

```swift
func smoothFingertip(_ samples: [(time: TimeInterval, position: SIMD3<Float>)]) -> [SIMD3<Float>] {
    var filter = OneEuroFilter<SIMD3<Float>>(configuration: .handJoints)
    return samples.compactMap { filter.filter($0.position, at: $0.time) }
}
```

### İçeriği masaya yerleştirme

```swift
func placeOnTable() throws -> Placement {
    let solver = PlacementSolver(options: .init(gridSize: 0.05, rotationStep: .pi / 4))
    let tap = SurfaceHit(position: SIMD3(0.42, 0.74, -0.81), normal: SIMD3(0, 1, 0))
    return try solver.place(on: tap, facing: SIMD3(0, 1.6, 0))
}
```

İçerik `(0.40, 0.74, -0.80)` konumunda dik durur ve 45°'lik adımla izleyiciye döner. Önü, USD kuralına göre +Z eksenidir. Bir duvarda ise duvara yaslanır ve dışarıya bakar.

### Boyutu bilinmeyen modeli sığdırma

```swift
func fitModel() -> Float {
    guard let bounds = SpatialBounds(min: SIMD3(-60, 0, -40), max: SIMD3(60, 90, 40)) else { return 1 }
    return bounds.scaleToFit(SIMD3(repeating: 0.3))
}
```

`0.0025` döndürür: 120 birim genişliğinde hazırlanmış bir model 30 cm genişliğinde olur. Bir RealityKit entity'sinde bunun yerine `entity.scaleToFit(SIMD3(repeating: 0.3))` çağrısını yapın.

### Yerleştirilen içeriği kaydetme ve geri yükleme

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

visionOS'ta anchor, `WorldTrackingProvider`'dan gelir. Canlı alan, yeni içeriği 50 cm içindeki izlenen bir anchor'a bağlar ya da yeni bir tane oluşturur:

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

[Örnek uygulamanın](Examples/ARCraftLab) ekranları; [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) ile iOS simülatöründen alınmıştır. Her biri ARCraft'ı sentetik ya da kayıtlı veriyle çalıştırır.

| El jestleri | Yumuşatma | Yerleştirme | Kalıcılık |
| --- | --- | --- | --- |
| ![El jestleri, açık tema](docs/images/gestures-light.png) | ![Yumuşatma, açık tema](docs/images/smoothing-light.png) | ![Yerleştirme, açık tema](docs/images/placement-light.png) | ![Kalıcılık, açık tema](docs/images/persistence-light.png) |
| ![El jestleri, koyu tema](docs/images/gestures-dark.png) | ![Yumuşatma, koyu tema](docs/images/smoothing-dark.png) | ![Yerleştirme, koyu tema](docs/images/placement-dark.png) | ![Kalıcılık, koyu tema](docs/images/persistence-dark.png) |

## Dokümantasyon

- [API başvurusu](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/) (DocC, `main` dalından GitHub Pages'e yayımlanır)
- Xcode'da **Product › Build Documentation** ile ya da komut satırından yerelde derleyin:

```sh
xcodebuild docbuild -scheme ARCraft -destination 'generic/platform=visionOS Simulator'
```

## Rehberler

- [Getting Started](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/gettingstarted)
  — paketi ekleyin, sentetik veride, ardından ARKit verisinde pinch hareketini tanıyın
  ([kaynak](Sources/ARCraft/ARCraft.docc/GettingStarted.md)).
- [Recognizing Hand Gestures](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/recognizinghandgestures)
  — şekillerin nasıl ölçüldüğü, debounce, histerezis, takip kaybı, iki el ve iOS'ta Vision
  ([kaynak](Sources/ARCraft/ARCraft.docc/RecognizingHandGestures.md)).
- [Smoothing Tracking Data](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/smoothingtrackingdata)
  — One Euro filtresini ayarlama ve pozları yumuşatma
  ([kaynak](Sources/ARCraft/ARCraft.docc/SmoothingTrackingData.md)).
- [Placing Content on Surfaces](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/placingcontentonsurfaces)
  — zeminler, duvarlar, oturtma ve modelleri sığdırma
  ([kaynak](Sources/ARCraft/ARCraft.docc/PlacingContentOnSurfaces.md)).
- [Persisting Placed Content](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/persistingplacedcontent)
  — world anchor'lar, açılışta geri yükleme, temizleme ve dosya biçiminin sınırları
  ([kaynak](Sources/ARCraft/ARCraft.docc/PersistingPlacedContent.md)).
- [Testing Without a Headset](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/testingwithoutaheadset)
  — birim testlerinde sentetik ve kayıtlı eller ile anchor'lar
  ([kaynak](Sources/ARCraft/ARCraft.docc/TestingWithoutAHeadset.md)).

## Gereksinimler

| Platform | En düşük sürüm |
| --- | --- |
| iOS | 18 |
| macOS | 15 |
| visionOS | 2 |
| Araç zinciri | Swift 6.2 · Xcode 26+ |

El ve dünya takibi için Apple Vision Pro gerekir; ARKit adaptörleri yalnızca visionOS için derlenir. CI, GitHub'ın `macos-26` runner imajındaki varsayılan Xcode ile derler. Paket, Xcode 27 ile iOS 27 ve visionOS 27 SDK'larına karşı geliştirilir.

## Başka bir şey ne zaman kullanılmalı

- **Entity'leri standart jestlerle taşımak, döndürmek ve ölçeklemek:** RealityKit'in `ManipulationComponent` (visionOS 26) ve `GestureComponent` bileşenleri bunu ek kod olmadan yapar.
- **Özel statik el pozlarını benzerliğe göre eşleştirmek:** [HandVector](https://github.com/XanderXu/HandVector), tüm elin eklem vektörlerini kayıtlı şablonlarla karşılaştırır; ARCraft ise dört sabit şekli açık eşiklerle sınıflandırır.
- **SwiftUI modifier'ları olarak anlamsal jestler (alkış, parmak şıklatma, yumruk):** [HandGesture](https://github.com/johnhaney/HandGesture).
- **3B arayüz kontrolleri (anahtarlar, kaydırıcılar, entity olarak düğmeler):** [RealityUI](https://github.com/maxxfrazer/RealityUI).

## Mimari

- `Sources/ARCraft/Math`, `Filtering`, `Hands`, `Placement` ve `Persistence` yalnızca Foundation ve `simd` kullanan değer tipleridir. `PlacementStore` tek referans tipidir (dosya erişimini sıraya koyan bir actor).
- `Sources/ARCraft/Platform` adaptörleri barındırır: `ARKit+ARCraft.swift` (yalnızca visionOS) ve `Vision+ARCraft.swift`. `Placement/Entity+ARCraft.swift` RealityKit yardımcılarını ekler.
- Dışarıdan girdi kabul eden her tip, bu girdiyi sınırda doğrular: matrisler ve çözülen sayılar sonlu olmalıdır, yapılandırma değerleri sınırlandırılır, koleksiyonların ve dosyaların boyut sınırı vardır ve dosya adları uygulamanın klasöründen çıkamaz.
- Testler `Tests/ARCraftTests` içindedir (Swift Testing). El sınıflandırıcısı, sentetik ellerin yanı sıra elle yazılmış eklem verileriyle de test edilir; böylece ikisi yalnızca birbiriyle uyumlu olmakla kalmaz.

Testleri yerelde çalıştırın:

```sh
swift test                                    # macOS
xcodebuild test -scheme ARCraft \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
xcodebuild test -scheme ARCraft \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

## Yol haritası

- 2.0.0 sürümünü etiketlemek ve paketi Swift Package Index'e eklemek; `.spi.yml` zaten depoda duruyor.
- `HandGestureRecognizer` üzerine iki elli jestler (iki pinch arasında ölçekleme ve döndürme).
- İçeriğin algılanan masanın kenarları içinde kalması için plane anchor'ların kapladığı alana göre yerleştirme.

## Katkıda bulunma

Katkılarınızı bekliyoruz. Pull request açmadan önce [katkı rehberini](https://github.com/muhittincamdali/ARCraft/blob/main/CONTRIBUTING.md) ve [davranış kurallarını](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md) okuyun. Güvenlik açıklarını [güvenlik politikasında](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md) anlatıldığı gibi gizli olarak bildirin.

## Lisans

MIT lisansıyla yayımlanmıştır. Ayrıntılar için [LICENSE](LICENSE) dosyasına bakın.
