//
//  RestTimerView.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import SwiftUI

struct RestTimerView: View {
    @Binding var seconds: Int
    @Binding var isRunning: Bool
    let onSkip: () -> Void
    
    private var progress: Double {
        let total = UserPreferences.shared.defaultRestTime
        return Double(total - seconds) / Double(total)
    }
    
    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            Text("Rest Timer")
                .font(.headline)
            
            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 12)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Theme.Gradients.primary, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.5), value: progress)
                
                TimerDisplay(time: TimeInterval(seconds), fontSize: 48)
            }
            .frame(width: 200, height: 200)
            
            HStack(spacing: Theme.Spacing.medium) {
                Button("+15s") {
                    seconds += 15
                }
                .buttonStyle(.bordered)
                
                Button("Skip Rest") {
                    onSkip()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(Theme.CornerRadius.large)
        .shadow(color: Color.black.opacity(0.2), radius: 10, y: 5)
    }
}

struct TimerDisplay: View {
    let time: TimeInterval
    var fontSize: CGFloat = 48
    
    private var formattedTime: String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    var body: some View {
        Text(formattedTime)
            .font(.system(size: fontSize, weight: .bold, design: .monospaced))
            .foregroundColor(.primary)
    }
}