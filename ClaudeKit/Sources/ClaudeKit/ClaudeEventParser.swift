import Foundation

/// Turns one line of Claude Code's stream JSON output into the events Anvil acts on. A line that is not JSON, or that reports something Anvil does not show, gives no events. A message can start several tools at once, so one line can give several events.
public enum ClaudeEventParser {
    public static func events(in line: String) -> [ClaudeEvent] {
        guard let raw = try? JSONDecoder().decode(RawEvent.self, from: Data(line.utf8)) else { return [] }
        return switch raw.type {
        case "system": [started(from: raw)].compactMap(\.self)
        case "stream_event": [text(from: raw)].compactMap(\.self)
        case "assistant": raw.message?.content.compactMap(toolStarted) ?? []
        case "user": raw.message?.content.compactMap(toolFinished) ?? []
        case "result": [.finished(answer: raw.result ?? "", failed: raw.isError ?? false)]
        default: []
        }
    }

    private static func started(from raw: RawEvent) -> ClaudeEvent? {
        guard raw.subtype == "init", let sessionID = raw.sessionID, let model = raw.model, let folder = raw.cwd else { return nil }
        return .started(sessionID: sessionID, model: model, folder: folder)
    }

    private static func text(from raw: RawEvent) -> ClaudeEvent? {
        guard raw.event?.type == "content_block_delta", let delta = raw.event?.delta, delta.type == "text_delta", let text = delta.text else { return nil }
        return .text(text)
    }

    private static func toolStarted(_ block: RawBlock) -> ClaudeEvent? {
        guard block.type == "tool_use", let id = block.id, let name = block.name else { return nil }
        return .toolStarted(ToolCall(id: id, name: name, input: block.input?.values ?? [:]))
    }

    private static func toolFinished(_ block: RawBlock) -> ClaudeEvent? {
        guard block.type == "tool_result", let id = block.toolUseID else { return nil }
        return .toolFinished(id: id, failed: block.isError ?? false)
    }
}
