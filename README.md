# Google AI Swift SDK

> [!IMPORTANT]
> Thanks for your interest in the Google AI SDKs! **You can start using this SDK and its samples on December 13, 2023.** Until then, check out our [blog post](https://blog.google/technology/ai/google-gemini-ai/) to learn more about Google's Gemini multimodal model.

> [!IMPORTANT]
> If you are using the PaLM SDK for Swift, please see [Developers who use the PaLM SDK for Swift](#developers-who-use-the-palm-sdk-for-swift) for instructions.

The Google AI Swift SDK enables developers to use Google's state-of-the-art generative AI models
(like Gemini) to build AI-powered features and applications. This SDK supports use cases like:
- Generate text from text-only input
- Generate text from text-and-images input (multimodal)
- Build multi-turn conversations (chat)

For example, with just a few lines of code, you can access Gemini's multimodal capabilities to
generate text from text-and-image input:

```swift
let model = GenerativeModel(name: "gemini-pro-vision", apiKey: "YOUR_API_KEY")
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

## Contributing

See [Contributing](https://github.com/google/generative-ai-swift/blob/main/docs/CONTRIBUTING.md)
for more information on
contributing to the Google AI Swift SDK.


## Developers who use the PaLM SDK for Swift

​​If you're using the PaLM SDK for Swift, review the information below to continue
using the PaLM SDK until you've migrated to the new version that allows you to use Gemini.

- To continue using PaLM models, make sure your app depends on version
[`0.3.0`](https://github.com/google/generative-ai-swift/releases/tag/0.3.0)
_up to_ the next minor version
([`0.4.0`](https://github.com/google/generative-ai-swift/releases/tag/0.4.0))
of `generative-ai-swift`.

- When you're ready to use Gemini models, migrate your code to the Gemini API and update your app's
`generative-ai-swift` dependency to version `0.4.0` or higher.

To see the PaLM documentation and code, go to the
[`palm` branch](https://github.com/google/generative-ai-swift/tree/palm).
