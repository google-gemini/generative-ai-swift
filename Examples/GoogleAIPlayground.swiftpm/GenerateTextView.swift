import GoogleGenerativeAI
import SwiftUI

struct GenerateTextView: View {
  let model = GenerativeModel(
    name: "gemini-pro",
    // Enter your API key below; do not share or commit it.
    apiKey: "MY_API_KEY"
  )

  @State var text: String = ""
  @State var prompt: String = ""

  var body: some View {
    VStack {
      ScrollView {
        Text(text)
      }
      Spacer()
      HStack {
        TextField("Enter a prompt...", text: $prompt)
        Button("Send", systemImage: "arrow.up.circle.fill") {
          generateText()
        }.labelStyle(.iconOnly)
      }
    }.padding()
  }

  func generateText() {
    Task {
      do {
        let response = try await model.generateContent(prompt)
        guard let responseText = response.text else {
          text = "No text in response"
          return
        }
        text = responseText
      } catch {
        print(error)
        text = error.localizedDescription
      }
    }
  }
}
