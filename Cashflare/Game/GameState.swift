import Foundation
import Combine

@MainActor
final class GameState: ObservableObject {
    @Published var cash: Double = 0
    @Published var currency: Currency = .usd
    @Published var billValueLevel: Int = 1
    @Published var businessLevel: Int = 0

    private let defaults = UserDefaults.standard
    private let cashKey = "cashflare.cash"
    private let currencyKey = "cashflare.currency"
    private let billLevelKey = "cashflare.billLevel"
    private let businessLevelKey = "cashflare.businessLevel"
    private let lastSeenKey = "cashflare.lastSeen"

    var billValue: Double {
        1.0 * pow(1.35, Double(billValueLevel - 1))
    }

    var billUpgradeCost: Double {
        25 * pow(1.55, Double(billValueLevel - 1))
    }

    var businessIncomePerSecond: Double {
        guard businessLevel > 0 else { return 0 }
        return 0.5 * pow(1.45, Double(businessLevel - 1))
    }

    var businessUpgradeCost: Double {
        80 * pow(1.6, Double(businessLevel))
    }

    init() {
        load()
        applyOfflineIncome()
    }

    func formatCash(_ value: Double? = nil) -> String {
        let amount = value ?? cash
        return "\(currency.symbol)\(Self.compact(amount))"
    }

    func throwBills(count: Int = 1) {
        cash += billValue * Double(max(1, count))
        save()
    }

    func tickPassive(delta: TimeInterval) {
        guard businessIncomePerSecond > 0, delta > 0 else { return }
        cash += businessIncomePerSecond * delta
        save()
    }

    @discardableResult
    func buyBillUpgrade() -> Bool {
        let cost = billUpgradeCost
        guard cash >= cost else { return false }
        cash -= cost
        billValueLevel += 1
        save()
        return true
    }

    @discardableResult
    func buyBusinessUpgrade() -> Bool {
        let cost = businessUpgradeCost
        guard cash >= cost else { return false }
        cash -= cost
        businessLevel += 1
        save()
        return true
    }

    func setCurrency(_ next: Currency) {
        currency = next
        save()
    }

    func cycleCurrency() {
        let all = Currency.allCases
        guard let idx = all.firstIndex(of: currency) else { return }
        setCurrency(all[(idx + 1) % all.count])
    }

    private func applyOfflineIncome() {
        let last = defaults.double(forKey: lastSeenKey)
        guard last > 0, businessIncomePerSecond > 0 else {
            defaults.set(Date().timeIntervalSince1970, forKey: lastSeenKey)
            return
        }
        let elapsed = min(Date().timeIntervalSince1970 - last, 8 * 60 * 60)
        if elapsed > 5 {
            cash += businessIncomePerSecond * elapsed * 0.5
        }
        defaults.set(Date().timeIntervalSince1970, forKey: lastSeenKey)
        save()
    }

    private func load() {
        cash = defaults.double(forKey: cashKey)
        billValueLevel = max(1, defaults.integer(forKey: billLevelKey) == 0 ? 1 : defaults.integer(forKey: billLevelKey))
        businessLevel = max(0, defaults.integer(forKey: businessLevelKey))
        if let raw = defaults.string(forKey: currencyKey), let c = Currency(rawValue: raw) {
            currency = c
        }
    }

    private func save() {
        defaults.set(cash, forKey: cashKey)
        defaults.set(currency.rawValue, forKey: currencyKey)
        defaults.set(billValueLevel, forKey: billLevelKey)
        defaults.set(businessLevel, forKey: businessLevelKey)
        defaults.set(Date().timeIntervalSince1970, forKey: lastSeenKey)
    }

    static func compact(_ value: Double) -> String {
        let absValue = abs(value)
        switch absValue {
        case 1_000_000_000_000...:
            return String(format: "%.2fT", value / 1_000_000_000_000)
        case 1_000_000_000...:
            return String(format: "%.2fB", value / 1_000_000_000)
        case 1_000_000...:
            return String(format: "%.2fM", value / 1_000_000)
        case 10_000...:
            return String(format: "%.1fK", value / 1_000)
        case 100...:
            return String(format: "%.0f", value)
        default:
            return String(format: "%.1f", value)
        }
    }
}
