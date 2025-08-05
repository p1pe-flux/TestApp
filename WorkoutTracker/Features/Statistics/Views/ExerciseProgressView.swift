//
//  ExerciseProgressView.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 7/7/25.
//


//
//  ExerciseProgressView.swift
//  WorkoutTracker
//
//  Vista para mostrar el progreso histórico de un ejercicio
//

import SwiftUI

struct ExerciseProgressView: View {
    let exercise: Exercise
    @StateObject private var viewModel: ExerciseProgressViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(exercise: Exercise) {
        self.exercise = exercise
        _viewModel = StateObject(wrappedValue: ExerciseProgressViewModel(
            exercise: exercise,
            context: exercise.managedObjectContext ?? PersistenceController.shared.container.viewContext
        ))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Theme.Spacing.large) {
                    exerciseHeader
                    
                    if viewModel.isLoading {
                        LoadingView(message: "Cargando historial...")
                    } else if viewModel.recentWorkouts.isEmpty {
                        emptyState
                    } else {
                        progressComparison
                    }
                }
                .padding()
            }
            .navigationTitle("Progreso del Ejercicio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
        .onAppear {
            viewModel.loadRecentWorkouts()
        }
    }
    
    private var exerciseHeader: some View {
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
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(Theme.CornerRadius.medium)
    }
    
    private var emptyState: some View {
        EmptyStateView(
            icon: "chart.line.uptrend.xyaxis",
            title: "Sin historial",
            message: "Aún no has realizado este ejercicio en ningún entrenamiento"
        )
    }
    
    private var progressComparison: some View {
        VStack(spacing: Theme.Spacing.large) {
            // Resumen de progreso
            progressSummary
            
            // Comparación de las últimas 3 sesiones
            Text("Últimas \(viewModel.recentWorkouts.count) sesiones")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(Array(viewModel.recentWorkouts.enumerated()), id: \.element.id) { index, workoutData in
                WorkoutSessionCard(
                    workoutData: workoutData,
                    sessionNumber: index + 1,
                    isLatest: index == 0
                )
            }
        }
    }
    
    private var progressSummary: some View {
        VStack(spacing: Theme.Spacing.medium) {
            Text("Resumen de Progreso")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: Theme.Spacing.medium) {
                ProgressIndicatorCard(
                    title: "Peso Máximo",
                    currentValue: viewModel.latestMaxWeight,
                    previousValue: viewModel.previousMaxWeight,
                    unit: UserPreferences.shared.weightUnit.rawValue,
                    icon: "scalemass"
                )
                
                ProgressIndicatorCard(
                    title: "Volumen Total",
                    currentValue: viewModel.latestTotalVolume,
                    previousValue: viewModel.previousTotalVolume,
                    unit: UserPreferences.shared.weightUnit.rawValue,
                    icon: "chart.bar.fill"
                )
            }
        }
    }
}

// MARK: - Componentes

struct WorkoutSessionCard: View {
    let workoutData: ExerciseWorkoutData
    let sessionNumber: Int
    let isLatest: Bool
    
    @State private var isExpanded = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            // Header
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            if isLatest {
                                Label("Más reciente", systemImage: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                            } else {
                                Text("Sesión \(sessionNumber)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Text(workoutData.workout.wrappedName)
                            .font(.headline)
                        
                        Text(workoutData.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(UserPreferences.shared.formatWeight(workoutData.maxWeight))
                            .font(.headline)
                            .foregroundColor(Theme.Colors.primary)
                        
                        Text("Peso máx.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .padding(.leading, 8)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Divider()
                
                // Sets detail
                VStack(spacing: Theme.Spacing.xSmall) {
                    ForEach(workoutData.sets) { setData in
                        SetComparisonRow(setData: setData)
                    }
                }
                
                // Summary
                HStack {
                    Label("\(workoutData.sets.count) sets", systemImage: "list.number")
                    
                    Spacer()
                    
                    Label("Vol: \(UserPreferences.shared.formatWeight(workoutData.totalVolume))", 
                          systemImage: "chart.bar")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, Theme.Spacing.xSmall)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .fill(isLatest ? Theme.Colors.primary.opacity(0.1) : Color(UIColor.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .stroke(isLatest ? Theme.Colors.primary.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
}

struct SetComparisonRow: View {
    let setData: SetData
    
    var body: some View {
        HStack {
            Text("Set \(setData.setNumber)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .leading)
            
            HStack(spacing: 4) {
                Text(UserPreferences.shared.formatWeight(setData.weight))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("×")
                    .foregroundColor(.secondary)
                
                Text("\(setData.reps)")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            if setData.isPersonalRecord {
                Text("PR")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Theme.Colors.success)
                    .cornerRadius(4)
            }
            
            Text("= \(Int(setData.volume))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ProgressIndicatorCard: View {
    let title: String
    let currentValue: Double
    let previousValue: Double?
    let unit: String
    let icon: String
    
    private var percentageChange: Double? {
        guard let previousValue = previousValue, previousValue > 0 else { return nil }
        return ((currentValue - previousValue) / previousValue) * 100
    }
    
    private var changeColor: Color {
        guard let change = percentageChange else { return .secondary }
        return change >= 0 ? Theme.Colors.success : Theme.Colors.error
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text("\(Int(currentValue)) \(unit)")
                .font(.title3)
                .fontWeight(.bold)
            
            if let change = percentageChange {
                HStack(spacing: 4) {
                    Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption2)
                    
                    Text("\(abs(Int(change)))%")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(changeColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(Theme.CornerRadius.small)
    }
}