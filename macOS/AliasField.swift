/// The alias form's text fields, in the order Tab moves through them. Tab after the last field goes back to the first, and Shift Tab goes the other way.
enum AliasField: CaseIterable {
    case name
    case command

    func moved(by offset: Int) -> AliasField {
        let fields = Self.allCases
        let index = fields.firstIndex(of: self) ?? 0
        return fields[(index + offset + fields.count) % fields.count]
    }
}
