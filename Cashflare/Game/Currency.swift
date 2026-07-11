import Foundation

enum Currency: String, CaseIterable, Identifiable, Codable {
    case usd
    case eur
    case gbp
    case brl
    case inr
    case tryLira = "try"
    case rub

    var id: String { rawValue }

    var code: String {
        switch self {
        case .usd: return "USD"
        case .eur: return "EUR"
        case .gbp: return "GBP"
        case .brl: return "BRL"
        case .inr: return "INR"
        case .tryLira: return "TRY"
        case .rub: return "RUB"
        }
    }

    var symbol: String {
        switch self {
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .brl: return "R$"
        case .inr: return "₹"
        case .tryLira: return "₺"
        case .rub: return "₽"
        }
    }

    var flag: String {
        switch self {
        case .usd: return "🇺🇸"
        case .eur: return "🇪🇺"
        case .gbp: return "🇬🇧"
        case .brl: return "🇧🇷"
        case .inr: return "🇮🇳"
        case .tryLira: return "🇹🇷"
        case .rub: return "🇷🇺"
        }
    }

    var billColorHex: String {
        switch self {
        case .usd: return "2E7D4F"
        case .eur: return "2F5AA8"
        case .gbp: return "6B3FA0"
        case .brl: return "1F8A4C"
        case .inr: return "C45C26"
        case .tryLira: return "C0392B"
        case .rub: return "1F6A4D"
        }
    }

    var accentHex: String {
        switch self {
        case .usd: return "F2E8C9"
        case .eur: return "E8F0FF"
        case .gbp: return "F3E9FF"
        case .brl: return "FFF4CC"
        case .inr: return "FFE7D1"
        case .tryLira: return "FFE4E1"
        case .rub: return "E8F7EE"
        }
    }
}
