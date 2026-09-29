// swift-tools-version: 6.0
import PackageDescription

/// Pure product logic for Gentle Walk. Foundation only — no SwiftUI, SwiftData, StoreKit or other
/// Apple frameworks, so everything here is testable with `swift test` in seconds.
let package = Package(
    name: "GentleWalkCore",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "GentleWalkCore", targets: ["GentleWalkCore"]),
    ],
    targets: [
        .target(name: "GentleWalkCore"),
        .testTarget(
            name: "GentleWalkCoreTests",
            dependencies: ["GentleWalkCore"],
            resources: [.copy("Fixtures")]
        ),
    ]
)
