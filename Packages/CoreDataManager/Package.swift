// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CoreDataManager",
    platforms: [
        .iOS(.v15),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "CoreDataManager",
            targets: ["CoreDataManager"]),
    ],
    targets: [
        .target(
            name: "CoreDataManager",
            path: "Sources/CoreDataManager",
            resources: [
                .process("ToDoSimple.xcdatamodeld")
            ]
        ),
        .testTarget(
            name: "CoreDataManagerTests",
            dependencies: ["CoreDataManager"]
        ),
    ],
    swiftLanguageModes: [.v5]
)
