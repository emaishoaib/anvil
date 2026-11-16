/// The fields of a JSON object whose values are text, leaving out any field whose value is a number, a list or another object.
struct StringFields: Decodable {
    let values: [String: String]

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: FieldName.self)
        var values: [String: String] = [:]
        for key in container.allKeys {
            guard let value = try? container.decode(String.self, forKey: key) else { continue }
            values[key.stringValue] = value
        }
        self.values = values
    }
}

/// Any field name of a JSON object, for reading objects whose field names are not known ahead of time.
private struct FieldName: CodingKey {
    let stringValue: String
    let intValue: Int? = nil

    init(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        nil
    }
}
