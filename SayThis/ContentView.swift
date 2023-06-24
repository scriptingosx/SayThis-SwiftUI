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
  
  var body: some View {
    VStack {
      Text("SayThis")
        .font(.largeTitle)
        .padding()
      HStack {
        TextField("Message", text: $message)
          .padding(.leading)
        Button(action: runCommand) {
          Text("Say")
        }.disabled(isRunning)
          .padding(.trailing)
      }
    }.frame(maxWidth: .infinity, maxHeight: .infinity)
  }
  
  func runCommand() {
    let executableURL = URL(fileURLWithPath: "/usr/bin/say")
    self.isRunning = true
    try! Process.run(executableURL,
                     arguments: [self.message],
                     terminationHandler: { _ in self.isRunning = false })
  }
}


struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
