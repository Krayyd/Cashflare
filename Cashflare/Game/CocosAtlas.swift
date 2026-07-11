import Foundation
import SpriteKit
import UIKit

/// Loads Cocos2d-x TexturePacker atlas (plist + png).
final class CocosAtlas {
    private let sheet: SKTexture
    private var frames: [String: SKTexture] = [:]

    init?(named atlasName: String, in subdirectory: String = "Resources/Atlas") {
        guard
            let pngURL = Bundle.main.url(forResource: atlasName, withExtension: "png", subdirectory: subdirectory),
            let plistURL = Bundle.main.url(forResource: atlasName, withExtension: "plist", subdirectory: subdirectory),
            let image = UIImage(contentsOfFile: pngURL.path),
            let plist = NSDictionary(contentsOf: plistURL),
            let frameDict = plist["frames"] as? [String: [String: Any]]
        else { return nil }

        sheet = SKTexture(image: image)
        let sheetSize = image.size

        for (name, info) in frameDict {
            guard
                let rectString = info["textureRect"] as? String,
                let sizeString = info["spriteSize"] as? String
            else { continue }

            let rotated = (info["textureRotated"] as? Bool) ?? false
            guard let texRect = Self.parseRect(rectString),
                  let spriteSize = Self.parseSize(sizeString)
            else { continue }

            // Cocos: origin top-left. SpriteKit texture rect: origin bottom-left, unit coords.
            var pixelRect = texRect
            if rotated {
                // When rotated, textureRect width/height are swapped in the sheet.
                pixelRect = CGRect(x: texRect.origin.x, y: texRect.origin.y, width: texRect.height, height: texRect.width)
            }

            let unit = CGRect(
                x: pixelRect.origin.x / sheetSize.width,
                y: 1.0 - (pixelRect.origin.y + pixelRect.height) / sheetSize.height,
                width: pixelRect.width / sheetSize.width,
                height: pixelRect.height / sheetSize.height
            )

            var texture = SKTexture(rect: unit, in: sheet)
            texture.filteringMode = .linear
            if rotated {
                // Consumer should rotate node 90°; store metadata via userData on demand.
            }
            frames[name] = texture
            // Also store without path quirks
            frames[name.replacingOccurrences(of: ".png", with: "")] = texture
        }

        // Keep sprite sizes for layout
        self.spriteSizes = frameDict.reduce(into: [:]) { result, pair in
            if let sizeString = pair.value["spriteSize"] as? String,
               let size = Self.parseSize(sizeString) {
                result[pair.key] = size
                result[pair.key.replacingOccurrences(of: ".png", with: "")] = size
            }
        }
        self.rotatedFlags = frameDict.reduce(into: [:]) { result, pair in
            let flag = (pair.value["textureRotated"] as? Bool) ?? false
            result[pair.key] = flag
            result[pair.key.replacingOccurrences(of: ".png", with: "")] = flag
        }
    }

    private(set) var spriteSizes: [String: CGSize] = [:]
    private(set) var rotatedFlags: [String: Bool] = [:]

    func texture(_ name: String) -> SKTexture? {
        frames[name] ?? frames[name + ".png"]
    }

    func node(_ name: String, scale: CGFloat = 0.5) -> SKSpriteNode? {
        guard let tex = texture(name) else { return nil }
        let size = spriteSizes[name] ?? spriteSizes[name + ".png"] ?? tex.size()
        let node = SKSpriteNode(texture: tex, size: CGSize(width: size.width * scale, height: size.height * scale))
        if rotatedFlags[name] == true || rotatedFlags[name + ".png"] == true {
            node.zRotation = -.pi / 2
            // After rotation, swap display size for layout comfort
            node.size = CGSize(width: node.size.height, height: node.size.width)
        }
        return node
    }

    private static func parseRect(_ raw: String) -> CGRect? {
        // {{x,y},{w,h}}
        let cleaned = raw
            .replacingOccurrences(of: "{", with: "")
            .replacingOccurrences(of: "}", with: "")
        let parts = cleaned.split(separator: ",").compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
        guard parts.count == 4 else { return nil }
        return CGRect(x: parts[0], y: parts[1], width: parts[2], height: parts[3])
    }

    private static func parseSize(_ raw: String) -> CGSize? {
        let cleaned = raw
            .replacingOccurrences(of: "{", with: "")
            .replacingOccurrences(of: "}", with: "")
        let parts = cleaned.split(separator: ",").compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
        guard parts.count == 2 else { return nil }
        return CGSize(width: parts[0], height: parts[1])
    }
}
