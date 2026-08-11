import SwiftUI

private let brandBarGradient = LinearGradient(
    colors: [
        Color(red: 0.99, green: 0.58, blue: 0.27),
        Color(red: 0.92, green: 0.30, blue: 0.32)
    ],
    startPoint: .leading,
    endPoint: .trailing
)

extension View {
    func brandedNavigationBar() -> some View {
        self
            .toolbarBackground(brandBarGradient, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

struct BrandedTitle: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 20, weight: .heavy, design: .rounded))
            .tracking(0.4)
            .foregroundStyle(.white)
    }
}
