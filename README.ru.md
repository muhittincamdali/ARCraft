<!-- i18n-source: README.md@82cfebf386a0495e4dc0d749638d4e7ac6f8f4d0 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/banner-light.svg" alt="ARCraft: Hand gestures, jitter filters, surface placement and world anchor persistence for visionOS and iOS apps."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/ARCraft/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/ARCraft/actions/workflows/ci.yml/badge.svg" alt="Статус CI"></a>
<a href="https://github.com/muhittincamdali/ARCraft/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-version-light.svg" alt="Последняя версия: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-platforms-light.svg" alt="Поддерживаемые платформы: iOS 18+ · macOS 15+ · visionOS 2+"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-language-light.svg" alt="Версия языка: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-license-light.svg" alt="Лицензия: MIT"></picture></a>
</p>

<p align="center">
<a href="#быстрый-старт"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-start-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-start-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-start-ru-light.svg" alt="Начать"></picture></a>
<a href="https://muhittincamdali.github.io/ARCraft/documentation/arcraft/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-docs-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-docs-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-docs-ru-light.svg" alt="Документация"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-examples-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-examples-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-examples-ru-light.svg" alt="Примеры"></picture></a>
</p>

> Это перевод README на английском языке. Если они расходятся, актуальна английская версия.

<!-- brand:end -->

ARCraft — это Swift-пакет для приложений visionOS и iOS, которые используют отслеживание рук и world anchors. Он не оборачивает RealityKit: RealityKit уже отрисовывает, симулирует и обрабатывает сущности (entities). ARCraft покрывает код, который находится между сырыми данными ARKit и вашей сценой и который каждое пространственное приложение иначе пишет само: распознавание щипка без мерцания, удержание курсора на кончике пальца неподвижным, превращение касания стола в вертикальную позу, выровненную по сетке, и запоминание того, какой контент к какому world anchor относится, между запусками. Ядро — это обычный Swift и `simd` без зависимостей, поэтому оно запускается и тестируется на Mac, в симуляторе и в превью; тонкие адаптеры связывают его с ARKit на visionOS, с позой руки из Vision на iOS и macOS и с сущностями RealityKit.

## Основные возможности

- **Жесты без мерцания** — `HandGestureRecognizer` добавляет покадровое подавление дребезга, увеличенное расстояние отпускания для щипков и отмену при потере отслеживания поверх не зависящего от масштаба классификатора формы руки (щипок, указание, кулак, открытая ладонь), который работает в метрах (ARKit) и в пикселях (Vision).
- **Фильтрация дрожания** — `OneEuroFilter` и `PoseFilter` сглаживают кончики пальцев, запястья и anchors: сильно в покое и слабо в движении; значения NaN и метки времени не по порядку игнорируются.
- **Размещение на поверхностях** — `PlacementSolver` держит контент вертикально на столах, плашмя на стенах и повёрнутым к пользователю, с необязательной привязкой к сетке и к шагу поворота; `SpatialBounds` вписывает модели неизвестного размера в объём.
- **Контент, который остаётся в комнате** — `AnchoredItem`, `AnchorResolver` и `PlacementStore` записывают, что было размещено относительно какого `WorldAnchor`, и читают файл обратно как недоверенный ввод: с ограничением размера до разбора, с версией, а одна повреждённая запись не приводит к потере остальных.
- **Работает без гарнитуры** — `SyntheticHand` строит позы рук для симулятора, превью и тестов; `HandPose` поддерживает `Codable` для записи и воспроизведения.
- **Протестировано** — 103 теста Swift Testing запускаются на macOS и в симуляторе iPhone (105 в симуляторе visionOS, включая адаптеры ARKit), а каждый пример из README ниже компилируется и выполняется тестовым таргетом.

### Что входит в пакет

| Область | Типы |
| --- | --- |
| Руки | `HandPose`, `HandJoint`, `Finger`, `HandShapeClassifier`, `HandShapeReading`, `HandGestureRecognizer`, `HandGestureEvent`, `SyntheticHand` |
| Фильтрация | `OneEuroFilter`, `OneEuroConfiguration`, `PoseFilter` |
| Размещение | `PlacementSolver`, `PlacementOptions`, `Placement`, `SurfaceHit`, `SurfaceOrientation`, `SpatialBounds`, `Entity.setPose(_:relativeTo:)`, `Entity.scaleToFit(_:allowsUpscaling:)` |
| Сохранение | `AnchoredItem`, `WorldAnchorState`, `AnchorResolver`, `ItemStatus`, `PlacementArchive`, `PlacementStore` |
| Геометрия | `Pose` (положение и единичный кватернион, `Codable`, отклоняет NaN) |
| Адаптеры | `HandPose(_: HandAnchor, timestamp:)`, `WorldAnchorState(_: WorldAnchor)`, `AnchorResolver.apply(_:)` на visionOS; `HandPose(_: HumanHandPoseObservation, imageSize:timestamp:)` с Vision |

## Быстрый старт

**1. Добавьте пакет**

В Xcode выберите **File › Add Package Dependencies…** и введите адрес репозитория:

