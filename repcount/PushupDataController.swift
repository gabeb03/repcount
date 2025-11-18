//
//  PushupDataController.swift
//  repcount
//

import Foundation
import SwiftUI

final class PushupDataController {
    private(set) var entries: [PushupEntry] = []
    var isLoading = false
    var toastMessage: String?
    var selectedRange: ActivityRange = .week

    private let repository: PushupRepositoryProtocol
    private let metadataStore = PushupMetadataStore()
    private let calendar: Calendar
    private let userId: String

    init(
        userId: String = AppConfiguration.userID,
        repository: PushupRepositoryProtocol = PushupRepository(),
        calendar: Calendar = .current
    ) {
        self.userId = userId
        self.repository = repository
        self.calendar = calendar
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let remoteEntries   = try await repository.fetchEntries(for: userId)
            entries = remoteEntries
                .map { applyMetadata($0) }
                .sorted { $0.displayDate > $1.displayDate }
            toastMessage = nil
        } catch {
            // Attempt to provide design-time data if nothing is cached.
            if entries.isEmpty, let fallback = try? await MockPushupRepository().fetchEntries(for: userId) {
                entries = fallback
                    .map { applyMetadata($0) }
                    .sorted { $0.displayDate > $1.displayDate }
            }
            toastMessage = error.localizedDescription
        }
    }

    func refresh() {
        Task { await load() }
    }

    func save(form: PushupEntryForm, editing entry: PushupEntry?) async -> Bool {
        guard form.isValid else {
            toastMessage = "Enter at least one push-up."
            return false
        }

        do {
            let normalizedDate = calendar.startOfDay(for: form.date)
            let metadata = PushupMetadataStore.Metadata(
                notes: form.notes.isEmpty ? nil : form.notes,
                overrideDate: normalizedDate
            )
            if var editingEntry = entry {
                let updated = try await repository.updateEntry(id: editingEntry.id, count: form.count)
                editingEntry.count = updated.count
                editingEntry.updatedAt = updated.updatedAt
                editingEntry.createdAt = updated.createdAt
                metadataStore.setMetadata(metadata, for: updated.id)
                merge(updated: applyMetadata(editingEntry))
            } else {
                let created = try await repository.createEntry(for: userId, count: form.count)
                metadataStore.setMetadata(metadata, for: created.id)
                var entryWithMetadata = created
                entryWithMetadata.notes = metadata.notes
                entryWithMetadata.overrideDate = metadata.overrideDate
                entries.append(entryWithMetadata)
                entries.sort { $0.displayDate > $1.displayDate }
            }
            toastMessage = nil
            return true
        } catch {
            toastMessage = error.localizedDescription
            return false
        }
    }

    func delete(entry: PushupEntry) async {
        do {
            try await repository.deleteEntry(id: entry.id)
            metadataStore.removeMetadata(for: entry.id)
            entries.removeAll { $0.id == entry.id }
        } catch {
            toastMessage = error.localizedDescription
        }
    }

    // MARK: - Analytics

    var todayStats: StreakStats {
        entries.streakStats(for: Date(), calendar: calendar)
    }

    var lastTenDayTotals: [DailyPushupTotal] {
        entries.totals(forLast: 10, calendar: calendar)
    }

    func weekdayComparisonText(for date: Date = Date()) -> String {
        let weekday = calendar.component(.weekday, from: date)
        let weekdayAverage = entries.weekdayAverage(for: weekday, calendar: calendar)
        let stats = todayStats
        let dayName = date.formatted(.dateTime.weekday(.wide))
        guard weekdayAverage > 0 else {
            return "No history for \(dayName) yet"
        }
        if Double(stats.total) >= weekdayAverage * 1.05 {
            return "Above typical \(dayName)"
        } else if Double(stats.total) <= weekdayAverage * 0.8 {
            return "Below your usual \(dayName)"
        } else {
            return "In line with your \(dayName)s"
        }
    }

    func history(for range: ActivityRange) -> [PushupHistoryDay] {
        entries.history(range: range, calendar: calendar)
    }

    func summary(for range: ActivityRange) -> (period: String, duration: String, total: String, average: String) {
        let histories = history(for: range)
        let totalPushups = histories.reduce(0) { $0 + $1.total }
        let totalDuration = histories.flatMap(\.entries).reduce(0) { $0 + $1.estimatedDuration }
        let averagePerDay = histories.isEmpty ? 0 : Double(totalPushups) / Double(histories.count)
        let periodText = periodText(for: histories, range: range)
        return (
            periodText,
            totalDuration.formattedHoursMinutes,
            "\(totalPushups)",
            String(format: "%.0f", averagePerDay)
        )
    }

    private func periodText(for histories: [PushupHistoryDay], range: ActivityRange) -> String {
        guard let first = histories.last?.date, let last = histories.first?.date else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: Date()).uppercased()
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: first).uppercased()) – \(formatter.string(from: last).uppercased())"
    }

    func monthlyInsights(for month: Date = Date()) -> MonthlyInsights {
        entries.monthlyInsights(for: month, calendar: calendar)
    }

    // MARK: - Helpers

    private func applyMetadata(_ entry: PushupEntry) -> PushupEntry {
        var enriched = entry
        if let metadata = metadataStore.metadata(for: entry.id) {
            enriched.notes = metadata.notes
            enriched.overrideDate = metadata.overrideDate
        }
        return enriched
    }

    private func merge(updated entry: PushupEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
        } else {
            entries.append(entry)
        }
        entries.sort { $0.displayDate > $1.displayDate }
    }

    static var preview: PushupDataController {
        let controller = PushupDataController(userId: "preview", repository: MockPushupRepository())
        Task { await controller.load() }
        return controller
    }
}
