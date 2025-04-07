// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWSignInWith3rd_Discord",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "WWSignInWith3rd_Discord", targets: ["WWSignInWith3rd_Discord"]),
    ],
    dependencies: [
        .package(url: "https://github.com/William-Weng/WWSignInWith3rd_Apple", .upToNextMinor(from: "1.1.4")),
        .package(url: "https://github.com/William-Weng/WWNetworking", .upToNextMinor(from: "1.7.6")),
    ],
    targets: [
        .target(name: "WWSignInWith3rd_Discord", dependencies: ["WWSignInWith3rd_Apple", "WWNetworking"], resources: [.process("Material/Media.xcassets"),.copy("Privacy")]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
