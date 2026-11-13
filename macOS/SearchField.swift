enum SearchField: Hashable {
    case query
    case argument(Int)
    case actionFilter

    func moved(by offset: Int, argumentCount: Int) -> SearchField {
        let fields = [SearchField.query] + (0..<argumentCount).map(SearchField.argument)
        let index = fields.firstIndex(of: self) ?? 0
        return fields[(index + offset + fields.count) % fields.count]
    }
}
