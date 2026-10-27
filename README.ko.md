<!-- i18n-source: README.md@c964923478924fb650768a0ae2e1614eafd6cf3d status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/banner-light.svg" alt="ARCraft: Hand gestures, jitter filters, surface placement and world anchor persistence for visionOS and iOS apps."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/ARCraft/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/ARCraft/actions/workflows/ci.yml/badge.svg" alt="CI 상태"></a>
<a href="https://github.com/muhittincamdali/ARCraft/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-version-light.svg" alt="최신 버전: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-platforms-light.svg" alt="지원 플랫폼: iOS 18+ · macOS 15+ · visionOS 2+"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-language-light.svg" alt="언어 버전: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-license-light.svg" alt="라이선스: MIT"></picture></a>
</p>

<p align="center">
<a href="#빠른-시작"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-start-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-start-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-start-ko-light.svg" alt="시작하기"></picture></a>
<a href="https://muhittincamdali.github.io/ARCraft/documentation/arcraft/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-docs-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-docs-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-docs-ko-light.svg" alt="문서"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-examples-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-examples-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-examples-ko-light.svg" alt="예제"></picture></a>
</p>

> 이 문서는 영어 README의 번역본입니다. 내용이 다를 경우 영어 버전이 최신입니다.

<!-- brand:end -->

ARCraft는 핸드 트래킹과 월드 앵커를 사용하는 visionOS 및 iOS 앱을 위한 Swift 패키지입니다. RealityKit을 감싸지 않습니다. 엔티티의 렌더링, 시뮬레이션, 조작은 이미 RealityKit이 맡고 있기 때문입니다. ARCraft는 ARKit의 원시 데이터와 여러분의 씬 사이에 있는 코드, 즉 공간 앱마다 따로 작성하게 되는 부분을 다룹니다. 깜빡임 없이 핀치를 인식하고, 손끝 커서를 안정적으로 유지하고, 테이블을 탭한 위치를 똑바로 서 있고 스냅된 포즈로 바꾸고, 어떤 콘텐츠가 어떤 월드 앵커에 속하는지를 앱을 다시 실행해도 기억하는 일입니다. 코어는 의존성이 없는 순수 Swift와 `simd`로 되어 있어서 Mac, 시뮬레이터, 프리뷰에서 실행하고 테스트할 수 있으며, 얇은 어댑터가 visionOS에서는 ARKit에, iOS와 macOS에서는 Vision의 손 포즈에, 그리고 RealityKit 엔티티에 연결해 줍니다.

## 주요 기능

- **깜빡이지 않는 제스처** — `HandGestureRecognizer`는 크기에 영향을 받지 않는 손 모양 분류기(핀치, 포인트, 주먹, 펼친 손바닥. ARKit의 미터와 Vision의 픽셀 모두에서 동작) 위에 프레임 디바운스, 핀치를 위한 더 넓은 해제 거리, 트래킹 손실 시 취소 기능을 더합니다.
- **지터 필터링** — `OneEuroFilter`와 `PoseFilter`는 손끝, 손목, 앵커를 정지해 있을 때는 강하게, 움직일 때는 약하게 스무딩하고, NaN 샘플과 순서가 어긋난 타임스탬프는 무시합니다.
- **표면 배치** — `PlacementSolver`는 콘텐츠를 테이블에서는 똑바로 세우고, 벽에서는 벽면에 붙여 눕히고, 사용자를 향하게 합니다. 격자 스냅과 회전 스냅도 선택적으로 쓸 수 있습니다. `SpatialBounds`는 크기를 알 수 없는 모델을 볼륨 안에 맞춰 줍니다.
- **방에 남는 콘텐츠** — `AnchoredItem`, `AnchorResolver`, `PlacementStore`는 어떤 `WorldAnchor`를 기준으로 무엇을 배치했는지 기록하고, 다시 읽어 들이는 파일은 신뢰할 수 없는 입력으로 취급합니다. 파싱 전에 크기를 제한하고, 버전이 관리되며, 항목 하나가 손상되어도 나머지는 잃지 않습니다.
- **헤드셋 없이도 동작** — `SyntheticHand`가 시뮬레이터, 프리뷰, 테스트용 손 포즈를 만들어 줍니다. `HandPose`는 `Codable`이라 녹화와 재생에 쓸 수 있습니다.
- **테스트 완료** — Swift Testing 테스트 100개가 macOS와 iPhone 시뮬레이터에서 실행되며(visionOS 시뮬레이터에서는 ARKit 어댑터를 포함해 102개), 아래의 모든 README 예제는 테스트 타깃에서 컴파일되고 실행됩니다.

