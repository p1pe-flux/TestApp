//
//  TimeEditorView.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 4/8/25.
//


//
//  TimeEditorView.swift
//  WorkoutTracker
//
//  Vista para editar manualmente el tiempo del workout
//

import SwiftUI

struct TimeEditorView: View {
    @Binding var time: TimeInterval
    @Environment(\.dismiss) private var dismiss
    
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: Theme.Spacing.large) {
                Text("Adjust Workout Time")
                    .font(.headline)
                    .padding(.top)
                
                HStack(spacing: Theme.Spacing.medium) {
                    TimePickerColumn(
                        value: $hours,
                        range: 0...23,
                        label: "Hours"
                    )
                    
                    Text(":")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    TimePickerColumn(
                        value: $minutes,
                        range: 0...59,
                        label: "Minutes"
                    )
                    
                    Text(":")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    TimePickerColumn(
                        value: $seconds,
                        range: 0...59,
                        label: "Seconds"
                    )
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(Theme.CornerRadius.medium)
                
                Text("Set the actual time you've been working out")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Edit Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        time = TimeInterval(hours * 3600 + minutes * 60 + seconds)
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
            .onAppear {
                let totalSeconds = Int(time)
                hours = totalSeconds / 3600
                minutes = (totalSeconds % 3600) / 60
                seconds = totalSeconds % 60
            }
        }
    }
}

struct TimePickerColumn: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let label: String
    
    var body: some View {
        VStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Picker(label, selection: $value) {
                ForEach(range, id: \.self) { number in
                    Text(String(format: "%02d", number))
                        .tag(number)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: 70, height: 100)
        }
    }
}