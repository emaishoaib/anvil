/// A line of a chat's saved transcript, the `.jsonl` file Claude Code keeps for each session, keeping only the fields needed to rebuild its turns.
struct RawTranscriptLine: Decodable {
    let type: String
    let isMeta: Bool?
    let isSidechain: Bool?
    let isCompactSummary: Bool?
    let origin: RawOrigin?
    let message: RawTranscriptMessage?
}

/// Who a transcript line came from, such as a person typing a prompt.
struct RawOrigin: Decodable {
    let kind: String?
}

/// A message in a saved transcript. A prompt's content is plain text, or a list of blocks when it carried an image, so both are read.
struct RawTranscriptMessage: Decodable {
    let text: String?
    let blocks: [RawBlock]

    enum CodingKeys: String, CodingKey {
        case content
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let text = try? container.decode(String.self, forKey: .content) {
            self.text = text
            blocks = []
        } else {
            blocks = (try? container.decode([RawBlock].self, forKey: .content)) ?? []
            let texts = blocks.filter { $0.type == "text" }.compactMap(\.text)
            text = texts.isEmpty ? nil : texts.joined(separator: "\n")
        }
    }
}
