// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Libgit2Swift",
    products: [
        .library(
            name: "Libgit2Swift",
            targets: ["Libgit2Swift"]
        )
    ],
    targets: [
        .systemLibrary(
            name: "libgit2",
            pkgConfig: "libgit2",
            providers: [.brew(["libgit2"])]
        ),
        .target(
            name: "Libgit2Swift",
            dependencies: ["libgit2"]
        )
    ]
)