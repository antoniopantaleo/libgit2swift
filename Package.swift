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
        .package(url: "https://github.com/apple/swift-log.git", from: "1.14.0")
    ],
    targets: [
        .systemLibrary(
            name: "libgit2",
            path: "Sources/libgit2",
            pkgConfig: "libgit2",
            providers: [
                .brew(["libgit2"])
            ]
        ),
        .target(
            name: "Git",
            dependencies: [
                "libgit2",
                .product(name: "Logging", package: "swift-log")
            ],
            cSettings: [
                .unsafeFlags(["-I/opt/homebrew/include", "-I/opt/homebrew/opt/libgit2/include"], .when(platforms: [.macOS]))
            ],
            linkerSettings: [
                .linkedLibrary("git2"),
                .unsafeFlags(["-L/opt/homebrew/lib"], .when(platforms: [.macOS]))
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
