extension String {
    var capitalisingFirstLetter: String {
        prefix(1).uppercased() + dropFirst()
    }
}
