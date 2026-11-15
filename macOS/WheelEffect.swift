nonisolated enum WheelEffect: String, Codable, CaseIterable {
    case scrollVertically, scrollHorizontally, zoom

    var name: String {
        switch self {
        case .scrollHorizontally: "Scrolls sideways"
        case .scrollVertically: "Scrolls up and down"
        case .zoom: "Zooms in and out"
        }
    }
}
