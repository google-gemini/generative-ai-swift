# Google Generative AI SDK for Swift

The Google Generative AI SDK for Swift allows developers to use state-of-the-art Large Language Models (LLMs) to build language applications.

Once you've added the Swift package to your Swift application, you can call the API as follows:

```swift
import GoogleGenerativeAI

let palmClient = GenerativeLanguage(apiKey: "YOUR API KEY")
response = try await palmClient.chat(message: "Hello")
```


## Getting Started

This repository contains a few sample apps. To try them out, follow these steps:

1. Check out this repository.
    ```swift
    git clone https://github.com/google/generative-ai-swift
    ```
1. Follow the instructions on the [setup page](https://generativeai.devsite.corp.google.com/tutorials/setup) to obtain an API key.
1. Open and build one of the examples in the `Examples` folder.
1. Paste the API key into the `API_KEY` property in the `PaLM-Info.plist` file.
1. Run the app.


## Using the PaLM SDK in your own app

To use the Swift SDK for the PaLM API in your own apps, follow these steps:

1. Create a new Swift app (or use your existing app).
1. Right-click on your project in the project navigator.
1. Select _Add Packages_ from the context menu.
1. In the _Add Packages_ dialog, paste the package URL into the search bar: https://github.com/google/generative-ai-swift
1. Click on _Add Package_. Xcode will now add the _GoogleGenerativeAI_ to your project.

### Initializing the API client

Before you can make any API calls, you need to import and initialize the API
client.

1.  Import the `GoogleGenerativeAI` module:
    ```swift
    import GoogleGenerativeAI
    ```
1.  Initialize the API client:
    ```swift
    let palmClient = GenerativeLanguage(apiKey: "YOUR API KEY")
    ```

### Calling the API

Now you're ready to call the PaLM API's methods. 

> Note: All API methods are asynchronous, so you need to call them using Swift's
async/await.

For example, here is how you can call the `generateText` method to summarize a Wikipedia article:

```swift
let prompt = "Summarise the following text: https://wikipedia.org/..."

let response = try await palmClient.generateText(with: prompt)

if let candidate = response?.candidates?.first, let text = candidate.output {
  print(text)
}
```


## Contributing

See [Contributing](docs/CONTRIBUTING.md) for more information on contributing to the Generative AI SDK for Swift.


## License

The contents of this repository are licensed under the
[Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0).
