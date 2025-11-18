//
//  ContentView.swift
//  repcount
//

import SwiftUI
import Charts

struct ContentView: View {
    @State private var session: AuthSession? = nil

    var body: some View {
        if let session {
            AuthenticatedAppView(session: session) {
                AuthService.shared.signOut()
                self.session = nil
            }
        } else {
            AuthenticationView { session in
                self.session = session
            }
        }
    }
}

struct AuthenticatedAppView: View {
    let session: AuthSession
    var onSignOut: () -> Void

    private let controller: PushupDataController
    @State private var entries: [PushupEntry] = []
    @State private var toastMessage: String?
    @State private var showingEntrySheet = false
    @State private var entryForm = PushupEntryForm()
    @State private var editingEntry: PushupEntry?
    @State private var selectedHistoryDay: PushupHistoryDay?
    @State private var selectedRange: ActivityRange = .week
    private let calendar = Calendar.current

    init(session: AuthSession, onSignOut: @escaping () -> Void) {
        self.session = session
        self.onSignOut = onSignOut
        self.controller = PushupDataController(userId: session.userId)
    }

    var body: some View {
        TabView {
            StreakView(
                stats: todayStats,
                comparisonText: weekdayComparisonText(),
                totals: lastTenDayTotals,
                onAdd: { presentSheet(for: nil) }
            )
            .tabItem {
                Label("Streak", systemImage: "flame.fill")
            }

            ActivitiesView(
                selectedRange: $selectedRange,
                histories: histories(for: selectedRange),
                summary: summary(for: selectedRange),
                onSelectHistoryDay: { selectedHistoryDay = $0 },
                onSignOut: onSignOut
            )
            .tabItem {
                Label("Activities", systemImage: "list.bullet.rectangle")
            }

            InsightsView(insights: monthlyInsights())
                .tabItem {
                    Label("Insights", systemImage: "sparkles")
                }
        }
        .task {
            await loadEntries()
        }
        .sheet(isPresented: $showingEntrySheet) {
            AddPushupSheet(
                form: $entryForm,
                isEditing: editingEntry != nil,
                onDismiss: { showingEntrySheet = false },
                onSave: { form in
                    await handleSave(form: form)
                }
            )
        }
        .sheet(item: $selectedHistoryDay) { day in
            HistoryDetailSheet(
                day: day,
                onEdit: { entry in
                    selectedHistoryDay = nil
                    presentSheet(for: entry)
                },
                onDelete: { entry in
                    Task { await deleteEntry(entry) }
                }
            )
            .presentationDetents([.medium, .large])
        }
        .overlay(alignment: .bottom) {
            if let toast = toastMessage {
                ToastView(message: toast)
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: toastMessage)
    }

    private func presentSheet(for entry: PushupEntry?) {
        editingEntry = entry
        if let entry {
            entryForm = PushupEntryForm(entry: entry)
        } else {
            entryForm = PushupEntryForm()
        }
        showingEntrySheet = true
    }

    private func loadEntries() async {
        await controller.load()
        await MainActor.run {
            syncStateFromController()
        }
    }

    private func handleSave(form: PushupEntryForm) async -> Bool {
        let success = await controller.save(form: form, editing: editingEntry)
        await MainActor.run {
            syncStateFromController()
        }
        return success
    }

    private func deleteEntry(_ entry: PushupEntry) async {
        await controller.delete(entry: entry)
        await MainActor.run {
            syncStateFromController()
        }
    }

    @MainActor
    private func syncStateFromController() {
        entries = controller.entries
        toastMessage = controller.toastMessage
    }

    private var todayStats: StreakStats {
        entries.streakStats(for: Date(), calendar: calendar)
    }

    private func weekdayComparisonText(for date: Date = Date()) -> String {
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

    private var lastTenDayTotals: [DailyPushupTotal] {
        entries.totals(forLast: 10, calendar: calendar)
    }

    private func histories(for range: ActivityRange) -> [PushupHistoryDay] {
        entries.history(range: range, calendar: calendar)
    }

    private func summary(for range: ActivityRange) -> (period: String, duration: String, total: String, average: String) {
        let histories = histories(for: range)
        let totalPushups = histories.reduce(0) { $0 + $1.total }
        let totalDuration = histories.flatMap(\.entries).reduce(0) { $0 + $1.estimatedDuration }
        let averagePerDay = histories.isEmpty ? 0 : Double(totalPushups) / Double(histories.count)
        let periodText = periodText(for: histories)
        return (
            periodText,
            totalDuration.formattedHoursMinutes,
            "\(totalPushups)",
            String(format: "%.0f", averagePerDay)
        )
    }

    private func periodText(for histories: [PushupHistoryDay]) -> String {
        guard let first = histories.last?.date, let last = histories.first?.date else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: Date()).uppercased()
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: first).uppercased()) – \(formatter.string(from: last).uppercased())"
    }

    private func monthlyInsights(for month: Date = Date()) -> MonthlyInsights {
        entries.monthlyInsights(for: month, calendar: calendar)
    }
}

