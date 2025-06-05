// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "Libgit2Swift",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "Libgit2Swift",
            targets: ["Libgit2Swift"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.3")
    ],
    targets: [
        .systemLibrary(
            name: "libgit2",
            pkgConfig: "libgit2",
            providers: [
                .brew(
                    ["libgit2"]
                )
            ]
        ),
        .target(
            name: "Libgit2Swift",
            dependencies: [
                "libgit2",
                .product(name: "Logging", package: "swift-log")
            ]
        ),
        .testTarget(
            name: "Libgit2SwiftTests",
            dependencies: [
                .target(name: "Libgit2Swift")
            ],
            resources: [
                .process("Libgit2Swift.xctestplan")
            ]
        )
    ]
)
