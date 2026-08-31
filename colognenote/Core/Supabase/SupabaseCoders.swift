import Foundation

// PostgREST returns/accepts snake_case JSON. Rather than hand-write CodingKeys on
// every model, the client is configured with these coders: keys convert
// automatically, and timestamps use ISO-8601 (with or without fractional seconds).
//
// Convention: Postgres `timestamptz` columns map to `Date`; Postgres `date`
// columns (no time, no zone) map to `String` ("yyyy-MM-dd") to avoid day-shift bugs.

extension JSONDecoder {
    static let cologne: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let raw = try decoder.singleValueContainer().decode(String.self)
            if let date = ISO8601DateFormatter.cologneFractional.date(from: raw)
                ?? ISO8601DateFormatter.colognePlain.date(from: raw) {
                return date
            }
            throw DecodingError.dataCorruptedError(
                in: try decoder.singleValueContainer(),
                debugDescription: "Unrecognised timestamp: \(raw)"
            )
        }
        return decoder
    }()
}

extension JSONEncoder {
    static let cologne: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(ISO8601DateFormatter.cologneFractional.string(from: date))
        }
        return encoder
    }()
}

private extension ISO8601DateFormatter {
    static let colognePlain: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    static let cologneFractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}
