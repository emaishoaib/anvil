import Foundation

enum DictionaryEntries {
    private static let exactMatch: UInt64 = 0
    private static let maximumRecords = 10
    private static let applicationLayout = 1
    private static let style = """
        html, body { margin: 0; background: transparent; }
        body { padding: 4px 24px 24px; }
        h2 { font: bold 15pt ui-serif; color: GrayText; margin: 20px 16px 4px; padding-bottom: 8px;
             border-bottom: 1px solid color-mix(in srgb, CanvasText 15%, transparent); }
        iframe { display: block; width: 100%; border: 0; }
        """
    private static let fitAndReveal = """
        function fitted(frame) {
            frame.style.height = frame.contentDocument.documentElement.scrollHeight + 'px';
            frame.dataset.fitted = 'yes';
            if ([...document.querySelectorAll('iframe')].every(each => each.dataset.fitted)) {
                document.body.style.visibility = 'visible';
            }
        }
        """

    static func page(for text: String) -> String {
        let sections = sections(for: text).map { section in
            "<h2>\(escaped(section.title))</h2>" + section.records.map { "<iframe srcdoc=\"\(escaped($0))\" onload=\"fitted(this)\"></iframe>" }.joined()
        }
        let visibility = sections.isEmpty ? "visible" : "hidden"
        return """
            <!DOCTYPE html><html><head><meta charset="utf-8"><meta name="color-scheme" content="light dark">
            <style>\(style) body { visibility: \(visibility); }</style><script>\(fitAndReveal)</script></head>
            <body>\(sections.joined())</body></html>
            """
    }

    private static func sections(for text: String) -> [(title: String, records: [String])] {
        guard let dictionaries = DCSGetActiveDictionaries()?.takeUnretainedValue() as? [AnyObject] else { return [] }
        return dictionaries.compactMap { dictionary in
            let found = DCSCopyRecordsForSearchString(dictionary, text as CFString, exactMatch, maximumRecords)?.takeRetainedValue() as? [AnyObject] ?? []
            let records = found.compactMap { DCSRecordCopyData($0, applicationLayout)?.takeRetainedValue() as String? }
            guard !records.isEmpty, let title = DCSDictionaryGetShortName(dictionary)?.takeUnretainedValue() as String? else { return nil }
            return (title, records)
        }
    }

    private static func escaped(_ html: String) -> String {
        html.replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "<", with: "&lt;")
    }
}
