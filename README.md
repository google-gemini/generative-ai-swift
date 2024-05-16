[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fgoogle-gemini%2Fgenerative-ai-swift%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/google-gemini/generative-ai-swift)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fgoogle-gemini%2Fgenerative-ai-swift%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/google-gemini/generative-ai-swift)

# Google AI SDK for Swift

> [!CAUTION]
> **The Google AI SDK for Swift is recommended for prototyping only.** If you plan to enable
> billing, we strongly recommend that you use a backend SDK to access the Google AI Gemini API. You
> risk potentially exposing your API key to malicious actors if you embed your API key directly in
> your Swift app or fetch it remotely at runtime.

The Google AI SDK for Swift enables developers to use Google's state-of-the-art generative AI models
(like Gemini) to build AI-powered features and applications. This SDK supports use cases like:
- Generate text from text-only input
- Generate text from text-and-images input (multimodal)
- Build multi-turn conversations (chat)

For example, with just a few lines of code, you can access Gemini's multimodal capabilities to
generate text from text-and-image input:

```swift
let model = GenerativeModel(name: "gemini-1.5-flash-latest", apiKey: "YOUR_API_KEY")
let cookieImage = UIImage(...)
let prompt = "Do these look store-bought or homemade?"

let response = try await model.generateContent(prompt, cookieImage)
```

## Try out the sample Swift app

This repository contains a sample app demonstrating how the SDK can access and utilize the Gemini
model for various use cases.

To try out the sample app, follow these steps:

1.  Check out this repository.\
`git clone https://github.com/google/generative-ai-swift`

1.  [Obtain an API key](https://makersuite.google.com/app/apikey) to use with the Google AI SDKs.

1.  Open and build the sample app in the `Examples` folder of this repo.

1. Run the app once to ensure the build script generates an empty `GenerativeAI-Info.plist` file

1.  Paste your API key into the `API_KEY` property in the `GenerativeAI-Info.plist` file.

1.  Run the app.

## Use the SDK in your app

Add [`generative-ai-swift`](https://github.com/google/generative-ai-swift) to your Xcode project
using Swift Package Manager.

For detailed instructions, you can find a
[quickstart](https://ai.google.dev/tutorials/swift_quickstart) for the Google AI SDK for Swift in the
Google documentation.

This quickstart describes how to add your API key and the Swift package to your app, initialize the
model, and then call the API to access the model. It also describes some additional use cases and
features, like streaming, counting tokens, and controlling responses.

## Logging

To enable additional logging in the Xcode console, including a cURL command and raw stream
response for each model request, add `-GoogleGenerativeAIDebugLogEnabled` as
`Arguments Passed On Launch` in the Xcode scheme.

## Command Line Tool

A command line tool is available to experiment with Gemini model requests via Xcode or the command
line:

1. `open Examples/GenerativeAICLI/Package.swift`
1. Run in Xcode and examine the console to see the options.
1. Edit the scheme's `Arguments Passed On Launch` with the desired options.

## Documentation

Find complete documentation for the Google AI SDKs and the Gemini model in the Google
documentation: https://ai.google.dev/docs

## Contributing

See [Contributing](https://github.com/google/generative-ai-swift/blob/main/docs/CONTRIBUTING.md)
for more information on
contributing to the Google AI SDK for Swift.


## Developers who use the PaLM SDK for Swift (Deprecated)

> [!IMPORTANT]
> The PaLM API is deprecated for use with Google AI services and tools (but _not_ for Vertex AI).
> Learn more about this deprecation, its timeline, and how to migrate to use Gemini in the
> [PaLM API deprecation guide](http://ai.google.dev/palm_docs/deprecation).

​​If you're using the PaLM SDK for Swift, review the information below to continue using the
**deprecated** PaLM SDK until you've migrated to the new version that allows you to use Gemini.

- To continue using PaLM models, make sure your app depends on version
[`0.3.0`](https://github.com/google/generative-ai-swift/releases/tag/0.3.0)
_up to_ the next minor version
([`0.4.0`](https://github.com/google/generative-ai-swift/releases/tag/0.4.0))
of `generative-ai-swift`.

- When you're ready to use Gemini models, migrate your code to the Gemini API and update your app's
`generative-ai-swift` dependency to version `0.4.0` or higher.

To see the PaLM documentation and code, go to the
[`palm` branch](https://github.com/google/generative-ai-swift/tree/palm).
