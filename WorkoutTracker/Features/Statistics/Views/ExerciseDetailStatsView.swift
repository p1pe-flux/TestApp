//
//  ExerciseDetailStatsView.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import SwiftUI
import Charts

struct ExerciseDetailStatsView: View {
    let exercise: Exercise
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ExerciseStatsViewModel
    @State private var selectedMetric: MetricType = .weight
    @State private var selectedTimeRange: TimeRange = .month
    
    init(exercise: Exercise) {
        self.exercise = exercise
        _viewModel = StateObject(wrappedValue: ExerciseStatsViewModel(exercise: exercise))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Theme.Spacing.large) {
                    exerciseHeader
                    personalRecordsSection
                    timeRangeSelector
                    progressChart
                    statsOverview
                    recentPerformances
                }
                .padding()
            }
            .navigationTitle("Exercise Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                viewModel.loadStats(for: selectedTimeRange)
            }
        }
    }
    
    private var exerciseHeader: some View {
        VStack(spacing: Theme.Spacing.small) {
            HStack {
                Image(systemName: exercise.categoryEnum.systemImage)
                    .font(.largeTitle)
                    .foregroundColor(exercise.categoryEnum.color)
                
                VStack(alignment: .leading) {
                    Text(exercise.wrappedName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(exercise.wrappedCategory)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            if let lastPerformed = viewModel.lastPerformed {
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Last performed: \(lastPerformed.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(Theme.CornerRadius.medium)
    }
    
    private var personalRecordsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            Text("Personal Records")
                .font(.headline)
            
            HStack(spacing: Theme.Spacing.medium) {
                PRCard(
                    title: "Max Weight",
                    value: UserPreferences.shared.formatWeight(viewModel.personalRecords.maxWeight),
                    date: viewModel.personalRecords.maxWeightDate,
                    icon: "scalemass",
                    color: Theme.Colors.primary
                )
                
                PRCard(
                    title: "Max Volume",
                    value: UserPreferences.shared.formatWeight(viewModel.personalRecords.maxVolume),
                    date: viewModel.personalRecords.maxVolumeDate,
                    icon: "chart.bar.fill",
                    color: Theme.Colors.shoulders
                )
                
                PRCard(
                    title: "Max Reps",
                    value: "\(viewModel.personalRecords.maxReps)",
                    date: viewModel.personalRecords.maxRepsDate,
                    icon: "number",
                    color: Theme.Colors.success
                )
            }
        }
    }
    
    private var timeRangeSelector: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach([TimeRange.week, TimeRange.month, TimeRange.threeMonths], id: \.self) { range in
                Text(range.title).tag(range)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .onChange(of: selectedTimeRange) { _, newRange in
            viewModel.loadStats(for: newRange)
        }
    }
    
    @ViewBuilder
    private var progressChart: some View {
        if !viewModel.progressData.isEmpty {
            VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                HStack {
                    Text("Progress")
                        .font(.headline)
                    
                    Spacer()
                    
                    Picker("Metric", selection: $selectedMetric) {
                        ForEach(MetricType.allCases, id: \.self) { metric in
                            Text(metric.title).tag(metric)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .font(.caption)
                }
                
                Chart(viewModel.progressData.filter { $0.type == selectedMetric }) { data in
                    LineMark(
                        x: .value("Date", data.date),
                        y: .value(selectedMetric.title, data.value)
                    )
                    .foregroundStyle(Theme.Colors.primary)
                    .interpolationMethod(.catmullRom)
                    
                    PointMark(
                        x: .value("Date", data.date),
                        y: .value(selectedMetric.title, data.value)
                    )
                    .foregroundStyle(Theme.Colors.primary)
                }
                .frame(height: 250)
            }
            .cardStyle()
        }
    }
    
    private var statsOverview: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.medium) {
            StatCard(
                title: "Total Sets",
                value: "\(viewModel.totalSets)",
                icon: "list.bullet"
            )
            
            StatCard(
                title: "Total Reps",
                value: "\(viewModel.totalReps)",
                icon: "repeat"
            )
            
            StatCard(
                title: "Avg Weight",
                value: UserPreferences.shared.formatWeight(viewModel.averageWeight),
                icon: "scalemass"
            )
            
            StatCard(
                title: "Avg Reps",
                value: String(format: "%.1f", viewModel.averageReps),
                icon: "chart.line.uptrend.xyaxis"
            )
        }
    }
    
    @ViewBuilder
    private var recentPerformances: some View {
        if !viewModel.recentPerformances.isEmpty {
            VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                Text("Recent Performances")
                    .font(.headline)
                
                VStack(spacing: Theme.Spacing.small) {
                    ForEach(viewModel.recentPerformances) { performance in
                        PerformanceRow(performance: performance)
                        
                        if performance != viewModel.recentPerformances.last {
                            Divider()
                        }
                    }
                }
            }
            .cardStyle()
        }
    }
}

struct PRCard: View {
    let title: String
    let value: String
    let date: Date?
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            if let date = date {
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                .fill(color.opacity(0.1))
        )
    }
}

struct PerformanceRow: View {
    let performance: ExercisePerformance
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(performance.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Text("\(performance.totalSets) sets")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("Avg \(Int(performance.averageReps)) reps")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(UserPreferences.shared.formatWeight(performance.maxWeight))
                    .font(.headline)
                    .foregroundColor(Theme.Colors.primary)
                
                Text("Max weight")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, Theme.Spacing.xSmall)
    }
}

enum MetricType: String, CaseIterable {
    case weight = "Weight"
    case volume = "Volume"
    case reps = "Reps"
    
    var title: String { rawValue }
}

struct TimeRange {
    static let week = TimeRange(title: "Week", days: 7)
    static let month = TimeRange(title: "Month", days: 30)
    static let threeMonths = TimeRange(title: "3 Months", days: 90)
    
    let title: String
    let days: Int
}

// MARK: - Exercise Stats View Model

@MainActor
class ExerciseStatsViewModel: ObservableObject {
    @Published var personalRecords = PersonalRecords()
    @Published var progressData: [ProgressData] = []
    @Published var recentPerformances: [ExercisePerformance] = []
    @Published var totalSets = 0
    @Published var totalReps = 0
    @Published var averageWeight: Double = 0
    @Published var averageReps: Double = 0
    @Published var lastPerformed: Date?
    
    private let exercise: Exercise
    private let statisticsService: StatisticsService
    
    init(exercise: Exercise) {
        self.exercise = exercise
        self.statisticsService = StatisticsService(context: exercise.managedObjectContext ?? PersistenceController.shared.container.viewContext)
    }
    
    func loadStats(for timeRange: TimeRange) {
        Task {
            do {
                let stats = try statisticsService.getExerciseStats(for: exercise)
                self.totalSets = stats.totalSets
                self.totalReps = stats.totalReps
                self.averageWeight = stats.totalVolume / Double(stats.totalSets)
                self.averageReps = Double(stats.totalReps) / Double(stats.totalSets)
                
                // Load progress data and other stats...
            } catch {
                print("Error loading exercise stats: \(error)")
            }
        }
    }
}

struct PersonalRecords {
    var maxWeight: Double = 0
    var maxWeightDate: Date?
    var maxVolume: Double = 0
    var maxVolumeDate: Date?
    var maxReps: Int = 0
    var maxRepsDate: Date?
}

struct ExercisePerformance: Identifiable {
    let id = UUID()
    let date: Date
    let totalSets: Int
    let averageReps: Double
    let maxWeight: Double
}

struct ProgressData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let type: MetricType
}