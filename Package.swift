// swift-tools-version: 5.7.1
// swift-tools-version: 5.10

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
    name: "Gemini",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .macCatalyst(.v16),
    ],
    products: [
        .library(
            name: "GoogleGenerativeAI",
            targets: [
                "GoogleGenerativeAI"
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/PreternaturalAI/AI.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "GoogleGenerativeAI",
            dependencies: [
                "AI"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "GoogleGenerativeAITests",
            dependencies: [
                "GoogleGenerativeAI"
            ],
            path: "Tests",
            resources: [
                .process("GoogleAITests/CountTokenResponses"),
                .process("GoogleAITests/GenerateContentResponses"),
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
