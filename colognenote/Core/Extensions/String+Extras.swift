import Foundation

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
