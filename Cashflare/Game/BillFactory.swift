import SpriteKit
import UIKit

enum BillFactory {
    static func makeBill(currency: Currency, size: CGSize = CGSize(width: 78, height: 40)) -> SKSpriteNode {
        let texture = renderBillTexture(currency: currency, size: size)
        let node = SKSpriteNode(texture: texture, size: size)
        node.name = "bill"
        node.zPosition = 20
        return node
    }

    private static func renderBillTexture(currency: Currency, size: CGSize) -> SKTexture {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let image = renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: size)
            let bg = UIColor(hex: currency.billColorHex)
            let accent = UIColor(hex: currency.accentHex)

            bg.setFill()
            UIBezierPath(roundedRect: rect, cornerRadius: 6).fill()

            accent.withAlphaComponent(0.35).setStroke()
            let inset = rect.insetBy(dx: 4, dy: 4)
            let border = UIBezierPath(roundedRect: inset, cornerRadius: 4)
            border.lineWidth = 1.5
            border.stroke()

            let symbol = currency.symbol as NSString
            let font = UIFont.systemFont(ofSize: size.height * 0.42, weight: .bold)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: accent
            ]
            let textSize = symbol.size(withAttributes: attrs)
            let textOrigin = CGPoint(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2
            )
            symbol.draw(at: textOrigin, withAttributes: attrs)
        }
        return SKTexture(image: image)
    }
}

extension UIColor {
    convenience init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)
        let r, g, b: UInt64
        switch cleaned.count {
        case 6:
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 1)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: 1
        )
    }
}
