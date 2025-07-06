import SwiftUI

extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(Theme.CornerRadius.medium)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    func primaryButton() -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Theme.Colors.primary)
            .cornerRadius(Theme.CornerRadius.medium)
    }
}
