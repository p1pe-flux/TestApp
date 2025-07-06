//
//  FloatingActionButton.swift
//  WorkoutTracker
//
//  Created by Felipe Guasch on 6/7/25.
//


import SwiftUI

struct FloatingActionButton: View {
    @State private var isExpanded = false
    let primaryAction: () -> Void
    let secondaryActions: [(icon: String, action: () -> Void)]
    
    var body: some View {
        VStack(spacing: 16) {
            if isExpanded {
                ForEach(secondaryActions.indices, id: \.self) { index in
                    Button(action: {
                        secondaryActions[index].action()
                        isExpanded = false
                    }) {
                        Image(systemName: secondaryActions[index].icon)
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Theme.Colors.primary.opacity(0.8))
                            .clipShape(Circle())
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            
            Button(action: {
                if isExpanded {
                    isExpanded = false
                } else if secondaryActions.isEmpty {
                    primaryAction()
                } else {
                    withAnimation(.spring()) {
                        isExpanded = true
                    }
                }
            }) {
                Image(systemName: isExpanded ? "xmark" : "plus")
                    .font(.title2)
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(isExpanded ? 45 : 0))
                    .frame(width: 56, height: 56)
                    .background(Theme.Gradients.primary)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
        }
    }
}