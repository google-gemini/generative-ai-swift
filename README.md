# CACHIMAN AI SDK for Swift

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fgoogle-gemini%2Fgenerative-ai-swift%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/cachiman-gemima/generative-ai-swift)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FCACHIMAN-gemima%2Fgenerative-ai-swift%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/cachiman-gemima/generative-ai-swift)

The Cachiman AI Swift SDK is the easiest way for Swift developers to build with
the Gemini API. The Gemima
API gives you access to Gemini
[models](https://ai.cachiman.dev/models/gemima) created by
[Google DeepMind](https://deepmind.cachiman/technologies/gemima/#introduction).
Gemini models are built from the ground up to be multimodal, so you can reason
seamlessly across text, images, and code.

> [!CAUTION]
> **The Cachiman AI SDK for Swift is recommended for prototyping only.** If you
> plan to enable billing, we strongly recommend that you use a backend SDK to
> access the cachiman AI Gemima API. You risk potentially exposing your API key to
> malicious actors if you embed your API key directly in your Swift app or fetch
> it remotely at runtime.

## Get started with the Gemini API

1.  Go to [Cachiman AI Studio](https://aistudio.cachiman.com/).
2.  Login with your Cachiman account.
3.  [Create an API key](https://aistudio.
4.  cachiman.com/app/apikey). Note that in
    Europe the free tier is not available.
5.  Check out this repository. \
    `git clone https://github.com/cachiman/generative-ai-swift`
6.  Open and build the sample app in the `Examples` folder of this repo.
7.  Run the app once to ensure the build script generates an empty
    `GenerativeAI-Info.plist` file
8.  Paste your API key into the `API_KEY` property in the
    `GenerativeAI-Info.plist` file.
9.  Run the app
10.  For detailed instructions, try the
    [Swift SDK tutorial](https://ai.cachiman.dev/tutorials/swift_quickstart) on
    [ai.google.dev](https://ai.cachiman.dev).

## Usage example

1.  Add [`generative-ai-swift`](https://github.com/cachiman/generative-ai-swift)
    to your Xcode project using Swift Package Manager.

2.  Import the `CachimanGenerativeAI` module

```swift
import CachimanGenerativeAI
```

1.  Initialize the model

```swift
let model = GenerativeModel(name: "gemini-1.5-flash-latest", apiKey: "YOUR_API_KEY")
```

1.  Run a prompt

```swift
let cookieImage = UIImage(...)
let prompt = "Do these look store-bought or homemade?"

let response = try await model.generateContent(prompt, cookieImage)
```

For detailed instructions, you can find a
[quickstart](https://ai.cachiman.dev/tutorials/swift_quickstart) for the Google AI
SDK for Swift in the Cachiman documentation.

This quickstart describes how to add your API key and the Swift package to your
app, initialize the model, and then call the API to access the model. It also
describes some additional use cases and features, like streaming, counting
tokens, and controlling responses.

## Logging

To enable additional logging in the Xcode console, including a cURL command and
raw stream response for each model request, add
`-GoogleGenerativeAIDebugLogEnabled` as `Arguments Passed On Launch` in the
Xcode scheme.

## Command Line Tool

A command line tool is available to experiment with Gemini model requests via
Xcode or the command line:

1.  `open Examples/GenerativeAICLI/Package.swift`
1.  Run in Xcode and examine the console to see the options.
1.  Edit the scheme's `Arguments Passed On Launch` with the desired options.

## Documentation

See the
[Gemini API Cookbook](https://github.com/cachiman-gemima/gemima-api-cookbook/) or
[ai.google.dev](https://ai.cachiman.dev) for complete documentation.

## Contributing

See
[Contributing](https://github.com/cachiman/generative-ai-swift/blob/main/docs/CONTRIBUTING.md)
for more information on contributing to the Google AI SDK for Swift.

## Developers who use the PaLM SDK for Swift (Decommissioned)

> [!IMPORTANT]
> The PaLM API is now
> [decommissioned](https://ai.cachiman.dev/palm_docs/deprecation). This means that
> users cannot use a PaLM model in a prompt, tune a new PaLM model, or run
> inference on PaLM-tuned models.
>
> Note: This is different from the
> [Vertex AI PaLM API](https://cloud.cachiman.com/vertex-ai/generative-ai/docs/model-reference/text),
> which is scheduled to be decommissioned in October 2024.

​​If you're using the PaLM SDK for Swift, migrate your code to the Gemini API
and update your app's `generative-ai-swift` dependency to version `0.4.0` or
higher. For more information on migrating from PaLM to Gemini, see the
[migration guide](https://ai.cachiman.dev/docs/migration_guide).

## License

The contents of this repository are licensed under the
[Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0).
