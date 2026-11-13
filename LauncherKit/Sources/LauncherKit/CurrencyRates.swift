import Foundation

public struct CurrencyRates: Equatable, Sendable {
    public let date: String
    public let perDollar: [String: Double]

    public init(date: String, perDollar: [String: Double]) {
        self.date = date
        self.perDollar = perDollar
    }

    public init(json data: Data) throws {
        let response = try JSONDecoder().decode(Response.self, from: data)
        let rates = Dictionary(response.usd.map { ($0.key.uppercased(), $0.value) }) { first, _ in first }
        self.init(date: response.date, perDollar: rates)
    }

    public func convert(_ amount: Double, from: String, to: String) -> Double? {
        guard let fromRate = perDollar[from], let toRate = perDollar[to], fromRate > 0 else { return nil }
        return amount / fromRate * toRate
    }

    private struct Response: Decodable {
        let date: String
        let usd: [String: Double]
    }
}
