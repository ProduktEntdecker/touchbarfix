// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TouchBarFix",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "TouchBarFix",
            targets: ["TouchBarFix"]
        )
    ],
    dependencies: [
        // Add dependencies here as needed
    ],
    targets: [
        .executableTarget(
            name: "TouchBarFix",
            dependencies: [],
            path: "Sources",
            resources: [
                .copy("../Resources/Info.plist"),
                .copy("../Resources/TouchBarFix.entitlements")
            ],
            swiftSettings: [
                // SECURITY: Removed unsafe flags that suppress warnings
                // All security warnings must be visible for proper auditing
            ]
        ),
        .testTarget(
            name: "TouchBarFixTests",
            dependencies: ["TouchBarFix"],
            path: "Tests"
        )
    ]
)
