import Foundation

/// Rebuilds a saved chat's turns from the transcript Claude Code keeps for it, so a chat carried on later shows what came before. Only prompts a person typed start a turn: lines Claude Code adds itself, such as command output, notes it slips in, or summaries after compacting, are left out, and so is everything an agent did on Claude's behalf. Text written before a tool is kept apart from the text after it, the same as while the answer streamed in.
public enum SessionHistory {
    private static let addedByClaudeCode = ["<command-", "<local-command", "[Request interrupted"]

    public static func turns(in transcript: String) -> [PastTurn] {
        var turns: [PastTurn] = []
        for line in transcript.split(separator: "\n") {
            guard let raw = try? JSONDecoder().decode(RawTranscriptLine.self, from: Data(line.utf8)), raw.isSidechain != true, let message = raw.message else { continue }
            if raw.type == "user", let prompt = prompt(in: raw, message: message) {
                turns.append(PastTurn(prompt: prompt))
                continue
            }
            guard !turns.isEmpty else { continue }
            for block in message.blocks {
                add(block, to: &turns[turns.count - 1])
            }
        }
        return turns
    }

    private static func prompt(in raw: RawTranscriptLine, message: RawTranscriptMessage) -> String? {
        guard raw.isMeta != true, raw.isCompactSummary != true, raw.origin?.kind ?? "human" == "human" else { return nil }
        guard !message.blocks.contains(where: { $0.type == "tool_result" }), let text = message.text, !text.isEmpty else { return nil }
        guard !addedByClaudeCode.contains(where: text.hasPrefix) else { return nil }
        return text
    }

    private static func add(_ block: RawBlock, to turn: inout PastTurn) {
        switch block.type {
        case "text":
            turn.answer += block.text ?? ""
        case "tool_use":
            guard let id = block.id, let name = block.name else { return }
            turn.tools.append(ToolCall(id: id, name: name, input: block.input?.values ?? [:]))
            if !turn.answer.isEmpty, !turn.answer.hasSuffix("\n") { turn.answer += "\n\n" }
        case "tool_result":
            guard block.isError == true, let id = block.toolUseID else { return }
            turn.failedToolIDs.insert(id)
        default:
            break
        }
    }
}