```text
https://github.com/muhittincamdali/ARCraft.git
```

Вставьте его в поле поиска в правом верхнем углу окна, выберите для **Dependency Rule** значение **Branch** › `main` и нажмите **Add Package**. В следующем окне выберите таргет вашего приложения рядом с **ARCraft** и снова нажмите **Add Package**.

**2. Импортируйте модуль**

```swift
import ARCraft
```

Поместите эту строку в начало Swift-файла, где вы используете ARCraft.

**3. Используйте**

Добавьте эту функцию в любой Swift-файл вашего приложения (или в модульный тест) и вызовите `print(pinchDemo())`. Она сжимает и разжимает синтетическую руку со скоростью 90 кадров в секунду, поэтому работает на любом устройстве и в симуляторе:

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

Она выведет `["pinch began at frame 4", "pinch ended at frame 9"]`. Щипок начинается на втором закрытом кадре и заканчивается после трёх кадров с раскрытой рукой за пределами расстояния отпускания — именно это и защищает его от мерцания. На Apple Vision Pro вы передаёте тому же recognizer `HandPose(update.anchor, timestamp: update.timestamp)`, как показано в разделе [Использование](#использование).

## Установка

### Swift Package Manager

В Xcode выберите **File › Add Package Dependencies…** и введите адрес репозитория:

```text
https://github.com/muhittincamdali/ARCraft.git
```

В манифесте `Package.swift` добавьте пакет и продукт:

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

Описанный здесь API находится в ветке `main`. Единственный на сегодня тег `v1.0.0` был создан до добавления исходного кода библиотеки, поэтому используйте `main`, пока не будет помечен тегом следующий релиз (см. [журнал изменений](CHANGELOG.md)).

## Использование

Каждый пример ниже скопирован из [демонстрационного приложения](Examples/ARCraftLab), которое CI собирает для iOS, macOS и visionOS.

### Распознавание щипков на Apple Vision Pro

Из файла [`LiveSpaceModel.swift`](Examples/ARCraftLab/ARCraftLab/LiveSpaceModel.swift), который работает внутри `ImmersiveSpace` с ключом `NSHandsTrackingUsageDescription` в Info.plist:

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

`pinch` — это `HandGestureRecognizer(configuration: .init(shape: .pinch))`; если рука теряется на время, превышающее допуск, жест отменяется, а не завершается, поэтому рука, вышедшая из поля зрения, никогда ничего не размещает.

### Сглаживание кончика пальца

```swift
func smoothFingertip(_ samples: [(time: TimeInterval, position: SIMD3<Float>)]) -> [SIMD3<Float>] {
    var filter = OneEuroFilter<SIMD3<Float>>(configuration: .handJoints)
    return samples.compactMap { filter.filter($0.position, at: $0.time) }
}
```

### Размещение контента на столе

```swift
func placeOnTable() throws -> Placement {
    let solver = PlacementSolver(options: .init(gridSize: 0.05, rotationStep: .pi / 4))
    let tap = SurfaceHit(position: SIMD3(0.42, 0.74, -0.81), normal: SIMD3(0, 1, 0))
    return try solver.place(on: tap, facing: SIMD3(0, 1.6, 0))
}
```

Контент стоит вертикально в точке `(0.40, 0.74, -0.80)` и повёрнут к пользователю с шагом 45°. Его лицевая сторона — ось +Z, как принято в USD. На стене он лежал бы плашмя на стене и смотрел наружу.

### Подгонка модели неизвестного размера

```swift
func fitModel() -> Float {
    guard let bounds = SpatialBounds(min: SIMD3(-60, 0, -40), max: SIMD3(60, 90, 40)) else { return 1 }
    return bounds.scaleToFit(SIMD3(repeating: 0.3))
}
```

Возвращает `0.0025`: модель, созданная шириной 120 единиц, становится шириной 30 см. Для сущности RealityKit вместо этого вызовите `entity.scaleToFit(SIMD3(repeating: 0.3))`.

### Сохранение размещённого контента и его восстановление

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

На visionOS anchor берётся из `WorldTrackingProvider`. Живое пространство привязывает новый контент к отслеживаемому anchor в пределах 50 см или создаёт новый:

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

## Демо

Экраны [демонстрационного приложения](Examples/ARCraftLab), снятые в симуляторе iOS скриптом [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh). На каждом ARCraft работает на синтетических или записанных данных.

| Жесты рук | Сглаживание | Размещение | Сохранение |
| --- | --- | --- | --- |
| ![Жесты рук, светлая тема](docs/images/gestures-light.png) | ![Сглаживание, светлая тема](docs/images/smoothing-light.png) | ![Размещение, светлая тема](docs/images/placement-light.png) | ![Сохранение, светлая тема](docs/images/persistence-light.png) |
| ![Жесты рук, тёмная тема](docs/images/gestures-dark.png) | ![Сглаживание, тёмная тема](docs/images/smoothing-dark.png) | ![Размещение, тёмная тема](docs/images/placement-dark.png) | ![Сохранение, тёмная тема](docs/images/persistence-dark.png) |

## Документация

- [Справочник API](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/) (DocC, публикуется на GitHub Pages из ветки `main`)
- Соберите документацию локально в Xcode через **Product › Build Documentation** или из командной строки:

```sh
xcodebuild docbuild -scheme ARCraft -destination 'generic/platform=visionOS Simulator'
```

## Руководства

- [Getting Started](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/gettingstarted)
  — добавление пакета, распознавание щипка на синтетических данных, а затем на данных ARKit
  ([исходный код](Sources/ARCraft/ARCraft.docc/GettingStarted.md)).
- [Recognizing Hand Gestures](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/recognizinghandgestures)
  — как измеряются формы, подавление дребезга, гистерезис, потеря отслеживания, две руки и Vision на iOS
  ([исходный код](Sources/ARCraft/ARCraft.docc/RecognizingHandGestures.md)).
- [Smoothing Tracking Data](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/smoothingtrackingdata)
  — настройка фильтра One Euro и сглаживание поз
  ([исходный код](Sources/ARCraft/ARCraft.docc/SmoothingTrackingData.md)).
- [Placing Content on Surfaces](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/placingcontentonsurfaces)
  — полы, стены, привязка и подгонка моделей
  ([исходный код](Sources/ARCraft/ARCraft.docc/PlacingContentOnSurfaces.md)).
- [Persisting Placed Content](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/persistingplacedcontent)
  — world anchors, восстановление при запуске, очистка и ограничения формата файла
  ([исходный код](Sources/ARCraft/ARCraft.docc/PersistingPlacedContent.md)).
- [Testing Without a Headset](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/testingwithoutaheadset)
  — синтетические и записанные руки и anchors в модульных тестах
  ([исходный код](Sources/ARCraft/ARCraft.docc/TestingWithoutAHeadset.md)).

## Требования

| Платформа | Минимальная версия |
| --- | --- |
| iOS | 18 |
| macOS | 15 |
| visionOS | 2 |
| Инструменты | Swift 6.2 · Xcode 26+ |

Для отслеживания рук и мира нужен Apple Vision Pro; адаптеры ARKit компилируются только для visionOS. CI собирает проект с Xcode по умолчанию из образа раннера `macos-26` на GitHub. Пакет разрабатывается в Xcode 27 с SDK iOS 27 и visionOS 27.

## Когда стоит использовать что-то другое

- **Перемещение, поворот и масштабирование сущностей стандартными жестами:** `ManipulationComponent` из RealityKit (visionOS 26) и `GestureComponent` делают это без дополнительного кода.
- **Сопоставление собственных статичных поз руки по сходству:** [HandVector](https://github.com/XanderXu/HandVector) сравнивает векторы суставов всей руки с записанными шаблонами; ARCraft классифицирует четыре фиксированные формы по явным порогам.
- **Семантические жесты в виде модификаторов SwiftUI (хлопок, щелчок пальцами, удар кулаком):** [HandGesture](https://github.com/johnhaney/HandGesture).
- **Элементы управления 3D-интерфейса (переключатели, ползунки, кнопки в виде сущностей):** [RealityUI](https://github.com/maxxfrazer/RealityUI).

## Архитектура

- `Sources/ARCraft/Math`, `Filtering`, `Hands`, `Placement` и `Persistence` — типы-значения, которые используют только Foundation и `simd`. `PlacementStore` — единственный ссылочный тип (actor, сериализующий доступ к файлам).
- `Sources/ARCraft/Platform` содержит адаптеры: `ARKit+ARCraft.swift` (только visionOS) и `Vision+ARCraft.swift`. `Placement/Entity+ARCraft.swift` добавляет вспомогательные функции для RealityKit.
- Каждый тип, принимающий данные извне, проверяет их на границе: матрицы и декодированные числа должны быть конечными, значения конфигурации ограничиваются, у коллекций и файлов есть ограничения по размеру, а имена файлов не могут выйти за пределы папки приложения.
- Тесты находятся в `Tests/ARCraftTests` (Swift Testing). Классификатор рук проверяется как на синтетических руках, так и на суставах, введённых вручную, чтобы они не просто согласовывались друг с другом.

Запустите тесты локально:

```sh
swift test                                    # macOS
xcodebuild test -scheme ARCraft \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
xcodebuild test -scheme ARCraft \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

## План развития

- Поставить тег релиза 2.0.0 и добавить пакет в Swift Package Index; `.spi.yml` уже есть в репозитории.
- Жесты двумя руками (масштабирование и поворот между двумя щипками) поверх `HandGestureRecognizer`.
- Размещение с учётом границ plane anchors, чтобы контент оставался в пределах краёв обнаруженного стола.

## Участие в разработке

Мы рады вашему участию. Перед открытием pull request прочитайте [руководство для участников](https://github.com/muhittincamdali/ARCraft/blob/main/CONTRIBUTING.md) и [кодекс поведения](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md). О проблемах безопасности сообщайте конфиденциально, как описано в [политике безопасности](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md).

## Лицензия

Распространяется по лицензии MIT. Подробнее — в файле [LICENSE](LICENSE).
