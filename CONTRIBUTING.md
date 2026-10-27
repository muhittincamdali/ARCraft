# Contributing

Thanks for taking the time to improve ARCraft.

## Reporting bugs

Open an issue with:

- the type and the values you passed (for hand gestures, a recorded `HandPose` as JSON helps:
  `HandPose` is `Codable`),
- what you expected and what happened,
- the platform and OS version (device or simulator) and the Xcode version.

Do not attach recordings of real hands or room scans you do not want to make public.

## Pull requests

1. Fork the repository and branch from `main`.
2. Keep each pull request focused on one change.
3. Run the tests on macOS and on the simulators:

    ```sh
    swift test
    xcodebuild test -scheme ARCraft \
      -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
    xcodebuild test -scheme ARCraft \
      -destination 'platform=visionOS Simulator,name=Apple Vision Pro'
    ```

    The ARKit adapters only compile for visionOS, so run the visionOS tests when you touch
    `Sources/ARCraft/Platform/ARKit+ARCraft.swift`.

4. Add or update a test in `Tests/ARCraftTests` for every logic change. Code that accepts outside
   input (matrices, decoded data, configuration values, files) must reject or clamp NaN,
   infinite, negative and oversized values, with a test for each case.
5. If you change a README code sample, change the copy in
   `Examples/ARCraftLab/ARCraftLab/ReadmeSamples.swift` as well. That file is what gets compiled:
   by the example app, and by `swift test` through the symlink
   `Tests/ARCraftTests/ReadmeExamples.swift`. Build the app with:

    ```sh
    cd Examples/ARCraftLab
    xcodebuild build -scheme ARCraftLab -destination 'generic/platform=visionOS Simulator'
    xcodebuild build -scheme ARCraftLab -destination 'generic/platform=iOS Simulator'
    ```

6. If a change affects the example app's screens, regenerate the screenshots with
   `scripts/capture-example-screens.sh`.
7. `README.md` will get translations (`README.<language>.md`). Each one records the version of
   `README.md` it follows, and CI reports a translation that is behind. If you change
   `README.md` and cannot update the translations, say so in the pull request.

## Code style

- Follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).
- The package builds in the Swift 6 language mode; new code should not add warnings.
- Document public API with DocC comments (`///`); `xcodebuild docbuild` should report no warnings.
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/)
  (`feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `ci:`, `chore:`).

## License

By contributing you agree that your contributions are licensed under the MIT License.
