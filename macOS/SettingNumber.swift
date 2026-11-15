/// A number a setting's row can change: its value, the range and step it moves in, how it reads, and whether it is saved on every step or only once adjusting ends.
struct SettingNumber {
    let value: Double
    let range: ClosedRange<Double>
    let step: Double
    let label: (Double) -> String
    var savesOnlyWhenDone = false
    let set: @MainActor (Double) -> Void

    func clamped(_ value: Double) -> Double {
        min(max(value, range.lowerBound), range.upperBound)
    }
}
