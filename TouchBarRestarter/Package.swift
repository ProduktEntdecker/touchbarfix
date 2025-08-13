// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TouchBarRestarter",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "TouchBarRestarter",
            targets: ["TouchBarRestarter"]
        )
    ],
    dependencies: [
        // Add dependencies here as needed
    ],
    targets: [
        .executableTarget(
            name: "TouchBarRestarter",
            dependencies: [],
            path: "Sources"
        )
    ]
)