// MARK: - Streak

struct StreakView: View {
    let stats: StreakStats
    let comparisonText: String
    let totals: [DailyPushupTotal]
    var onAdd: () -> Void
    @State private var animateCard = false
    @Environment(\.colorScheme) private var colorScheme

    private var dateSubtitle: String {
        Date().formatted(Date.FormatStyle().weekday(.wide).month(.wide).day())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    streakCard
                    statsRow
                    ProgressChartView(totals: totals)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 120)
            }
            .background(backgroundGradient)
            .overlay(alignment: .bottomTrailing) {
                FloatingAddButton(action: onAdd, title: "Log Push-ups")
                    .padding(24)
            }
            .navigationBarHidden(true)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            Image(systemName: "chevron.left")
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
            VStack(spacing: 4) {
                Text("Push-ups")
                    .font(.headline)
                Text(dateSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }

    private var streakCard: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color.orange, Color(red: 1.0, green: 0.55, blue: 0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(color: Color.orange.opacity(0.3), radius: 20, y: 10)
                    .frame(width: 260, height: 260)
                VStack(spacing: 12) {
                    AnimatedCountText(value: Double(stats.total))
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(comparisonText)
                        .font(.callout)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .scaleEffect(animateCard ? 1 : 0.9)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    animateCard = true
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
    }

    private var statsRow: some View {
        let statItems = [
            ("Total Sets", "\(stats.sets)"),
            ("Duration", stats.totalDuration.formattedHoursMinutes),
            ("Best Set", "\(stats.bestSet)"),
            ("Avg / Set", stats.averagePerSet.isFinite ? String(format: "%.0f", stats.averagePerSet) : "0")
        ]
        let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(statItems, id: \.0) { title, value in
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(value)
                        .font(.title3.bold())
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(UIColor.secondarySystemBackground))
                        .shadow(color: Color.black.opacity(0.04), radius: 12, y: 6)
                )
            }
        }
    }

    private var backgroundGradient: some View {
        let colors = [
            Color(red: 1.0, green: 0.96, blue: 0.93),
            Color(red: 0.95, green: 0.97, blue: 1.0)
        ]
        let darkColors = [
            Color(red: 0.1, green: 0.08, blue: 0.12),
            Color(red: 0.07, green: 0.07, blue: 0.11)
        ]
        return LinearGradient(colors: colorScheme == .dark ? darkColors : colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}

struct ProgressChartView: View {
    let totals: [DailyPushupTotal]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last days")
                .font(.headline)
            Chart {
                ForEach(totals) { day in
                    BarMark(
                        x: .value("Day", day.date, unit: .day),
                        y: .value("Push-ups", day.total)
                    )
                    .foregroundStyle(Color.orange.gradient)
                    .cornerRadius(8)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks(values: totals.map(\.date)) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date.formatted(.dateTime.weekday(.narrow)))
                        }
                    }
                }
            }
            .frame(height: 200)
            .padding()
            .background(RoundedRectangle(cornerRadius: 24).fill(Color(UIColor.secondarySystemBackground)))
            .shadow(color: Color.black.opacity(0.04), radius: 12, y: 6)
        }
    }
}

// MARK: - Activities

