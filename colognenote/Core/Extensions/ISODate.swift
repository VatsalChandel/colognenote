import Foundation

/// The single formatter for Postgres `date` columns ("yyyy-MM-dd"). One place so
/// the log sheets, the Add form and the derived-season helper all agree (task 6.4).
enum ISODate {
    static func string(from date: Date) -> String { formatter.string(from: date) }
    static func date(from string: String) -> Date? { formatter.date(from: string) }

    static let today: String = string(from: Date())

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .current
        return f
    }()
}
