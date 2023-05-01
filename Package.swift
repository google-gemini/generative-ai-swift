// swift-tools-version: 5.8

// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import PackageDescription

let package = Package(
  name: "GoogleGenerativeAI",
  platforms: [.iOS(.v16), .macOS(.v13), .watchOS(.v8), .tvOS(.v15)],
  products: [
    .library(
      name: "GoogleGenerativeAI",
      targets: ["GoogleGenerativeAI"]),
  ],
  dependencies: [
    .package(url: "https://github.com/kean/Get", from: "2.0.0"),
    .package(url: "https://github.com/CreateAPI/URLQueryEncoder", from: "0.2.0"),
  ],
  targets: [
    .target(
      name: "GoogleGenerativeAI",
      dependencies: [
        .product(name: "Get", package: "Get"),
        .product(name: "URLQueryEncoder", package: "URLQueryEncoder"),
      ],
      path: "Sources"
    ),
    .testTarget(
      name: "GoogleGenerativeAITests",
      dependencies: ["GoogleGenerativeAI"]),
    .binaryTarget(
      name: "create-api",
      url: "https://github.com/CreateAPI/CreateAPI/releases/download/0.1.1/create-api.artifactbundle.zip",
      checksum: "0f0cfe7300580ef3062aacf4c4936d942f5a24ab971e722566f937fa7714369a"
    ),
    .plugin(
      name: "CreateAPI",
      capability: .command(
        intent: .custom(
          verb: "generate-api",
          description: "Generates the OpenAPI entities and paths using CreateAPI"
        ),
        permissions: [
          .writeToPackageDirectory(reason: "To output the generated source code")
        ]
      ),
      dependencies: [
        .target(name: "create-api")
      ]
    )
  ]
)
