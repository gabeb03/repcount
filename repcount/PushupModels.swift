//
//  PushupModels.swift
//  repcount
//
//  Created for push-up tracking experience inspired by Gentler Streak.
//

import Foundation

/// Represents one push-up log entry sourced from the API plus local metadata.
struct PushupEntry: Identifiable, Hashable {
    let id: String
    var count: Int
    var createdAt: Date
    var updatedAt: Date
    var notes: String? = nil
    var overrideDate: Date? = nil

    var displayDate: Date { overrideDate ?? createdAt }
    var estimatedDuration: TimeInterval {
        // Assume ~0.9s per push-up to keep durations close to reality.
        Double(count) * 0.9
    }
}

/// Captures stats for the streak (today) card.
struct StreakStats {
    let total: Int
    let sets: Int
    let totalDuration: TimeInterval
    let bestSet: Int
    let averagePerSet: Double
}

/// Represents totals grouped by a single day for charts and history.
struct PushupHistoryDay: Identifiable, Hashable {
    var id: Date { date }
    let date: Date
    let total: Int
    let entries: [PushupEntry]

    var notesAvailable: Bool { entries.contains { ($0.notes ?? "").isEmpty == false } }
}

struct DailyPushupTotal: Identifiable, Hashable {
    var id: Date { date }
    let date: Date
    let total: Int
}

struct MonthlyInsights {
    let month: Date
    let dailyTotals: [DailyPushupTotal]
    let activeDays: Int
    let previousMonthActiveDays: Int
    let longestStreak: Int
    let averageOnActiveDays: Double
    let bestDay: PushupHistoryDay?
}

enum ActivityRange: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    case allTime = "All Time"

    var id: String { rawValue }

    var daysBack: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .year: return 365
        case .allTime: return 9999
        }
    }
}

/// Form model for creating or editing a push-up entry.
struct PushupEntryForm {
    var count: Int = 20
    var date: Date = Date()
    var notes: String = ""

    var isValid: Bool { count > 0 }

    init() {}

    init(entry: PushupEntry) {
        count = entry.count
        date = entry.displayDate
        notes = entry.notes ?? ""
    }
}

// MARK: - Metadata persistence

final class PushupMetadataStore {
    struct Metadata: Codable {
        var notes: String?
        var overrideDate: Date?
    }

    private let storageKey = "PushupMetadataStore.v1"
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let defaults: UserDefaults
    private var cache: [String: Metadata]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: storageKey),
           let decoded = try? decoder.decode([String: Metadata].self, from: data) {
            cache = decoded
        } else {
            cache = [:]
        }
    }

    func metadata(for id: String) -> Metadata? {
        cache[id]
    }

    func setMetadata(_ metadata: Metadata?, for id: String) {
        cache[id] = metadata
        persist()
    }

    func removeMetadata(for id: String) {
        cache[id] = nil
        persist()
    }

    private func persist() {
        guard let data = try? encoder.encode(cache) else { return }
        defaults.set(data, forKey: storageKey)
    }
}

// MARK: - Analytics helpers

extension Array where Element == PushupEntry {
    func streakStats(for date: Date, calendar: Calendar) -> StreakStats {
        let todaysEntries = filter { calendar.isDate($0.displayDate, inSameDayAs: date) }
        let total = todaysEntries.reduce(0) { $0 + $1.count }
        let best = todaysEntries.map(\.count).max() ?? 0
        let duration = todaysEntries.reduce(0) { $0 + $1.estimatedDuration }
        let sets = todaysEntries.count
        let average = sets > 0 ? Double(total) / Double(sets) : 0
        return StreakStats(total: total, sets: sets, totalDuration: duration, bestSet: best, averagePerSet: average)
    }

    func weekdayAverage(for weekday: Int, calendar: Calendar) -> Double {
        let grouped = Dictionary(grouping: self) { calendar.component(.weekday, from: $0.displayDate) }
        let entries = grouped[weekday] ?? []
        guard !entries.isEmpty else { return 0 }
        let totalsByDay = Dictionary(grouping: entries) { calendar.startOfDay(for: $0.displayDate) }
        let sums = totalsByDay.values.map { $0.reduce(0) { $0 + $1.count } }
        guard !sums.isEmpty else { return 0 }
        return Double(sums.reduce(0, +)) / Double(sums.count)
    }

