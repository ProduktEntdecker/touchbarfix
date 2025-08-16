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
            path: "Sources",
            resources: [
                .copy("../Resources/Info.plist"),
                .copy("../Resources/TouchBarRestarter.entitlements")
            ],
            swiftSettings: [
                // SECURITY: Removed unsafe flags that suppress warnings
                // All security warnings must be visible for proper auditing
            ]
        ),
        .testTarget(
            name: "TouchBarRestarterTests",
            dependencies: ["TouchBarRestarter"],
            path: "Tests"
        )
    ]
)
