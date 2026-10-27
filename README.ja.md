<!-- i18n-source: README.md@c964923478924fb650768a0ae2e1614eafd6cf3d status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/banner-light.svg" alt="ARCraft: Hand gestures, jitter filters, surface placement and world anchor persistence for visionOS and iOS apps."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/ARCraft/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/ARCraft/actions/workflows/ci.yml/badge.svg" alt="CI ステータス"></a>
<a href="https://github.com/muhittincamdali/ARCraft/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-version-light.svg" alt="最新バージョン: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-platforms-light.svg" alt="対応プラットフォーム: iOS 18+ · macOS 15+ · visionOS 2+"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-language-light.svg" alt="言語バージョン: Swift 6.2+"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/badge-license-light.svg" alt="ライセンス: MIT"></picture></a>
</p>

<p align="center">
<a href="#クイックスタート"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-start-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-start-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-start-ja-light.svg" alt="はじめる"></picture></a>
<a href="https://muhittincamdali.github.io/ARCraft/documentation/arcraft/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-docs-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-docs-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-docs-ja-light.svg" alt="ドキュメント"></picture></a>
<a href="https://github.com/muhittincamdali/ARCraft/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-examples-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-examples-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/ARCraft/main/.github/brand/button-examples-ja-light.svg" alt="サンプル"></picture></a>
</p>

> このドキュメントは英語版 README の翻訳です。内容が異なる場合は英語版が最新です。

<!-- brand:end -->

ARCraft は、ハンドトラッキングとワールドアンカーを使う visionOS / iOS アプリ向けの Swift パッケージです。RealityKit をラップするものではありません。エンティティの描画、シミュレーション、操作は RealityKit がすでに担っています。ARCraft が扱うのは、ARKit の生データとシーンの間にあって、空間アプリごとに各自で書かれがちなコードです。ちらつきなくピンチを認識する、指先カーソルを安定させる、テーブル上のタップを直立してスナップされたポーズに変換する、そしてどのコンテンツがどのワールドアンカーに属するかを起動をまたいで記憶する、といった処理です。コアは依存関係のない純粋な Swift と `simd` で書かれているため、Mac、シミュレータ、プレビューで実行・テストできます。薄いアダプタが、visionOS では ARKit、iOS と macOS では Vision の手のポーズ、そして RealityKit のエンティティにつなぎます。

## 主な特長

- **ちらつかないジェスチャ** — `HandGestureRecognizer` は、スケールに依存しない手の形の分類器（ピンチ、ポイント、握り拳、開いた手のひら。ARKit のメートル単位にも Vision のピクセル単位にも対応）の上に、フレーム単位のデバウンス、ピンチ用により広い解除距離、トラッキング喪失時のキャンセルを加えます。
- **ジッターのフィルタリング** — `OneEuroFilter` と `PoseFilter` は、指先、手首、アンカーを、静止時は強く、動いているときは軽くスムージングし、NaN のサンプルや順序が前後したタイムスタンプは無視します。
- **サーフェスへの配置** — `PlacementSolver` は、コンテンツをテーブルでは直立させ、壁では壁面に沿わせ、ユーザーのほうへ向けます。グリッドと回転のスナップも任意で使えます。`SpatialBounds` は、サイズ不明のモデルをボリュームに収めます。
- **部屋に残るコンテンツ** — `AnchoredItem`、`AnchorResolver`、`PlacementStore` は、どの `WorldAnchor` を基準に何を配置したかを記録し、読み戻すファイルは信頼できない入力として扱います。解析の前にサイズを制限し、バージョン管理され、1 件のエントリが壊れても残りは失われません。
- **ヘッドセットなしで動作** — `SyntheticHand` が、シミュレータ、プレビュー、テスト用の手のポーズを生成します。`HandPose` は `Codable` なので、記録と再生にも使えます。
- **テスト済み** — 100 個の Swift Testing テストが macOS と iPhone シミュレータで実行されます（visionOS シミュレータでは ARKit アダプタを含む 102 個）。また、以下の README のサンプルはすべて、テストターゲットでコンパイル・実行されています。

