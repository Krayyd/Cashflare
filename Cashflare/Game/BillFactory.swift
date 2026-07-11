import SpriteKit
import UIKit

enum BillFactory {
    static func texture(named file: String, folder: String = "Ruble") -> SKTexture? {
        let base = (file as NSString).deletingPathExtension
        let ext = (file as NSString).pathExtension
        guard let url = Bundle.main.url(forResource: base, withExtension: ext, subdirectory: "Resources/\(folder)"),
              let image = UIImage(contentsOfFile: url.path) else { return nil }
        let tex = SKTexture(image: image)
        tex.filteringMode = .linear
        return tex
    }

    static func billNode(def: BillDef, width: CGFloat = 160) -> SKSpriteNode {
        let tex = texture(named: def.image) ?? SKTexture()
        let aspect = tex.size().height / max(tex.size().width, 1)
        let node = SKSpriteNode(texture: tex, size: CGSize(width: width, height: width * aspect))
        node.name = "bill"
        node.zPosition = 30
        return node
    }

    static func deckNode(def: BillDef, width: CGFloat = 170) -> SKSpriteNode {
        let tex = texture(named: def.side) ?? texture(named: def.image)
        let size: CGSize
        if let tex {
            let aspect = tex.size().height / max(tex.size().width, 1)
            size = CGSize(width: width, height: width * aspect)
            let node = SKSpriteNode(texture: tex, size: size)
            node.name = "deck"
            node.zPosition = 25
            return node
        }
        let node = SKSpriteNode(color: .green, size: CGSize(width: width, height: width * 0.5))
        node.name = "deck"
        return node
    }
}