### 포함된 항목

| 영역 | 타입 |
| --- | --- |
| 손 | `HandPose`, `HandJoint`, `Finger`, `HandShapeClassifier`, `HandShapeReading`, `HandGestureRecognizer`, `HandGestureEvent`, `SyntheticHand` |
| 필터링 | `OneEuroFilter`, `OneEuroConfiguration`, `PoseFilter` |
| 배치 | `PlacementSolver`, `PlacementOptions`, `Placement`, `SurfaceHit`, `SurfaceOrientation`, `SpatialBounds`, `Entity.setPose(_:relativeTo:)`, `Entity.scaleToFit(_:allowsUpscaling:)` |
| 영속성 | `AnchoredItem`, `WorldAnchorState`, `AnchorResolver`, `ItemStatus`, `PlacementArchive`, `PlacementStore` |
| 지오메트리 | `Pose` (위치와 단위 쿼터니언, `Codable`, NaN 거부) |
| 어댑터 | visionOS용: `HandPose(_: HandAnchor, timestamp:)`, `WorldAnchorState(_: WorldAnchor)`, `AnchorResolver.apply(_:)`; Vision용: `HandPose(_: HumanHandPoseObservation, imageSize:timestamp:)` |

## 빠른 시작

**1. 패키지 추가**

Xcode에서 **File › Add Package Dependencies…**를 선택하고 저장소 URL을 입력하세요.

```text
https://github.com/muhittincamdali/ARCraft.git
```

창 오른쪽 위의 검색 필드에 붙여 넣고, **Dependency Rule**을 **Branch** › `main`으로 설정한 다음 **Add Package**를 클릭하세요. 다음 창에서 **ARCraft** 옆에 있는 앱 타깃을 선택하고 **Add Package**를 다시 클릭하세요.

**2. 모듈 가져오기**

```swift
import ARCraft
```

ARCraft를 사용하는 Swift 파일의 맨 위에 이 줄을 넣으세요.

**3. 사용하기**

앱의 아무 Swift 파일(또는 유닛 테스트)에 이 함수를 추가하고 `print(pinchDemo())`를 호출하세요. 합성 손을 초당 90프레임으로 쥐었다 펴므로 어떤 기기에서든 시뮬레이터에서든 실행됩니다.

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

