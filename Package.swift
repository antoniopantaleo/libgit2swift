// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "Libgit2Swift",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "Git",
            targets: ["Git"]
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
            name: "Git",
            dependencies: [
                "libgit2",
                .product(name: "Logging", package: "swift-log")
            ]
        ),
        .testTarget(
            name: "GitTests",
            dependencies: [
                .target(name: "Git")
            ],
            resources: [
                .process("Git.xctestplan")
            ]
        )
    ]
)
