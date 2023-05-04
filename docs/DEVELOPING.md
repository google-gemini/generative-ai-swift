# Developing

## Re-generating the API
All code in the [OpenAPI](../Sources/OpenAPI) is generated based on the API specification in [palm-v1beta2.json](../Sources/palm-v1beta2.json).

To re-generate the API based on any changes to the API, follow these steps:

* Obtain the API discovery document from https://generativelanguage.googleapis.com/$discovery/rest?version=v1beta2&key=$YOUR_API_KEY
* Convert the discovery document to OpenAPI 3.0 (Swagger) format
    * https://github.com/APIs-guru/google-discovery-to-swagger
    * https://github.com/LucyBot-Inc/api-spec-converter
* Use [CreateAPI](https://github.com/CreateAPI/CreateAPI) to generate helper classes for accessing the API
* Manually write the API surface ([protocol](../Sources/GoogleGenerativeAI/GenerativeLanguageProtocol.swift) / [implementation)](../Sources/GoogleGenerativeAI/GenerativeLanguage.swift) and [REST routes for the API client](../Sources/GoogleGenerativeAI/Endpoints.swift) to access the API using the generated helper classes