출력은 `["pinch began at frame 4", "pinch ended at frame 9"]`입니다. 핀치는 두 번째로 닫힌 프레임에서 시작되고, 해제 거리를 넘어 세 프레임 동안 열려 있으면 끝납니다. 이것이 깜빡임을 막아 주는 방식입니다. Apple Vision Pro에서는 [사용법](#사용법)에서 보듯이 같은 recognizer에 `HandPose(update.anchor, timestamp: update.timestamp)`를 넘겨 주면 됩니다.

## 설치

### Swift Package Manager

Xcode에서 **File › Add Package Dependencies…**를 선택하고 저장소 URL을 입력하세요.

```text
https://github.com/muhittincamdali/ARCraft.git
```

`Package.swift` 매니페스트에 패키지와 프로덕트를 추가하세요.

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

여기에 설명된 API는 `main` 브랜치에 있습니다. 지금까지 유일한 태그인 `v1.0.0`은 라이브러리 소스가 추가되기 전에 만들어졌으므로, 다음 릴리스에 태그가 붙을 때까지는 `main`에 의존하세요([변경 내역](CHANGELOG.md) 참고).

## 사용법

아래의 모든 예제는 CI가 iOS, macOS, visionOS용으로 빌드하는 [예제 앱](Examples/ARCraftLab)에서 가져온 것입니다.

### Apple Vision Pro에서 핀치 인식하기

[`LiveSpaceModel.swift`](Examples/ARCraftLab/ARCraftLab/LiveSpaceModel.swift)에서 가져온 코드입니다. 이 코드는 Info.plist에 `NSHandsTrackingUsageDescription`이 있는 `ImmersiveSpace` 안에서 실행됩니다.

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

`pinch`는 `HandGestureRecognizer(configuration: .init(shape: .pinch))`입니다. 손이 허용 시간보다 오래 사라지면 제스처는 종료되지 않고 취소되므로, 손이 시야를 벗어나도 아무것도 배치되지 않습니다.

### 손끝 스무딩하기

```swift
func smoothFingertip(_ samples: [(time: TimeInterval, position: SIMD3<Float>)]) -> [SIMD3<Float>] {
    var filter = OneEuroFilter<SIMD3<Float>>(configuration: .handJoints)
    return samples.compactMap { filter.filter($0.position, at: $0.time) }
}
```

### 테이블에 콘텐츠 배치하기

```swift
func placeOnTable() throws -> Placement {
    let solver = PlacementSolver(options: .init(gridSize: 0.05, rotationStep: .pi / 4))
    let tap = SurfaceHit(position: SIMD3(0.42, 0.74, -0.81), normal: SIMD3(0, 1, 0))
    return try solver.place(on: tap, facing: SIMD3(0, 1.6, 0))
}
```

콘텐츠는 `(0.40, 0.74, -0.80)`에 똑바로 서서 45° 단위로 사용자를 향합니다. 앞면은 +Z 축이며, USD의 규칙입니다. 벽에서는 벽면에 붙어 바깥쪽을 향합니다.

### 크기를 모르는 모델 맞추기

```swift
func fitModel() -> Float {
    guard let bounds = SpatialBounds(min: SIMD3(-60, 0, -40), max: SIMD3(60, 90, 40)) else { return 1 }
    return bounds.scaleToFit(SIMD3(repeating: 0.3))
}
```

`0.0025`를 반환합니다. 너비 120 유닛으로 만든 모델은 너비 30 cm가 됩니다. RealityKit 엔티티에서는 대신 `entity.scaleToFit(SIMD3(repeating: 0.3))`를 호출하세요.

### 배치한 콘텐츠 저장하고 복원하기

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

visionOS에서는 앵커가 `WorldTrackingProvider`에서 옵니다. 라이브 스페이스는 새 콘텐츠를 50 cm 이내에서 트래킹 중인 앵커에 연결하거나, 없으면 새로 만듭니다.

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

## 데모

[예제 앱](Examples/ARCraftLab)의 화면으로, [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh)가 iOS 시뮬레이터에서 캡처했습니다. 각 화면은 합성 데이터나 녹화된 데이터로 ARCraft를 실행합니다.

| 손 제스처 | 스무딩 | 배치 | 영속성 |
| --- | --- | --- | --- |
| ![손 제스처, 라이트](docs/images/gestures-light.png) | ![스무딩, 라이트](docs/images/smoothing-light.png) | ![배치, 라이트](docs/images/placement-light.png) | ![영속성, 라이트](docs/images/persistence-light.png) |
| ![손 제스처, 다크](docs/images/gestures-dark.png) | ![스무딩, 다크](docs/images/smoothing-dark.png) | ![배치, 다크](docs/images/placement-dark.png) | ![영속성, 다크](docs/images/persistence-dark.png) |

## 문서

- [API 레퍼런스](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/) (DocC, `main`에서 GitHub Pages로 게시)
- Xcode에서 **Product › Build Documentation**으로, 또는 명령줄에서 로컬로 빌드할 수 있습니다.

```sh
xcodebuild docbuild -scheme ARCraft -destination 'generic/platform=visionOS Simulator'
```

## 가이드

- [Getting Started](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/gettingstarted) — 패키지를 추가하고, 합성 데이터에서 핀치를 인식한 다음 ARKit 데이터에서 인식하기 ([소스](Sources/ARCraft/ARCraft.docc/GettingStarted.md))
- [Recognizing Hand Gestures](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/recognizinghandgestures) — 손 모양을 측정하는 방법, 디바운스, 히스테리시스, 트래킹 손실, 양손, iOS의 Vision ([소스](Sources/ARCraft/ARCraft.docc/RecognizingHandGestures.md))
- [Smoothing Tracking Data](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/smoothingtrackingdata) — One Euro 필터 조정과 포즈 스무딩 ([소스](Sources/ARCraft/ARCraft.docc/SmoothingTrackingData.md))
- [Placing Content on Surfaces](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/placingcontentonsurfaces) — 바닥, 벽, 스냅, 모델 맞추기 ([소스](Sources/ARCraft/ARCraft.docc/PlacingContentOnSurfaces.md))
- [Persisting Placed Content](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/persistingplacedcontent) — 월드 앵커, 실행 시 복원, 정리, 파일 형식의 한계 ([소스](Sources/ARCraft/ARCraft.docc/PersistingPlacedContent.md))
- [Testing Without a Headset](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/testingwithoutaheadset) — 합성 손과 녹화된 손, 유닛 테스트에서의 앵커 ([소스](Sources/ARCraft/ARCraft.docc/TestingWithoutAHeadset.md))

## 요구 사항

| 플랫폼 | 최소 버전 |
| --- | --- |
| iOS | 18 |
| macOS | 15 |
| visionOS | 2 |
| 툴체인 | Swift 6.2 · Xcode 26+ |

핸드 트래킹과 월드 트래킹에는 Apple Vision Pro가 필요하며, ARKit 어댑터는 visionOS용으로만 컴파일됩니다. CI는 GitHub의 `macos-26` 러너 이미지에 기본으로 들어 있는 Xcode로 빌드합니다. 이 패키지는 Xcode 27로 iOS 27 및 visionOS 27 SDK를 대상으로 개발합니다.

## 다른 도구가 더 나은 경우

- **표준 제스처로 엔티티를 이동, 회전, 확대/축소하기:** RealityKit의 `ManipulationComponent`(visionOS 26)와 `GestureComponent`가 추가 코드 없이 처리합니다.
- **직접 정의한 정지 손 포즈를 유사도로 매칭하기:** [HandVector](https://github.com/XanderXu/HandVector)는 손 전체의 관절 벡터를 녹화된 템플릿과 비교합니다. ARCraft는 명시적인 임계값으로 고정된 네 가지 모양을 분류합니다.
- **SwiftUI modifier로 쓰는 의미 기반 제스처(박수, 손가락 튕기기, 주먹 지르기):** [HandGesture](https://github.com/johnhaney/HandGesture).
- **3D UI 컨트롤(스위치, 슬라이더, 엔티티로 된 버튼):** [RealityUI](https://github.com/maxxfrazer/RealityUI).

## 아키텍처

- `Sources/ARCraft/Math`, `Filtering`, `Hands`, `Placement`, `Persistence`는 Foundation과 `simd`만 사용하는 값 타입입니다. `PlacementStore`는 유일한 참조 타입입니다(파일 접근을 직렬화하는 actor).
- `Sources/ARCraft/Platform`에는 어댑터가 있습니다. `ARKit+ARCraft.swift`(visionOS 전용)와 `Vision+ARCraft.swift`입니다. `Placement/Entity+ARCraft.swift`는 RealityKit 헬퍼를 추가합니다.
- 외부 입력을 받는 모든 타입은 경계에서 값을 검증합니다. 행렬과 디코딩된 숫자는 유한해야 하고, 설정 값은 범위로 제한되며, 컬렉션과 파일에는 크기 제한이 있고, 파일 이름은 앱의 폴더를 벗어날 수 없습니다.
- 테스트는 `Tests/ARCraftTests`(Swift Testing)에 있습니다. 손 분류기는 합성 손뿐 아니라 직접 입력한 관절 픽스처로도 테스트하므로, 둘이 서로에게만 맞는 일은 없습니다.

로컬에서 테스트를 실행하세요.

```sh
swift test                                    # macOS
xcodebuild test -scheme ARCraft \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
xcodebuild test -scheme ARCraft \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

## 로드맵

- 2.0.0 릴리스에 태그를 붙이고 패키지를 Swift Package Index에 추가하기. `.spi.yml`은 이미 저장소에 있습니다.
- `HandGestureRecognizer`를 바탕으로 한 양손 제스처(두 핀치 사이에서 확대/축소와 회전).
- 평면 앵커의 범위를 기준으로 한 배치. 감지된 테이블의 가장자리 안에 콘텐츠를 유지합니다.

## 기여하기

기여를 환영합니다. pull request를 열기 전에 [기여 가이드](https://github.com/muhittincamdali/ARCraft/blob/main/CONTRIBUTING.md)와 [행동 강령](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md)을 읽어 주세요. 보안 문제는 [보안 정책](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md)에 따라 비공개로 제보해 주세요.

## 라이선스

MIT 라이선스로 배포됩니다. 자세한 내용은 [LICENSE](LICENSE)를 참고하세요.