### 含まれるもの

| 分野 | 型 |
| --- | --- |
| 手 | `HandPose`, `HandJoint`, `Finger`, `HandShapeClassifier`, `HandShapeReading`, `HandGestureRecognizer`, `HandGestureEvent`, `SyntheticHand` |
| フィルタリング | `OneEuroFilter`, `OneEuroConfiguration`, `PoseFilter` |
| 配置 | `PlacementSolver`, `PlacementOptions`, `Placement`, `SurfaceHit`, `SurfaceOrientation`, `SpatialBounds`, `Entity.setPose(_:relativeTo:)`, `Entity.scaleToFit(_:allowsUpscaling:)` |
| 永続化 | `AnchoredItem`, `WorldAnchorState`, `AnchorResolver`, `ItemStatus`, `PlacementArchive`, `PlacementStore` |
| ジオメトリ | `Pose` （位置と単位クォータニオン、`Codable`、NaN は拒否） |
| アダプタ | visionOS 向け：`HandPose(_: HandAnchor, timestamp:)`, `WorldAnchorState(_: WorldAnchor)`, `AnchorResolver.apply(_:)`。Vision 向け：`HandPose(_: HumanHandPoseObservation, imageSize:timestamp:)` |

## クイックスタート

**1. パッケージを追加する**

Xcode で **File › Add Package Dependencies…** を選び、リポジトリの URL を入力します。

```text
https://github.com/muhittincamdali/ARCraft.git
```

ウィンドウ右上の検索欄に貼り付け、**Dependency Rule** を **Branch** › `main` に設定して、**Add Package** をクリックします。次のウィンドウで、**ARCraft** の横にあるアプリのターゲットを選び、もう一度 **Add Package** をクリックします。

**2. モジュールをインポートする**

```swift
import ARCraft
```

この行は、ARCraft を使う Swift ファイルの先頭に置きます。

**3. 使ってみる**

この関数をアプリ内の任意の Swift ファイル（またはユニットテスト）に追加し、`print(pinchDemo())` を呼び出してください。合成した手を 90 フレーム/秒で閉じて開くので、どのデバイスでもシミュレータでも動作します。

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

