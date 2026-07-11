import SpriteKit
import UIKit

final class GameScene: SKScene {
    var gameState: GameState!

    private let cashLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let hintLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
    private let currencyButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let billUpgradeButton = SKShapeNode()
    private let businessUpgradeButton = SKShapeNode()
    private let billUpgradeLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private let businessUpgradeLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")

    private var lastUpdateTime: TimeInterval = 0
    private var hudNeedsRefresh = true

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.07, green: 0.09, blue: 0.12, alpha: 1)
        buildAtmosphere()
        buildHUD()
        refreshHUD()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        layoutHUD()
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        let delta = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        if delta > 0, delta < 1 {
            gameState.tickPassive(delta: delta)
        }
        if hudNeedsRefresh {
            refreshHUD()
            hudNeedsRefresh = false
        } else {
            cashLabel.text = gameState.formatCash()
            updateUpgradeAffordability()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let hitNames = Set(nodes(at: location).compactMap(\.name))

        if hitNames.contains("currencyButton") || currencyButton.calculateAccumulatedFrame().insetBy(dx: -12, dy: -12).contains(location) {
            gameState.cycleCurrency()
            hudNeedsRefresh = true
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            return
        }
        if hitNames.contains("billUpgrade") {
            if gameState.buyBillUpgrade() {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                pulse(billUpgradeButton)
            } else {
                shake(billUpgradeButton)
            }
            hudNeedsRefresh = true
            return
        }
        if hitNames.contains("businessUpgrade") {
            if gameState.buyBusinessUpgrade() {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                pulse(businessUpgradeButton)
            } else {
                shake(businessUpgradeButton)
            }
            hudNeedsRefresh = true
            return
        }

        throwBills(at: location)
    }

    private func throwBills(at point: CGPoint) {
        let count = 1 + min(4, gameState.billValueLevel / 3)
        gameState.throwBills(count: count)
        hudNeedsRefresh = true
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()

        for i in 0..<count {
            let bill = BillFactory.makeBill(currency: gameState.currency)
            let spread = CGFloat.random(in: -40...40)
            bill.position = CGPoint(x: point.x + spread * 0.2, y: max(120, point.y - 20))
            bill.zRotation = CGFloat.random(in: -0.35...0.35)
            bill.setScale(0.85)
            addChild(bill)

            let dx = CGFloat.random(in: -90...90) + spread
            let dy = CGFloat.random(in: 220...420)
            let end = CGPoint(x: bill.position.x + dx, y: bill.position.y + dy)
            let move = SKAction.move(to: end, duration: 0.55 + Double(i) * 0.04)
            move.timingMode = .easeOut
            let rotate = SKAction.rotate(byAngle: CGFloat.random(in: -1.2...1.2), duration: move.duration)
            let fade = SKAction.sequence([
                SKAction.wait(forDuration: 0.25),
                SKAction.fadeOut(withDuration: 0.4)
            ])
            let group = SKAction.group([move, rotate, fade])
            bill.run(SKAction.sequence([group, .removeFromParent()]))
        }

        spawnGainPopup(at: point, amount: gameState.billValue * Double(count))
    }

    private func spawnGainPopup(at point: CGPoint, amount: Double) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "+\(gameState.currency.symbol)\(GameState.compact(amount))"
        label.fontSize = 18
        label.fontColor = SKColor(white: 0.95, alpha: 1)
        label.position = CGPoint(x: point.x, y: point.y + 30)
        label.zPosition = 50
        addChild(label)
        label.run(.sequence([
            .group([
                .moveBy(x: 0, y: 50, duration: 0.55),
                .fadeOut(withDuration: 0.55)
            ]),
            .removeFromParent()
        ]))
    }

    private func buildAtmosphere() {
        let glow = SKShapeNode(circleOfRadius: 180)
        glow.fillColor = SKColor(red: 0.18, green: 0.55, blue: 0.42, alpha: 0.18)
        glow.strokeColor = .clear
        glow.position = CGPoint(x: size.width * 0.5, y: size.height * 0.55)
        glow.zPosition = 0
        glow.name = "glow"
        addChild(glow)
        glow.run(.repeatForever(.sequence([
            .scale(to: 1.12, duration: 2.4),
            .scale(to: 1.0, duration: 2.4)
        ])))

        hintLabel.text = "Tap to throw cash"
        hintLabel.fontSize = 15
        hintLabel.fontColor = SKColor(white: 1, alpha: 0.45)
        hintLabel.zPosition = 5
        addChild(hintLabel)
    }

    private func buildHUD() {
        cashLabel.fontSize = 34
        cashLabel.fontColor = .white
        cashLabel.horizontalAlignmentMode = .center
        cashLabel.verticalAlignmentMode = .center
        cashLabel.zPosition = 100
        addChild(cashLabel)

        currencyButton.fontSize = 18
        currencyButton.fontColor = SKColor(white: 0.92, alpha: 1)
        currencyButton.horizontalAlignmentMode = .right
        currencyButton.verticalAlignmentMode = .center
        currencyButton.zPosition = 100
        currencyButton.name = "currencyButton"
        addChild(currencyButton)

        configureUpgradeButton(billUpgradeButton, label: billUpgradeLabel, name: "billUpgrade")
        configureUpgradeButton(businessUpgradeButton, label: businessUpgradeLabel, name: "businessUpgrade")
        layoutHUD()
    }

    private func configureUpgradeButton(_ button: SKShapeNode, label: SKLabelNode, name: String) {
        button.name = name
        button.fillColor = SKColor(white: 0.14, alpha: 0.92)
        button.strokeColor = SKColor(white: 1, alpha: 0.12)
        button.lineWidth = 1
        button.zPosition = 100
        addChild(button)

        label.fontSize = 13
        label.fontColor = .white
        label.numberOfLines = 2
        label.preferredMaxLayoutWidth = 150
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.zPosition = 101
        addChild(label)
    }

    private func layoutHUD() {
        let top = size.height - 70
        cashLabel.position = CGPoint(x: size.width / 2, y: top)
        currencyButton.position = CGPoint(x: size.width - 24, y: top)
        hintLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.42)

        if let glow = childNode(withName: "glow") {
            glow.position = CGPoint(x: size.width * 0.5, y: size.height * 0.55)
        }

        let buttonSize = CGSize(width: min(170, size.width * 0.42), height: 64)
        let y = 56 + safeAreaBottom()
        let leftX = size.width * 0.28
        let rightX = size.width * 0.72

        billUpgradeButton.path = CGPath(
            roundedRect: CGRect(x: -buttonSize.width / 2, y: -buttonSize.height / 2, width: buttonSize.width, height: buttonSize.height),
            cornerWidth: 14,
            cornerHeight: 14,
            transform: nil
        )
        businessUpgradeButton.path = billUpgradeButton.path
        billUpgradeButton.position = CGPoint(x: leftX, y: y)
        businessUpgradeButton.position = CGPoint(x: rightX, y: y)
        billUpgradeLabel.position = billUpgradeButton.position
        businessUpgradeLabel.position = businessUpgradeButton.position
        billUpgradeLabel.preferredMaxLayoutWidth = buttonSize.width - 12
        businessUpgradeLabel.preferredMaxLayoutWidth = buttonSize.width - 12
    }

    private func safeAreaBottom() -> CGFloat {
        view?.safeAreaInsets.bottom ?? 20
    }

    private func refreshHUD() {
        cashLabel.text = gameState.formatCash()
        currencyButton.text = "\(gameState.currency.flag) \(gameState.currency.code)"
        billUpgradeLabel.text = "Bill value Lv\(gameState.billValueLevel)\n\(gameState.formatCash(gameState.billUpgradeCost))"
        let income = gameState.formatCash(gameState.businessIncomePerSecond) + "/s"
        businessUpgradeLabel.text = "Business Lv\(gameState.businessLevel)\n\(income) · \(gameState.formatCash(gameState.businessUpgradeCost))"
        updateUpgradeAffordability()
    }

    private func updateUpgradeAffordability() {
        billUpgradeButton.alpha = gameState.cash >= gameState.billUpgradeCost ? 1 : 0.55
        businessUpgradeButton.alpha = gameState.cash >= gameState.businessUpgradeCost ? 1 : 0.55
    }

    private func pulse(_ node: SKNode) {
        node.run(.sequence([
            .scale(to: 1.06, duration: 0.08),
            .scale(to: 1.0, duration: 0.1)
        ]))
    }

    private func shake(_ node: SKNode) {
        node.run(.sequence([
            .moveBy(x: -6, y: 0, duration: 0.04),
            .moveBy(x: 12, y: 0, duration: 0.06),
            .moveBy(x: -6, y: 0, duration: 0.04)
        ]))
    }
}
