import Foundation

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var nilIfBlank: String? {
        let value = trimmed
        return value.isEmpty ? nil : value
    }
}

func slugify(_ value: String) -> String {
    let lowercased = value.lowercased()
    let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-"))
    let separatorNormalized = lowercased.replacingOccurrences(
        of: "[^a-z0-9]+",
        with: "-",
        options: .regularExpression
    )
    let scalars = separatorNormalized.unicodeScalars.filter { allowed.contains($0) }
    let cleaned = String(String.UnicodeScalarView(scalars))
        .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    return cleaned.isEmpty ? "agent" : cleaned
}

