// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FunnyAlarm",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "FunnyAlarm",
            targets: ["FunnyAlarm"]
        ),
    ],
    targets: [
        .target(
            name: "FunnyAlarm",
            path: "FunnyAlarm"
        ),
    ]
)
