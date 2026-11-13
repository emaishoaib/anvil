import Foundation
import LauncherKit

final class CurrencyRatesStore {
    static let shared = CurrencyRatesStore()

    private static let dataKey = "launcher.currencyRates"
    private static let fetchedKey = "launcher.currencyRatesFetchedAt"
    private static let refreshIntervalSeconds: TimeInterval = 12 * 60 * 60
    private static let sources = [
        URL(string: "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json")!,
        URL(string: "https://latest.currency-api.pages.dev/v1/currencies/usd.json")!,
    ]

    private(set) var rates: CurrencyRates?
    private var isFetching = false

    func start() {
        rates = UserDefaults.standard.data(forKey: Self.dataKey).flatMap { try? CurrencyRates(json: $0) }
        refreshIfStale()
    }

    func refreshIfStale() {
        let fetchedAt = UserDefaults.standard.object(forKey: Self.fetchedKey) as? Date ?? .distantPast
        guard !isFetching, Date.now.timeIntervalSince(fetchedAt) > Self.refreshIntervalSeconds else { return }
        isFetching = true
        Task {
            defer { isFetching = false }
            for source in Self.sources {
                guard let (data, _) = try? await URLSession.shared.data(from: source), let fresh = try? CurrencyRates(json: data) else { continue }
                rates = fresh
                UserDefaults.standard.set(data, forKey: Self.dataKey)
                UserDefaults.standard.set(Date.now, forKey: Self.fetchedKey)
                return
            }
        }
    }
}