出力は `["pinch began at frame 4", "pinch ended at frame 9"]` です。ピンチは 2 つ目の閉じたフレームで始まり、解除距離を超えて 3 フレーム開いた時点で終わります。これがちらつきを防ぐ仕組みです。Apple Vision Pro では、[使い方](#使い方)で示すとおり、同じ recognizer に `HandPose(update.anchor, timestamp: update.timestamp)` を渡します。

## インストール

### Swift Package Manager

Xcode で **File › Add Package Dependencies…** を選び、リポジトリの URL を入力します。

```text
https://github.com/muhittincamdali/ARCraft.git
```

`Package.swift` マニフェストに、パッケージとプロダクトを追加します。

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

ここで説明している API は `main` ブランチにあります。これまでの唯一のタグ `v1.0.0` は、ライブラリのソースが追加される前に作成されたものなので、次のリリースにタグが付くまでは `main` に依存してください（[変更履歴](CHANGELOG.md)を参照）。

## 使い方

以下のサンプルはすべて、CI が iOS、macOS、visionOS 向けにビルドしている[サンプルアプリ](Examples/ARCraftLab)からコピーしたものです。

### Apple Vision Pro でピンチを認識する

[`LiveSpaceModel.swift`](Examples/ARCraftLab/ARCraftLab/LiveSpaceModel.swift) からの抜粋です。このコードは、Info.plist に `NSHandsTrackingUsageDescription` を含む `ImmersiveSpace` の中で動作します。

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

`pinch` は `HandGestureRecognizer(configuration: .init(shape: .pinch))` です。手が許容時間より長く失われると、ジェスチャは終了ではなくキャンセルされるため、手が視野から外れても何かが配置されることはありません。

### 指先をスムージングする

```swift
func smoothFingertip(_ samples: [(time: TimeInterval, position: SIMD3<Float>)]) -> [SIMD3<Float>] {
    var filter = OneEuroFilter<SIMD3<Float>>(configuration: .handJoints)
    return samples.compactMap { filter.filter($0.position, at: $0.time) }
}
```

### テーブルにコンテンツを配置する

```swift
func placeOnTable() throws -> Placement {
    let solver = PlacementSolver(options: .init(gridSize: 0.05, rotationStep: .pi / 4))
    let tap = SurfaceHit(position: SIMD3(0.42, 0.74, -0.81), normal: SIMD3(0, 1, 0))
    return try solver.place(on: tap, facing: SIMD3(0, 1.6, 0))
}
```

コンテンツは `(0.40, 0.74, -0.80)` に直立し、45° 刻みでユーザーのほうへ向きます。正面は +Z 軸で、これは USD の規約です。壁に置いた場合は、壁面に沿って外向きになります。

### サイズ不明のモデルを収める

```swift
func fitModel() -> Float {
    guard let bounds = SpatialBounds(min: SIMD3(-60, 0, -40), max: SIMD3(60, 90, 40)) else { return 1 }
    return bounds.scaleToFit(SIMD3(repeating: 0.3))
}
```

`0.0025` を返します。幅 120 ユニットで作られたモデルは、幅 30 cm になります。RealityKit のエンティティでは、代わりに `entity.scaleToFit(SIMD3(repeating: 0.3))` を呼び出してください。

### 配置したコンテンツを保存して復元する

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

visionOS では、アンカーは `WorldTrackingProvider` から取得します。ライブスペースでは、新しいコンテンツを 50 cm 以内のトラッキング中のアンカーに関連付けるか、なければ新しく作成します。

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

## デモ

[サンプルアプリ](Examples/ARCraftLab)の画面です。[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) が iOS シミュレータから取得しました。いずれも、合成データまたは記録データで ARCraft を動かしています。

| ハンドジェスチャ | スムージング | 配置 | 永続化 |
| --- | --- | --- | --- |
| ![ハンドジェスチャ, ライト](docs/images/gestures-light.png) | ![スムージング, ライト](docs/images/smoothing-light.png) | ![配置, ライト](docs/images/placement-light.png) | ![永続化, ライト](docs/images/persistence-light.png) |
| ![ハンドジェスチャ, ダーク](docs/images/gestures-dark.png) | ![スムージング, ダーク](docs/images/smoothing-dark.png) | ![配置, ダーク](docs/images/placement-dark.png) | ![永続化, ダーク](docs/images/persistence-dark.png) |

## ドキュメント

- [API リファレンス](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/) （DocC。`main` から GitHub Pages に公開）
- Xcode では **Product › Build Documentation** で、またはコマンドラインからローカルにビルドできます。

```sh
xcodebuild docbuild -scheme ARCraft -destination 'generic/platform=visionOS Simulator'
```

## ガイド

- [Getting Started](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/gettingstarted) — パッケージを追加し、合成データで、続いて ARKit のデータでピンチを認識する （[ソース](Sources/ARCraft/ARCraft.docc/GettingStarted.md)）。
- [Recognizing Hand Gestures](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/recognizinghandgestures) — 手の形の測定方法、デバウンス、ヒステリシス、トラッキングの喪失、両手、iOS の Vision （[ソース](Sources/ARCraft/ARCraft.docc/RecognizingHandGestures.md)）。
- [Smoothing Tracking Data](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/smoothingtrackingdata) — One Euro フィルタの調整とポーズのスムージング （[ソース](Sources/ARCraft/ARCraft.docc/SmoothingTrackingData.md)）。
- [Placing Content on Surfaces](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/placingcontentonsurfaces) — 床、壁、スナップ、モデルのフィット （[ソース](Sources/ARCraft/ARCraft.docc/PlacingContentOnSurfaces.md)）。
- [Persisting Placed Content](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/persistingplacedcontent) — ワールドアンカー、起動時の復元、クリーンアップ、ファイル形式の制限 （[ソース](Sources/ARCraft/ARCraft.docc/PersistingPlacedContent.md)）。
- [Testing Without a Headset](https://muhittincamdali.github.io/ARCraft/documentation/arcraft/testingwithoutaheadset) — 合成の手と記録した手、ユニットテストでのアンカー （[ソース](Sources/ARCraft/ARCraft.docc/TestingWithoutAHeadset.md)）。

## 動作要件

| プラットフォーム | 最小バージョン |
| --- | --- |
| iOS | 18 |
| macOS | 15 |
| visionOS | 2 |
| ツールチェーン | Swift 6.2 · Xcode 26+ |

ハンドトラッキングとワールドトラッキングには Apple Vision Pro が必要です。ARKit アダプタは visionOS 向けにのみコンパイルされます。CI は、GitHub の `macos-26` ランナーイメージに入っているデフォルトの Xcode でビルドします。パッケージは Xcode 27 と、iOS 27 および visionOS 27 の SDK を使って開発されています。

## 別の手段を選ぶ場合

- **標準のジェスチャでエンティティを移動・回転・拡大縮小する：** RealityKit の `ManipulationComponent`（visionOS 26）と `GestureComponent` が、追加のコードなしで対応します。
- **カスタムの静止した手のポーズを類似度で照合する：** [HandVector](https://github.com/XanderXu/HandVector) は、手全体の関節ベクトルを記録済みのテンプレートと比較します。ARCraft は、明示的なしきい値で 4 種類の固定された形を分類します。
- **SwiftUI のモディファイアとして使う意味的なジェスチャ（拍手、指パッチン、パンチ）：** [HandGesture](https://github.com/johnhaney/HandGesture)。
- **3D の UI コントロール（スイッチ、スライダー、エンティティとしてのボタン）：** [RealityUI](https://github.com/maxxfrazer/RealityUI)。

## アーキテクチャ

- `Sources/ARCraft/Math`、`Filtering`、`Hands`、`Placement`、`Persistence` は、Foundation と `simd` だけを使う値型です。`PlacementStore` は唯一の参照型です（ファイルアクセスを直列化する actor）。
- `Sources/ARCraft/Platform` にはアダプタがあります。`ARKit+ARCraft.swift`（visionOS のみ）と `Vision+ARCraft.swift` です。`Placement/Entity+ARCraft.swift` は RealityKit 用のヘルパーを追加します。
- 外部からの入力を受け取る型はすべて、境界で検証します。行列とデコードした数値は有限でなければならず、設定値はクランプされ、コレクションとファイルにはサイズ上限があり、ファイル名がアプリのフォルダの外に出ることはありません。
- テストは `Tests/ARCraftTests`（Swift Testing）にあります。手の形の分類器は、合成の手に加えて、手で入力した関節のフィクスチャでもテストしているため、両者が互いに一致しているだけという状態にはなりません。

テストをローカルで実行するには：

```sh
swift test                                    # macOS
xcodebuild test -scheme ARCraft \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
xcodebuild test -scheme ARCraft \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
```

## ロードマップ

- 2.0.0 リリースにタグを付け、パッケージを Swift Package Index に追加する。`.spi.yml` はすでにリポジトリにあります。
- `HandGestureRecognizer` を土台にした両手のジェスチャ（2 つのピンチの間での拡大縮小と回転）。
- 平面アンカーの範囲に基づく配置。検出されたテーブルの縁の内側にコンテンツを収めます。

## コントリビューション

コントリビューションを歓迎します。pull request を作成する前に[コントリビューションガイド](https://github.com/muhittincamdali/ARCraft/blob/main/CONTRIBUTING.md)と[行動規範](https://github.com/muhittincamdali/.github/blob/main/CODE_OF_CONDUCT.md)をお読みください。セキュリティ上の問題は[セキュリティポリシー](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md)に従って非公開で報告してください。

## ライセンス

MIT ライセンスで公開しています。詳細は [LICENSE](LICENSE) を参照してください。
