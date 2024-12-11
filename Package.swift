// swift-tools-version:5.10

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
            name: "Gemini",
            targets: [
                "Gemini",
                "GoogleGenerativeAI",
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/PreternaturalAI/AI.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Gemini",
            dependencies: [
                "AI"
            ],
            path: "Sources/GoogleAI"
        ),
        .target(
            name: "GoogleGenerativeAI",
            dependencies: [
                "Gemini"
            ],
            path: "Sources/GoogleGenerativeAI"
        ),
        .testTarget(
            name: "GeminiTests",
            dependencies: [
                "Gemini",
                "GoogleGenerativeAI",
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
