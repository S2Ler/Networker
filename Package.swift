// swift-tools-version:5.3

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
      ],
      swiftSettings: [
        .unsafeFlags([
          "-Xfrontend",
          "-enable-experimental-concurrency"
        ])
      ]
    ),
    .testTarget(
      name: "NetworkerTests",
      dependencies: ["Networker"],
      swiftSettings: [
        .unsafeFlags([
          "-Xfrontend",
          "-enable-experimental-concurrency"
        ])
      ]
    ),
  ]
)
