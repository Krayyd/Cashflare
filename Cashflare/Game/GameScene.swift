import SpriteKit
import UIKit

final class GameScene: SKScene {
    var gameState: GameState!

    private var atlas: CocosAtlas?
    private let world = SKNode()
    private let hud = SKNode()
    private let shopLayer = SKNode()

    private var cashLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private var rateLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
    private var deckNode: SKSpriteNode?
    private var upPanel: SKSpriteNode?
    private var downPanel: SKSpriteNode?

    private var lastUpdate: TimeInterval = 0
    private var currentBillImage: String = ""

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.45, green: 0.72, blue: 0.78, alpha: 1) // matches bill50 tint vibe
        atlas = CocosAtlas(named: "atlas0")
        addChild(world)
        addChild(hud)
        addChild(shopLayer)
        shopLayer.zPosition = 200
        shopLayer.isHidden = true

        buildBackground()
        buildHUD()
        rebuildDeck()
        layoutAll()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        layoutAll()
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdate == 0 { lastUpdate = currentTime }
        let dt = currentTime - lastUpdate
        lastUpdate = currentTime
        gameState.tickPassive(delta: dt)
        refreshLabels()
        if gameState.activeBill.image != currentBillImage {
            rebuildDeck()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let nodes = nodes(at: loc)

        if !shopLayer.isHidden {
            handleShopTouch(at: loc, nodes: nodes)
            return
        }

        if nodes.contains(where: { $0.name?.hasPrefix("tab_") == true }) {
            if let tab = nodes.first(where: { $0.name?.hasPrefix("tab_") == true })?.name {
                let n = Int(tab.replacingOccurrences(of: "tab_", with: "")) ?? 0
                openShop(tab: n)
                gameState.playClick()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            return
        }

        // Main throw — anywhere except bottom panel chrome
        throwBill(at: loc)
    }

    private func throwBill(at point: CGPoint) {
        gameState.tapThrow()
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()

        let def = gameState.activeBill
        let bill = BillFactory.billNode(def: def, width: min(size.width * 0.42, 190))
        let origin = deckNode?.position ?? CGPoint(x: size.width / 2, y: size.height * 0.28)
        bill.position = origin
        bill.zRotation = CGFloat.random(in: -0.15...0.15)
        bill.setScale(0.92)
        world.addChild(bill)

        let dx = CGFloat.random(in: -120...120)
        let dy = CGFloat.random(in: 260...480)
        let end = CGPoint(x: origin.x + dx, y: origin.y + dy)
        let move = SKAction.move(to: end, duration: 0.55)
        move.timingMode = .easeOut
        let spin = SKAction.rotate(byAngle: CGFloat.random(in: -1.4...1.4), duration: 0.55)
        let fade = SKAction.sequence([.wait(forDuration: 0.2), .fadeOut(withDuration: 0.4)])
        bill.run(.sequence([.group([move, spin, fade]), .removeFromParent()]))

        let popup = SKLabelNode(fontNamed: "AvenirNext-Bold")
        popup.text = "+\(GameState.compact(gameState.moneyPerClick))"
        popup.fontSize = 20
        popup.fontColor = .white
        popup.position = CGPoint(x: point.x, y: point.y + 24)
        popup.zPosition = 80
        hud.addChild(popup)
        popup.run(.sequence([
            .group([.moveBy(x: 0, y: 55, duration: 0.5), .fadeOut(withDuration: 0.5)]),
            .removeFromParent()
        ]))

        refreshLabels()
    }

    private func buildBackground() {
        // Soft desk gradient feel
        let desk = SKSpriteNode(color: SKColor(red: 0.55, green: 0.38, blue: 0.28, alpha: 1), size: CGSize(width: 10, height: 10))
        desk.name = "desk"
        desk.zPosition = 1
        world.addChild(desk)

        if let board = atlas?.node("board.png", scale: 0.55) {
            board.name = "board"
            board.zPosition = 2
            world.addChild(board)
        }
    }

    private func buildHUD() {
        let up = SKShapeNode(rectOf: CGSize(width: 320, height: 72), cornerRadius: 16)
        up.fillColor = SKColor(red: 0.10, green: 0.12, blue: 0.14, alpha: 0.92)
        up.strokeColor = SKColor(white: 1, alpha: 0.1)
        up.name = "up_panel"
        up.zPosition = 100
        hud.addChild(up)
        // Keep a sprite-sized proxy for layout via empty sprite
        let upProxy = SKSpriteNode(color: .clear, size: CGSize(width: 320, height: 72))
        upProxy.name = "up_panel_proxy"
        upProxy.zPosition = 99
        hud.addChild(upProxy)
        upPanel = upProxy

        cashLabel.fontSize = 28
        cashLabel.fontColor = .white
        cashLabel.horizontalAlignmentMode = .center
        cashLabel.verticalAlignmentMode = .center
        cashLabel.zPosition = 110
        hud.addChild(cashLabel)

        rateLabel.fontSize = 13
        rateLabel.fontColor = SKColor(white: 1, alpha: 0.85)
        rateLabel.horizontalAlignmentMode = .center
        rateLabel.verticalAlignmentMode = .center
        rateLabel.zPosition = 110
        hud.addChild(rateLabel)

        let down = SKShapeNode(rectOf: CGSize(width: 340, height: 78), cornerRadius: 18)
        down.fillColor = SKColor(red: 0.10, green: 0.12, blue: 0.14, alpha: 0.95)
        down.strokeColor = SKColor(white: 1, alpha: 0.1)
        down.name = "down_panel_shape"
        down.zPosition = 100
        hud.addChild(down)

        let downProxy = SKSpriteNode(color: .clear, size: CGSize(width: 340, height: 78))
        downProxy.name = "down_panel"
        downProxy.zPosition = 99
        hud.addChild(downProxy)
        downPanel = downProxy

        for i in [1, 3] {
            let name = "section\(i)_btn.png"
            if let btn = atlas?.node(name, scale: 0.42) {
                btn.name = "tab_\(i)"
                btn.zPosition = 105
                hud.addChild(btn)
            } else {
                let btn = SKLabelNode(fontNamed: "AvenirNext-Bold")
                btn.text = i == 1 ? "$$$/s" : "TAP"
                btn.name = "tab_\(i)"
                btn.fontSize = 14
                btn.fontColor = .white
                btn.zPosition = 105
                hud.addChild(btn)
            }
        }

        if let s4 = atlas?.node("section4_btn.png", scale: 0.42) {
            s4.name = "tab_4"
            s4.zPosition = 105
            s4.alpha = 0.85
            hud.addChild(s4)
        }
    }

    private func rebuildDeck() {
        deckNode?.removeFromParent()
        let def = gameState.activeBill
        currentBillImage = def.image
        let deck = BillFactory.deckNode(def: def, width: min(size.width * 0.55, 220))
        // Prefer bill face as the stack top for recognizability
        if let face = BillFactory.texture(named: def.image) {
            let aspect = face.size().height / max(face.size().width, 1)
            let w = min(size.width * 0.58, 240)
            deck.texture = face
            deck.size = CGSize(width: w, height: w * aspect)
        }
        deck.zPosition = 20
        world.addChild(deck)
        deckNode = deck
        layoutAll()
    }

    private func layoutAll() {
        let w = size.width
        let h = size.height
        let bottom = (view?.safeAreaInsets.bottom ?? 16) + 8
        let top = h - ((view?.safeAreaInsets.top ?? 20) + 8)

        if let desk = world.childNode(withName: "desk") as? SKSpriteNode {
            desk.size = CGSize(width: w, height: h * 0.55)
            desk.position = CGPoint(x: w / 2, y: h * 0.28)
        }
        if let board = world.childNode(withName: "board") as? SKSpriteNode {
            board.position = CGPoint(x: w / 2, y: h * 0.34)
        }

        upPanel?.position = CGPoint(x: w / 2, y: top - 36)
        upPanel?.size = CGSize(width: w * 0.92, height: 72)
        if let shape = hud.childNode(withName: "up_panel") as? SKShapeNode {
            shape.path = CGPath(roundedRect: CGRect(x: -w * 0.46, y: -36, width: w * 0.92, height: 72), cornerWidth: 16, cornerHeight: 16, transform: nil)
            shape.position = upPanel?.position ?? .zero
        }
        cashLabel.position = CGPoint(x: w / 2, y: top - 28)
        rateLabel.position = CGPoint(x: w / 2, y: top - 52)

        downPanel?.position = CGPoint(x: w / 2, y: bottom + 40)
        downPanel?.size = CGSize(width: w * 0.96, height: 78)
        if let shape = hud.childNode(withName: "down_panel_shape") as? SKShapeNode {
            shape.path = CGPath(roundedRect: CGRect(x: -w * 0.48, y: -39, width: w * 0.96, height: 78), cornerWidth: 18, cornerHeight: 18, transform: nil)
            shape.position = downPanel?.position ?? .zero
        }

        let tabY = bottom + 40
        let xs: [CGFloat] = [0.2, 0.5, 0.8]
        let tabs = ["tab_1", "tab_3", "tab_4"]
        for (idx, name) in tabs.enumerated() {
            hud.childNode(withName: name)?.position = CGPoint(x: w * xs[idx], y: tabY)
        }

        deckNode?.position = CGPoint(x: w / 2, y: h * 0.30)
    }

    private func refreshLabels() {
        cashLabel.text = gameState.format(gameState.cash)
        let click = gameState.format(gameState.moneyPerClick) + "/tap"
        let mps = gameState.format(gameState.moneyPerSecond) + "/s"
        rateLabel.text = "\(click)   ·   \(mps)"
    }

    // MARK: - Shop

    private func openShop(tab: Int) {
        gameState.shopTab = tab
        shopLayer.removeAllChildren()
        shopLayer.isHidden = false

        let dim = SKSpriteNode(color: SKColor(white: 0, alpha: 0.55), size: size)
        dim.anchorPoint = .zero
        dim.position = .zero
        dim.name = "shop_dim"
        dim.zPosition = 0
        shopLayer.addChild(dim)

        let panelH = size.height * 0.62
        let panel = SKShapeNode(rectOf: CGSize(width: size.width * 0.94, height: panelH), cornerRadius: 18)
        panel.fillColor = SKColor(red: 0.12, green: 0.14, blue: 0.16, alpha: 0.97)
        panel.strokeColor = SKColor(white: 1, alpha: 0.12)
        panel.position = CGPoint(x: size.width / 2, y: size.height * 0.48)
        panel.name = "shop_panel"
        panel.zPosition = 1
        shopLayer.addChild(panel)

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = tab == 1 ? (gameState.strings["section1"] ?? "Investments") : (gameState.strings["section3"] ?? "Business")
        title.fontSize = 20
        title.fontColor = .white
        title.position = CGPoint(x: size.width / 2, y: panel.position.y + panelH / 2 - 36)
        title.zPosition = 2
        shopLayer.addChild(title)

        let close = SKLabelNode(fontNamed: "AvenirNext-Bold")
        close.text = "✕"
        close.name = "shop_close"
        close.fontSize = 22
        close.fontColor = .white
        close.position = CGPoint(x: size.width * 0.88, y: title.position.y)
        close.zPosition = 2
        shopLayer.addChild(close)

        let items = tab == 1 ? gameState.passiveItems : gameState.clickItems
        let startY = title.position.y - 50
        for (idx, item) in items.prefix(10).enumerated() {
            addShopRow(item: item, index: idx, y: startY - CGFloat(idx) * 58)
        }
    }

    private func addShopRow(item: ShopItemDef, index: Int, y: CGFloat) {
        let row = SKNode()
        row.name = "shop_row_\(item.id)"
        row.position = CGPoint(x: size.width / 2, y: y)
        row.zPosition = 2
        shopLayer.addChild(row)

        let bg = SKShapeNode(rectOf: CGSize(width: size.width * 0.86, height: 52), cornerRadius: 10)
        bg.fillColor = SKColor(white: 1, alpha: 0.06)
        bg.strokeColor = .clear
        bg.name = "buy_\(item.id)"
        row.addChild(bg)

        if let icon = atlas?.node(item.icon, scale: 0.35) {
            icon.position = CGPoint(x: -size.width * 0.33, y: 0)
            icon.name = "buy_\(item.id)"
            row.addChild(icon)
        }

        let unlocked = gameState.isUnlocked(item)
        let lv = gameState.level(of: item.id)
        let name = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        name.text = gameState.title(for: item)
        name.fontSize = 13
        name.fontColor = unlocked ? .white : SKColor(white: 1, alpha: 0.35)
        name.horizontalAlignmentMode = .left
        name.position = CGPoint(x: -size.width * 0.22, y: 6)
        name.name = "buy_\(item.id)"
        row.addChild(name)

        let meta = SKLabelNode(fontNamed: "AvenirNext-Medium")
        if item.moneyPerClick > 0 {
            meta.text = "Lv\(lv)/\(item.maxLevel)  ·  +\(GameState.compact(item.moneyPerClick))/tap"
        } else {
            meta.text = "Lv\(lv)  ·  +\(GameState.compact(item.moneyPerSecond))/s"
        }
        meta.fontSize = 11
        meta.fontColor = SKColor(white: 1, alpha: 0.7)
        meta.horizontalAlignmentMode = .left
        meta.position = CGPoint(x: -size.width * 0.22, y: -12)
        meta.name = "buy_\(item.id)"
        row.addChild(meta)

        let price = SKLabelNode(fontNamed: "AvenirNext-Bold")
        if !unlocked {
            price.text = "🔒"
        } else if lv >= item.maxLevel {
            price.text = "MAX"
        } else {
            price.text = gameState.format(gameState.cost(for: item))
        }
        price.fontSize = 13
        price.fontColor = gameState.canBuy(item) ? SKColor(red: 0.45, green: 0.95, blue: 0.55, alpha: 1) : SKColor(white: 1, alpha: 0.45)
        price.horizontalAlignmentMode = .right
        price.position = CGPoint(x: size.width * 0.36, y: -5)
        price.name = "buy_\(item.id)"
        row.addChild(price)
    }

    private func handleShopTouch(at loc: CGPoint, nodes: [SKNode]) {
        if nodes.contains(where: { $0.name == "shop_close" || $0.name == "shop_dim" }) {
            shopLayer.isHidden = true
            shopLayer.removeAllChildren()
            gameState.shopTab = 0
            gameState.playClick()
            return
        }
        if let buy = nodes.compactMap(\.name).first(where: { $0.hasPrefix("buy_") }) {
            let id = String(buy.dropFirst(4))
            let items = gameState.shopTab == 1 ? gameState.passiveItems : gameState.clickItems
            if let item = items.first(where: { $0.id == id }) {
                if gameState.buy(item) {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    openShop(tab: gameState.shopTab) // refresh rows
                } else {
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            }
        }
    }
}
