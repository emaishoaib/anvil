import RulesKit

/// The two keys chosen so far in the search bar's key swap form. It makes a swap only once both are chosen and they differ.
struct KeySwapDraft {
    var first: Int?
    var second: Int?

    var keySwap: KeySwap? {
        guard let first, let second, first != second else { return nil }
        return KeySwap(first: first, second: second)
    }
}
