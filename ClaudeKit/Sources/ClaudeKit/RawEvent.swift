/// A line of Claude Code's stream JSON output as it is written, keeping only the fields Anvil reads.
struct RawEvent: Decodable {
    let type: String
    let subtype: String?
    let sessionID: String?
    let model: String?
    let cwd: String?
    let event: RawStreamEvent?
    let message: RawMessage?
    let isError: Bool?
    let result: String?
    let requestID: String?
    let request: RawControlRequest?

    enum CodingKeys: String, CodingKey {
        case type, subtype, model, cwd, event, message, result, request
        case sessionID = "session_id"
        case isError = "is_error"
        case requestID = "request_id"
    }
}

/// Something Claude Code asks the app driving it, such as whether a tool may run.
struct RawControlRequest: Decodable {
    let subtype: String
    let toolName: String?
    let input: StringFields?
    let toolUseID: String?

    enum CodingKeys: String, CodingKey {
        case subtype, input
        case toolName = "tool_name"
        case toolUseID = "tool_use_id"
    }
}

/// A piece of the answer as it streams in, such as a few more words of text.
struct RawStreamEvent: Decodable {
    let type: String
    let delta: RawDelta?
}

/// The change a streamed piece of the answer makes, which carries text when it adds words to the answer.
struct RawDelta: Decodable {
    let type: String
    let text: String?
}

/// A whole message from Claude or back to it. Its content is a list of blocks, or plain text, which counts as no blocks.
struct RawMessage: Decodable {
    let content: [RawBlock]

    enum CodingKeys: String, CodingKey {
        case content
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        content = (try? container.decode([RawBlock].self, forKey: .content)) ?? []
    }
}

/// One block of a message, such as a tool Claude starts using or the result that tool gave back.
struct RawBlock: Decodable {
    let type: String
    let id: String?
    let name: String?
    let input: StringFields?
    let toolUseID: String?
    let isError: Bool?

    enum CodingKeys: String, CodingKey {
        case type, id, name, input
        case toolUseID = "tool_use_id"
        case isError = "is_error"
    }
}
