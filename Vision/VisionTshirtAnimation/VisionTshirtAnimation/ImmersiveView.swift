//
//  ImmersiveView.swift
//  VisionTshirtAnimation
//
//  Created by Fabio Dela Antonio on 16/07/2024.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    var body: some View {
        RealityView { content in

            let sceneManager = SceneManager()
            content.add(sceneManager.rootEntity)

            sceneManager.runSession()
        }
    }
}
