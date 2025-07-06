//
//  ProfileView.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var userPreferences: UserPreferences
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading) {
                            Text("Workout Enthusiast")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("Member since \(Date().formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical)
                }
                
                Section("Preferences") {
                    HStack {
                        Label("Weight Unit", systemImage: "scalemass")
                        Spacer()
                        Picker("Weight Unit", selection: $userPreferences.weightUnit) {
                            ForEach(UserPreferences.WeightUnit.allCases, id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    HStack {
                        Label("Default Rest Time", systemImage: "timer")
                        Spacer()
                        Text("\(userPreferences.defaultRestTime)s")
                            .foregroundColor(.secondary)
                    }
                    
                    Toggle("Auto-start Rest Timer", isOn: $userPreferences.autoStartRestTimer)
                    Toggle("Play Timer Sound", isOn: $userPreferences.playTimerSound)
                    Toggle("Haptic Feedback", isOn: $userPreferences.enableHaptics)
                }
                
                Section("Appearance") {
                    Picker("Theme", selection: $userPreferences.appTheme) {
                        ForEach(UserPreferences.AppTheme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                }
                
                Section {
                    Button("Settings") {
                        showingSettings = true
                    }
                    
                    Button("Export Data") {
                        // Export functionality
                    }
                    
                    Button("About") {
                        // About screen
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Data") {
                    Button("Export Workouts") {
                        // Export functionality
                    }
                    
                    Button("Import Workouts") {
                        // Import functionality
                    }
                    
                    Button("Clear All Data", role: .destructive) {
                        // Clear data functionality
                    }
                }
                
                Section("Support") {
                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
                    Link("Contact Support", destination: URL(string: "mailto:support@example.com")!)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}