struct ActivitiesView: View {
    @Binding var selectedRange: ActivityRange
    let histories: [PushupHistoryDay]
    let summary: (period: String, duration: String, total: String, average: String)
    var onSelectHistoryDay: (PushupHistoryDay) -> Void
    var onSignOut: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    activitiesHeader
                    segmentedControl
                    summaryCards
                    ActivitiesChart(histories: histories)
                    historyList
                }
                .padding(24)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Activities")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive, action: onSignOut) {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 36, height: 36)
                            .overlay(Image(systemName: "person.crop.circle").foregroundColor(.orange))
                    }
                }
            }
        }
    }

    private var activitiesHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Activities")
                .font(.largeTitle.bold())
            Text("Keep your streak glowing.")
                .foregroundStyle(.secondary)
        }
    }

    private var segmentedControl: some View {
        Picker("", selection: $selectedRange) {
            ForEach(ActivityRange.allCases) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }

    private var summaryCards: some View {
        let labels = ["Duration", "Total", "Avg / Day"]
        let values = [summary.duration, summary.total, summary.average]
        return VStack(alignment: .leading, spacing: 8) {
            Text(summary.period)
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            HStack(spacing: 12) {
                ForEach(0..<labels.count, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(labels[index])
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Text(values[index])
                            .font(.title2.bold())
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(UIColor.secondarySystemBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
                    )
                }
            }
        }
    }

    private var historyList: some View {
        let limitedHistories = Array(histories.prefix(14))
        return VStack(alignment: .leading, spacing: 12) {
            Text("Recent sessions")
                .font(.headline)
            ForEach(limitedHistories) { day in
                Button {
                    onSelectHistoryDay(day)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(day.date.formatted(.dateTime.weekday(.abbreviated).month().day()))
                                .font(.headline)
                            if day.notesAvailable {
                                Label("Notes added", systemImage: "note.text")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Text("\(day.total)")
                            .font(.title2.bold())
                            .foregroundStyle(Color.orange)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color(UIColor.secondarySystemBackground))
                            .shadow(color: Color.black.opacity(0.04), radius: 12, y: 6)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct ActivitiesChart: View {
    let histories: [PushupHistoryDay]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress")
                .font(.headline)
            Chart {
                ForEach(histories.sorted { $0.date < $1.date }) { day in
                    BarMark(
                        x: .value("Date", day.date, unit: .day),
                        y: .value("Push-ups", day.total)
                    )
                    .cornerRadius(8)
                    .foregroundStyle(Color.orange.gradient)
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 7)) { value in
                    AxisGridLine()
                    AxisValueLabel(centered: true, anchor: .center) {
                        if let date = value.as(Date.self) {
                            Text(date.formatted(.dateTime.weekday(.narrow)))
                        }
                    }
                }
            }
            .frame(height: 200)
            .background(RoundedRectangle(cornerRadius: 24).fill(Color(UIColor.secondarySystemBackground)))
            .shadow(color: Color.black.opacity(0.04), radius: 12, y: 6)
        }
    }
}

// MARK: - Insights

struct InsightsView: View {
    let insights: MonthlyInsights

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                hero
                MonthlyLineChart(dailyTotals: insights.dailyTotals)
                insightsCards
            }
            .padding(24)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Monthly Recap")
                    .font(.largeTitle.bold())
                Text(insights.month.formatted(.dateTime.month(.wide).year()))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            ShareLink(item: shareMessage) {
                Label("Share", systemImage: "square.and.arrow.up")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nice! You met your push-up target on \(insights.activeDays) days.")
                .font(.headline)
            Text("\(insights.activeDays)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
            Text("September: \(insights.previousMonthActiveDays) days")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(LinearGradient(colors: [Color.green.opacity(0.3), Color.blue.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
        )
    }

    private var insightsCards: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                InsightCard(title: "Longest streak", value: "\(insights.longestStreak) days", icon: "flame.fill", tint: .orange)
                InsightCard(title: "Avg active day", value: String(format: "%.0f", insights.averageOnActiveDays), icon: "chart.xyaxis.line", tint: .purple)
            }
            InsightCard(
                title: "Best day",
                value: insights.bestDay.map { "\($0.total) on " + $0.date.formatted(.dateTime.month(.abbreviated).day()) } ?? "Keep pushing",
                icon: "star.fill",
                tint: .yellow
            )
        }
    }

    private var shareMessage: String {
        "I logged \(insights.activeDays) active push-up days in \(insights.month.formatted(.dateTime.month(.wide)))! Best day hit \(insights.bestDay?.total ?? 0) push-ups 🔥"
    }
}

struct MonthlyLineChart: View {
    let dailyTotals: [DailyPushupTotal]
    private let targetRange: ClosedRange<Double> = 40...110

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily trend")
                .font(.headline)
            Chart {
                if let firstDate = dailyTotals.first?.date,
                   let lastDate = dailyTotals.last?.date {
                    RectangleMark(
                        xStart: .value("Start", firstDate),
                        xEnd: .value("End", lastDate),
                        yStart: .value("Target Min", targetRange.lowerBound),
                        yEnd: .value("Target Max", targetRange.upperBound)
                    )
                    .foregroundStyle(Color.green.opacity(0.2))
                }
                ForEach(dailyTotals.sorted { $0.date < $1.date }) { day in
                    LineMark(
                        x: .value("Day", day.date, unit: .day),
                        y: .value("Push-ups", day.total)
                    )
                    .interpolationMethod(.catmullRom)
                    PointMark(
                        x: .value("Day", day.date, unit: .day),
                        y: .value("Push-ups", day.total)
                    )
                    .foregroundStyle(Color.black)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 220)
            .padding()
            .background(RoundedRectangle(cornerRadius: 28).fill(Color(UIColor.secondarySystemBackground)))
            .shadow(color: Color.black.opacity(0.04), radius: 12, y: 6)
        }
    }
}

