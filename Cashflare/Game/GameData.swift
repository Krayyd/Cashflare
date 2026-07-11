import Foundation

struct BillDef {
    let image: String
    let side: String
    let unlockAt: Double
}

struct ShopItemDef: Identifiable {
    let id: String
    let titleKey: String
    let icon: String
    let baseCost: Double
    let costPerLevel: Double
    let maxLevel: Int
    let moneyPerSecond: Double
    let moneyPerClick: Double
    let moneyPerLevel: [Double]
    let requireId: String?
    let requireLevel: Int
}

enum GameData {
    static func loadBills(currencyFolder: String = "Ruble") -> [BillDef] {
        guard
            let url = Bundle.main.url(forResource: "currency", withExtension: "plist", subdirectory: "Resources/\(currencyFolder)"),
            let dict = NSDictionary(contentsOf: url),
            let bills = dict["bills"] as? [[String: Any]]
        else { return [] }

        return bills.compactMap { item in
            guard
                let image = item["image"] as? String,
                let side = item["side"] as? String
            else { return nil }
            let unlock: Double
            if let v = item["value"] as? Double {
                unlock = v
            } else if let v = item["value"] as? Int {
                unlock = Double(v)
            } else {
                unlock = 0
            }
            return BillDef(image: image, side: side, unlockAt: unlock)
        }
    }

    static func loadShop(region: String = "Russia") -> (passive: [ShopItemDef], click: [ShopItemDef]) {
        guard
            let url = Bundle.main.url(forResource: "shop", withExtension: "plist", subdirectory: "Resources/\(region)"),
            let dict = NSDictionary(contentsOf: url)
        else { return ([], []) }

        let passive = parseSection(dict["section1"] as? [[String: Any]] ?? [], kind: .passive)
        let click = parseSection(dict["section3"] as? [[String: Any]] ?? [], kind: .click)
        return (passive, click)
    }

    private enum Kind { case passive, click }

    private static func parseSection(_ raw: [[String: Any]], kind: Kind) -> [ShopItemDef] {
        raw.compactMap { item in
            guard
                let id = item["id"] as? String,
                let title = item["title"] as? String,
                let icon = item["icon"] as? String
            else { return nil }

            let cost = doubleValue(item["cost"]) ?? 0
            let costPerLevel = doubleValue(item["costPerLevel"]) ?? 1.35
            let maxLevel = Int(doubleValue(item["maxLevel"]) ?? 0)
            let mps = doubleValue(item["moneyPerSecond"]) ?? 0
            let mpc = doubleValue(item["moneyPerClick"]) ?? 0
            let levels = (item["moneyPerLevel"] as? [Any])?.compactMap { doubleValue($0) } ?? [1, 3, 6]
            var reqId: String?
            var reqLv = 0
            if let req = item["require"] as? [String: Any] {
                reqId = req["id"] as? String
                if let s = req["level"] as? String { reqLv = Int(s) ?? 0 }
                else { reqLv = Int(doubleValue(req["level"]) ?? 0) }
            }

            return ShopItemDef(
                id: id,
                titleKey: title,
                icon: icon,
                baseCost: cost,
                costPerLevel: costPerLevel,
                maxLevel: maxLevel > 0 ? maxLevel : 999,
                moneyPerSecond: kind == .passive ? mps : 0,
                moneyPerClick: kind == .click ? mpc : 0,
                moneyPerLevel: levels,
                requireId: reqId,
                requireLevel: reqLv
            )
        }
    }

    private static func doubleValue(_ any: Any?) -> Double? {
        switch any {
        case let d as Double: return d
        case let i as Int: return Double(i)
        case let n as NSNumber: return n.doubleValue
        case let s as String: return Double(s)
        default: return nil
        }
    }

    static func loadStrings(lang: String = "ru") -> [String: String] {
        guard
            let url = Bundle.main.url(forResource: lang, withExtension: "json", subdirectory: "Resources/Localizable"),
            let data = try? Data(contentsOf: url),
            let dict = try? JSONSerialization.jsonObject(with: data) as? [String: String]
        else { return [:] }
        return dict
    }
}
