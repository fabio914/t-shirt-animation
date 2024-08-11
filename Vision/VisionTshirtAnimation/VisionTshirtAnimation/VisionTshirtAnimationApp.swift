//
//  VisionTshirtAnimationApp.swift
//  VisionTshirtAnimation
//
//  Created by Fabio Dela Antonio on 16/07/2024.
//

import SwiftUI

@main
struct VisionTshirtAnimationApp: App {
    @Environment(\.dismissWindow) var dismissWindow

    var body: some Scene {
        WindowGroup(id: "menu-window") {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                .onAppear(perform: { dismissWindow(id: "menu-window") })
        }.immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
