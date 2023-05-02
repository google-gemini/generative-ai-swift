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

import SwiftUI

struct RoundedCorner: Shape {
  var radius: CGFloat = .infinity
  var corners: UIRectCorner = .allCorners
  
  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    return Path(path.cgPath)
  }
}

extension View {
  func roundedCorner(_ radius: CGFloat, corners: UIRectCorner) -> some View {
    clipShape(RoundedCorner(radius: radius, corners: corners) )
  }
}

struct MessageContentView: View {
  var message: ChatMessage
  
  var body: some View {
    if message.pending {
      BouncingDots()
    }
    else {
      Text(message.message)
    }
  }
}

struct MessageView: View {
  var message: ChatMessage

  var body: some View {
    HStack {
      if message.participant == .user {
        Spacer()
      }
      MessageContentView(message: message)
        .padding(10)
        .background(.blue)
        .foregroundColor(.white)
        .roundedCorner(10,
                       corners: [
                        .topLeft,
                        .topRight,
                        message.participant == .system ? .bottomRight : .bottomLeft
                       ])
      if message.participant == .system {
        Spacer()
      }
    }
    .listRowSeparator(.hidden)
  }
}

struct MessageView_Previews: PreviewProvider {
  static var previews: some View {
    List {
      MessageView(message: ChatMessage.sample)
      MessageView(message: ChatMessage(message: "Hello!", participant: .system, pending: true))
    }
  }
}
