import SwiftUI

// MARK: - Color Extensions

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Extensions

extension View {
    /// Apply rounded corners to specific corners
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    /// Apply a shadow with preset values optimized for cards
    func cardShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    /// Apply standard card styling
    func cardStyle(cornerRadius: CGFloat = 15) -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(cornerRadius)
            .cardShadow()
    }
    
    /// Apply a bordered card style
    func borderedCardStyle(cornerRadius: CGFloat = 15) -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
            .cardShadow()
    }
    
    /// Apply a button style consistent with the app's design
    func primaryButtonStyle() -> some View {
        self
            .padding()
            .background(Color(hex: "5CBDB9"))
            .foregroundColor(.white)
            .cornerRadius(20)
            .padding(.horizontal)
    }
    
    /// Apply a secondary button style
    func secondaryButtonStyle() -> some View {
        self
            .padding()
            .background(Color(.systemGray6))
            .foregroundColor(Color(hex: "3A366E"))
            .cornerRadius(20)
            .padding(.horizontal)
    }
}

// MARK: - Shape Utilities

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Date Extensions

extension Date {
    /// Format date to standard app format
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        return formatter.string(from: self)
    }
    
    /// Format date to "MMM d" format (e.g. "Feb 21")
    func toShortMonthDay() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }
    
    /// Format date to weekday abbreviation (e.g. "Mon")
    func toWeekdayAbbreviation() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: self)
    }
    
    /// Format time to 12-hour format (e.g. "11:30 PM")
    func toTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: self)
    }
}

// MARK: - String Extensions

extension String {
    /// Capitalize first letter of the string
    var capitalizedFirst: String {
        return prefix(1).capitalized + dropFirst()
    }
}

// MARK: - App Theme

struct AppTheme {
    // Colors
    static let primary = Color(hex: "3A366E")
    static let secondary = Color(hex: "5CBDB9")
    static let accent = Color(hex: "B8B5E1")
    static let background = Color(hex: "F8F9FF")
    static let warning = Color(hex: "FF9500")
    static let success = Color.green
    
    // Sleep stage colors
    static let coreColor = Color(hex: "B8B5E1")
    static let deepColor = Color(hex: "3A366E")
    static let remColor = Color(hex: "5CBDB9")
    static let awakeColor = Color(hex: "FFD485")
    
    // Spacing
    static let spacing: CGFloat = 15
    static let smallSpacing: CGFloat = 8
    static let largeSpacing: CGFloat = 25
    
    // Corner radius
    static let cornerRadius: CGFloat = 15
    static let buttonCornerRadius: CGFloat = 20
    static let smallCornerRadius: CGFloat = 10
}
