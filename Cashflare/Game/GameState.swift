import Foundation
import Combine
import AVFoundation

@MainActor
final class GameState: ObservableObject {
    @Published var cash: Double = 0
    @Published var shopTab: Int = 0 // 0 closed, 1 passive, 3 click
    @Published private(set) var levels: [String: Int] = [:]

    let bills: [BillDef]
    let passiveItems: [ShopItemDef]
    let clickItems: [ShopItemDef]
    let strings: [String: String]
    let currencySymbol: String = "₽"

    private let defaults = UserDefaults.standard
    private let cashKey = "cashflare.v2.cash"
    private let levelsKey = "cashflare.v2.levels"
    private let lastSeenKey = "cashflare.v2.lastSeen"

    private var moneyPlayer: AVAudioPlayer?
    private var clickPlayer: AVAudioPlayer?
    private var buyPlayer: AVAudioPlayer?

    init() {
        bills = GameData.loadBills(currencyFolder: "Ruble")
        let shop = GameData.loadShop(region: "Russia")
        passiveItems = shop.passive
        clickItems = shop.click
        strings = GameData.loadStrings(lang: "ru")
        load()
        prepareAudio()
        applyOfflineIncome()
    }

    var moneyPerClick: Double {
        var total = 1.0 // base tap like original starter
        for item in clickItems {
            let lv = levels[item.id, default: 0]
            guard lv > 0 else { continue }
            let multIndex = min(lv, item.moneyPerLevel.count) - 1
            let mult = item.moneyPerLevel[max(0, multIndex)]
            total += item.moneyPerClick * mult
        }
        // If no business bought yet, keep 1 per tap
        if clickItems.allSatisfy({ levels[$0.id, default: 0] == 0 }) {
            return 1
        }
        return total
    }

    var moneyPerSecond: Double {
        var total = 0.0
        for item in passiveItems {
            let lv = levels[item.id, default: 0]
            guard lv > 0 else { continue }
            total += item.moneyPerSecond * Double(lv)
        }
        return total
    }

    var activeBill: BillDef {
        let unlocked = bills.filter { cash >= $0.unlockAt }
        return unlocked.last ?? bills.first ?? BillDef(image: "bill50.jpg", side: "deck50.png", unlockAt: 0)
    }

    func title(for item: ShopItemDef) -> String {
        strings[item.titleKey] ?? item.titleKey
    }

    func level(of id: String) -> Int { levels[id, default: 0] }

    func cost(for item: ShopItemDef) -> Double {
        let lv = level(of: item.id)
        return item.baseCost * pow(item.costPerLevel, Double(lv))
    }

    func isUnlocked(_ item: ShopItemDef) -> Bool {
        guard let req = item.requireId else { return true }
        return level(of: req) >= item.requireLevel
    }

    func canBuy(_ item: ShopItemDef) -> Bool {
        guard isUnlocked(item) else { return false }
        guard level(of: item.id) < item.maxLevel else { return false }
        return cash >= cost(for: item)
    }

    @discardableResult
    func buy(_ item: ShopItemDef) -> Bool {
        guard canBuy(item) else { return false }
        cash -= cost(for: item)
        levels[item.id, default: 0] += 1
        buyPlayer?.play()
        save()
        objectWillChange.send()
        return true
    }

    func tapThrow() {
        cash += moneyPerClick
        moneyPlayer?.currentTime = 0
        moneyPlayer?.play()
        save()
    }

    func tickPassive(delta: TimeInterval) {
        guard moneyPerSecond > 0, delta > 0, delta < 2 else { return }
        cash += moneyPerSecond * delta
        save()
    }

    func format(_ value: Double) -> String {
        "\(currencySymbol)\(Self.compact(value))"
    }

    func playClick() { clickPlayer?.play() }

    private func prepareAudio() {
        moneyPlayer = player(name: "money", ext: "mp3", folder: "Resources/Sounds")
        clickPlayer = player(name: "click", ext: "mp3", folder: "Resources/Sounds")
        buyPlayer = player(name: "purchase", ext: "mp3", folder: "Resources/Sounds")
    }

    private func player(name: String, ext: String, folder: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: folder) else { return nil }
        let p = try? AVAudioPlayer(contentsOf: url)
        p?.prepareToPlay()
        return p
    }

    private func applyOfflineIncome() {
        let last = defaults.double(forKey: lastSeenKey)
        defer { defaults.set(Date().timeIntervalSince1970, forKey: lastSeenKey) }
        guard last > 0, moneyPerSecond > 0 else { return }
        let elapsed = min(Date().timeIntervalSince1970 - last, 8 * 3600)
        if elapsed > 5 {
            cash += moneyPerSecond * elapsed * 0.5
            save()
        }
    }

    private func load() {
        cash = defaults.double(forKey: cashKey)
        if let data = defaults.data(forKey: levelsKey),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            levels = decoded
        }
    }

    private func save() {
        defaults.set(cash, forKey: cashKey)
        if let data = try? JSONEncoder().encode(levels) {
            defaults.set(data, forKey: levelsKey)
        }
        defaults.set(Date().timeIntervalSince1970, forKey: lastSeenKey)
    }

    static func compact(_ value: Double) -> String {
        let a = abs(value)
        switch a {
        case 1e15...: return String(format: "%.2fQ", value / 1e15)
        case 1e12...: return String(format: "%.2fT", value / 1e12)
        case 1e9...: return String(format: "%.2fB", value / 1e9)
        case 1e6...: return String(format: "%.2fM", value / 1e6)
        case 1e4...: return String(format: "%.1fK", value / 1e3)
        case 100...: return String(format: "%.0f", value)
        default: return String(format: "%.0f", value)
        }
    }
}
