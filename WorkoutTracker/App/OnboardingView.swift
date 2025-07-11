//
//  OnboardingView.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    
    let pages: [(title: String, subtitle: String, icon: String, color: Color)] = [
        (
            "Welcome to Workout Tracker",
            "Your personal fitness companion",
            "figure.strengthtraining.traditional",
            Theme.Colors.primary
        ),
        (
            "Track Your Workouts",
            "Log exercises, sets, and monitor your progress",
            "dumbbell",
            Theme.Colors.chest
        ),
        (
            "View Statistics",
            "Analyze your performance with detailed insights",
            "chart.line.uptrend.xyaxis",
            Theme.Colors.success
        ),
        (
            "Ready to Start",
            "Let's begin your fitness journey!",
            "checkmark.circle.fill",
            Theme.Colors.primary
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("Skip") {
                    completeOnboarding()
                }
                .foregroundColor(.secondary)
                .padding()
            }
            
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPage(
                        title: pages[index].title,
                        subtitle: pages[index].subtitle,
                        icon: pages[index].icon,
                        color: pages[index].color
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Theme.Colors.primary : Color.secondary.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: currentPage)
                }
            }
            .padding()
            
            Button(action: {
                if currentPage < pages.count - 1 {
                    withAnimation {
                        currentPage += 1
                    }
                } else {
                    completeOnboarding()
                }
            }) {
                Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                    .fontWeight(.medium)
            }
            .primaryButton()
            .padding(.horizontal)
            .padding(.bottom, 50)
        }
    }
    
    private func completeOnboarding() {
        hasCompletedOnboarding = true
        HapticManager.shared.notification(.success)
        isPresented = false
    }
}

struct OnboardingPage: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xLarge) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 100))
                .foregroundColor(color)
                .padding()
                .background(
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 200, height: 200)
                )
            
            VStack(spacing: Theme.Spacing.medium) {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.xLarge)
            }
            
            Spacer()
            Spacer()
        }
    }
}