    func totals(forLast days: Int, calendar: Calendar) -> [DailyPushupTotal] {
        guard days > 0 else { return [] }
        let now = calendar.startOfDay(for: Date())
        var totals: [DailyPushupTotal] = []
        for offset in stride(from: days - 1, through: 0, by: -1) {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: now) else { continue }
            let total = filter { calendar.isDate($0.displayDate, inSameDayAs: day) }.reduce(0) { $0 + $1.count }
            totals.append(DailyPushupTotal(date: day, total: total))
        }
        return totals
    }

    func history(range: ActivityRange, calendar: Calendar) -> [PushupHistoryDay] {
        let startDate = calendar.date(byAdding: .day, value: -(range.daysBack - 1), to: calendar.startOfDay(for: Date())) ?? Date()
        let filtered = filter { entry in
            let day = entry.displayDate
            return day >= startDate || range == .allTime
        }
        let grouped = Dictionary(grouping: filtered) { calendar.startOfDay(for: $0.displayDate) }
        return grouped
            .map { date, entries in
                PushupHistoryDay(date: date, total: entries.reduce(0) { $0 + $1.count }, entries: entries.sorted { $0.displayDate > $1.displayDate })
            }
            .sorted { $0.date > $1.date }
    }

    func monthlyInsights(for month: Date, calendar: Calendar) -> MonthlyInsights {
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
              let range = calendar.range(of: .day, in: .month, for: monthStart) else {
            return MonthlyInsights(month: month, dailyTotals: [], activeDays: 0, previousMonthActiveDays: 0, longestStreak: 0, averageOnActiveDays: 0, bestDay: nil)
        }

        let monthEntries = filter { calendar.isDate($0.displayDate, equalTo: monthStart, toGranularity: .month) }
        let totals = range.map { day -> DailyPushupTotal in
            let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) ?? monthStart
            let total = monthEntries.filter { calendar.isDate($0.displayDate, inSameDayAs: date) }.reduce(0) { $0 + $1.count }
            return DailyPushupTotal(date: date, total: total)
        }

        let activeDays = totals.filter { $0.total > 0 }.count
        let averageOnActiveDays = activeDays > 0 ? Double(totals.filter { $0.total > 0 }.reduce(0) { $0 + $1.total }) / Double(activeDays) : 0
        let bestDayTotal = totals.max { $0.total < $1.total }
        let bestDayEntries = monthEntries.filter { entry in
            if let bestDate = bestDayTotal?.date {
                return calendar.isDate(entry.displayDate, inSameDayAs: bestDate)
            }
            return false
        }
        var bestDay: PushupHistoryDay? = nil
        if let best = bestDayTotal {
            let sortedEntries = bestDayEntries.sorted { $0.displayDate > $1.displayDate }
            bestDay = PushupHistoryDay(date: best.date, total: best.total, entries: sortedEntries)
        }

        let previousMonthDate = calendar.date(byAdding: .month, value: -1, to: monthStart) ?? monthStart
        let previousTotals = activeDayCount(for: previousMonthDate, calendar: calendar)

        return MonthlyInsights(
            month: monthStart,
            dailyTotals: totals,
            activeDays: activeDays,
            previousMonthActiveDays: previousTotals,
            longestStreak: longestStreak(calendar: calendar),
            averageOnActiveDays: averageOnActiveDays,
            bestDay: bestDay
        )
    }

    private func activeDayCount(for month: Date, calendar: Calendar) -> Int {
        guard let start = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
              let range = calendar.range(of: .day, in: .month, for: start) else {
            return 0
        }
        return range.reduce(0) { count, day in
            let date = calendar.date(byAdding: .day, value: day - 1, to: start) ?? start
            let hasEntry = contains { calendar.isDate($0.displayDate, inSameDayAs: date) }
            return hasEntry ? count + 1 : count
        }
    }

    func longestStreak(calendar: Calendar) -> Int {
        let grouped = Dictionary(grouping: self) { calendar.startOfDay(for: $0.displayDate) }
        let days = grouped.keys.sorted()
        var longest = 0
        var current = 0
        var previousDay: Date?
        for day in days {
            defer { previousDay = day }
            if let previous = previousDay,
               let diff = calendar.dateComponents([.day], from: previous, to: day).day,
               diff == 1 {
                current += 1
            } else {
                current = 1
            }
            longest = Swift.max(longest, current)
        }
        return longest
    }
}

// MARK: - Formatting helpers

extension TimeInterval {
    var formattedHoursMinutes: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
