import Foundation

/// A prompt written as the one line of stream JSON that Claude Code reads as a new message from the user, ending in a newline so Claude Code knows the line is complete. A prompt with no images is plain text. One with images is a list of blocks instead, the images first as base64 PNG and then the text, which is left out when there is none, so Claude sees the images themselves rather than a path to them.
public enum ClaudePrompt {
    public static func line(_ text: String, pngImages: [Data] = []) -> Data {
        let message: [String: Any] = ["type": "user", "message": ["role": "user", "content": content(text, pngImages: pngImages)]]
        let json = (try? JSONSerialization.data(withJSONObject: message)) ?? Data()
        return json + Data("\n".utf8)
    }

    private static func content(_ text: String, pngImages: [Data]) -> Any {
        guard !pngImages.isEmpty else { return text }
        let images: [[String: Any]] = pngImages.map { png in
            ["type": "image", "source": ["type": "base64", "media_type": "image/png", "data": png.base64EncodedString()]]
        }
        let words: [[String: Any]] = text.isEmpty ? [] : [["type": "text", "text": text]]
        return images + words
    }
}
