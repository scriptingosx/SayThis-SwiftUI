//
//  ContentView.swift
//  SayThis
//
//  Created by Armin Briegel on 02.12.19.
//  Copyright © 2019 Scripting OS X. All rights reserved.
//

import SwiftUI

struct ContentView: View {
  @State var message = "Hello, World"
  @State var isRunning = false

  @State var voices: [String] = []
  @State var selectedVoice: String = "Samantha"

  var body: some View {
    VStack {
      Text("SayThis")
        .font(.largeTitle)
        .padding()
      Picker(selection: $selectedVoice, label: Text("Voice:")) {
//        Text("System Default").tag("System Default")
//        Divider()
        ForEach(voices, id: \.self) { Text($0) }
      }
      HStack {
        TextField("Message", text: $message)
        Button("Say") {
          runCommand()
        }
        .disabled(isRunning)
      }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .task {
      guard let (_, outData, _) = try? await Process.launch(
        path: "/usr/bin/say",
        arguments: ["-v", "?"]
      ) else { return }

      let output = String(data: outData, encoding: .utf8) ?? ""
      voices = parseVoices(output)
    }
  }

  func parseVoices(_ output: String) -> [String] {
    output
      .components(separatedBy: "\n")
      .map {
        $0
          .components(separatedBy: "#")
          .first?
          .trimmingCharacters(in: .whitespaces)
          .components(separatedBy: CharacterSet.whitespaces)
          .dropLast()
          .filter { !$0.isEmpty }
          .joined(separator: " ")
        ?? ""
      }
      .filter { !$0.isEmpty }
  }

  func runCommand() {
    var arguments = [message]
    if selectedVoice != "System Default" {
      arguments.append(contentsOf: ["-v", selectedVoice])
    }

    let executableURL = URL(fileURLWithPath: "/usr/bin/say")
    self.isRunning = true
    try! Process.run(executableURL,
                     arguments: arguments,
                     terminationHandler: { _ in self.isRunning = false })
  }

  func runCommandNew() async {
    var arguments = [message]
    if selectedVoice != "System Default" {
      arguments.append(contentsOf: ["-v", selectedVoice])
    }
    isRunning = true
    let _ = try? await Process.launch(path: "/usr/bin/say", arguments: arguments)
    isRunning = false
  }
}


struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