// MARK: - Components

struct AnimatedCountText: View {
    var value: Double
    var animation: Animation = .easeOut(duration: 0.8)
    @State private var displayValue: Double = 0

    var body: some View {
        Text("\(Int(displayValue))")
            .onChange(of: value) { newValue in
                withAnimation(animation) {
                    displayValue = newValue
                }
            }
            .onAppear {
                displayValue = value
            }
    }
}

struct FloatingAddButton: View {
    var action: () -> Void
    var title: String

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: "plus")
                .font(.headline)
                .padding(.horizontal, 22)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(LinearGradient(colors: [Color.orange, Color(red: 1.0, green: 0.6, blue: 0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                )
                .foregroundColor(.white)
                .shadow(color: Color.orange.opacity(0.3), radius: 10, y: 6)
        }
    }
}

struct InsightCard: View {
    var title: String
    var value: String
    var icon: String
    var tint: Color

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: icon)
                .frame(width: 44, height: 44)
                .background(Circle().fill(tint.opacity(0.2)))
                .foregroundColor(tint)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.title3.bold())
            }
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 24).fill(Color(UIColor.secondarySystemBackground)))
        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 6)
    }
}

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.footnote)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.8))
            )
            .foregroundColor(.white)
            .padding(.horizontal)
    }
}

struct AddPushupSheet: View {
    @Binding var form: PushupEntryForm
    var isEditing: Bool
    var onDismiss: () -> Void
    var onSave: (PushupEntryForm) async -> Bool
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Capsule()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)
                Form {
                    Section("Push-ups") {
                        Stepper(value: $form.count, in: 1...1000) {
                            Text("\(form.count) reps")
                        }
                    }
                    Section("Date") {
                        DatePicker("Select date", selection: $form.date, displayedComponents: [.date])
                    }
                    Section("Notes") {
                        TextField("Optional notes", text: $form.notes, axis: .vertical)
                            .lineLimit(3)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle(isEditing ? "Edit Push-ups" : "Log Push-ups")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: {
                        onDismiss()
                    })
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isSaving ? "Saving…" : "Save") {
                        guard !isSaving else { return }
                        Task {
                            isSaving = true
                            let success = await onSave(form)
                            isSaving = false
                            if success { onDismiss() }
                        }
                    }
                    .disabled(!form.isValid || isSaving)
                }
            }
        }
        .presentationDetents([.fraction(0.45), .large])
    }
}

struct HistoryDetailSheet: View {
    let day: PushupHistoryDay
    var onEdit: (PushupEntry) -> Void
    var onDelete: (PushupEntry) -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(day.date.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                                .font(.headline)
                            Text("\(day.total) push-ups total")
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                }
                Section("Sets") {
                    ForEach(day.entries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(entry.count) reps")
                                .font(.headline)
                            if let notes = entry.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Text(entry.displayDate.formatted(.dateTime.hour().minute()))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .swipeActions {
                            Button("Delete", role: .destructive) {
                                onDelete(entry)
                            }
                            Button("Edit") {
                                onEdit(entry)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Details")
        }
    }
}

#Preview("Auth Flow") {
    AuthenticationView { _ in }
}

#Preview("Logged In") {
    AuthenticatedAppView(
        session: AuthSession(token: "demo-token", userId: "preview-user", email: "demo@example.com"),
        onSignOut: {}
    )
}
