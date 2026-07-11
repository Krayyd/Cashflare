import SwiftUI
import SpriteKit
import UIKit

@MainActor
final class GameSession: ObservableObject {
    let state = GameState()
    let scene: GameScene

    init() {
        let size = UIScreen.main.bounds.size
        scene = GameScene(size: size)
        scene.scaleMode = .resizeFill
        scene.gameState = state
    }
}

struct ContentView: View {
    @StateObject private var session = GameSession()

    var body: some View {
        SpriteView(scene: session.scene, options: [.allowsTransparency])
            .ignoresSafeArea()
            .background(Color(red: 0.07, green: 0.09, blue: 0.12))
            .statusBarHidden()
    }
}

#Preview {
    ContentView()
}
