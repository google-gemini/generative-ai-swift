# Google Generative AI SDK for Swift

The Google Generative AI SDK for Swift allows developers to use state-of-the-art Large Language Models (LLMs) to build language applications.

Once you've added the Swift package to your Swift application, you can call the API as follows:

```swift
import GoogleGenerativeAI
let palmClient = GenerativeLanguage(apiKey: "YOUR API KEY")
response = try await palmClient.chat(message: "Hello")
```

## Contributing

See [Contributing](docs/CONTRIBUTING.md) for more information on contributing to the Generative AI SDK for Swift.

## License

The contents of this repository are licensed under the
[Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0).
