import Foundation

/// "1 wear" / "3 wears" — plain, no localization catalog needed.
func pluralized(_ count: Int, _ singular: String, _ plural: String? = nil) -> String {
    "\(count) \(count == 1 ? singular : (plural ?? singular + "s"))"
}

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isValidEmail: Bool {
        wholeMatch(of: #/[^@\s]+@[^@\s]+\.[^@\s]+/#) != nil
    }

    /// nil if the trimmed string is empty — handy for optional DB columns.
    var nilIfBlank: String? {
        let t = trimmed
        return t.isEmpty ? nil : t
    }
}
