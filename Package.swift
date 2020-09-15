// swift-tools-version:5.2

import PackageDescription

let package = Package(
  name: "Networker",
  products: [
    .library(
      name: "Networker",
      targets: ["Networker"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-log.git", from: "1.4.0")
  ],
  targets: [
    .target(
      name: "Networker",
      dependencies: [
        .product(name: "Logging", package: "swift-log")
      ]
    ),
    .testTarget(
      name: "NetworkerTests",
      dependencies: ["Networker"]),
  ]
)
