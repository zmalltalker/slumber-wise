import SwiftUI

struct SleepStatsView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Weekly overview card
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Last 7 Days")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Quick stats
                        HStack(spacing: 15) {
                            sleepStatItem(title: "Avg. Sleep", value: "6.8h", icon: "clock")
                            sleepStatItem(title: "Sleep Score", value: "82", icon: "chart.bar")
                            sleepStatItem(title: "Deep Sleep", value: "17%", icon: "moon.fill")
                        }
                        .padding(.horizontal)
                        
                        Divider()
                            .padding(.vertical, 5)
                        
                        // Sleep chart
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Sleep Duration")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            // Mock sleep chart
                            HStack(alignment: .bottom, spacing: 8) {
                                ForEach(0..<7, id: \.self) { day in
                                    VStack(spacing: 5) {
                                        // Bar chart with stacked components
                                        sleepBar(day: day)
                                        
                                        // Day label
                                        Text(dayLabel(offset: 6 - day))
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .frame(height: 150)
                            .padding(.bottom)
                        }
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // Sleep breakdown
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Sleep Breakdown")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Pie chart
                        ZStack {
                            // This is a simplistic representation
                            Circle()
                                .trim(from: 0, to: 0.45)
                                .stroke(Color(hex: "3A366E"), lineWidth: 25)
                                .rotationEffect(.degrees(-90))
                            
                            Circle()
                                .trim(from: 0.45, to: 0.65)
                                .stroke(Color(hex: "5CBDB9"), lineWidth: 25)
                                .rotationEffect(.degrees(-90))
                            
                            Circle()
                                .trim(from: 0.65, to: 0.95)
                                .stroke(Color(hex: "B8B5E1"), lineWidth: 25)
                                .rotationEffect(.degrees(-90))
                            
                            Circle()
                                .trim(from: 0.95, to: 1)
                                .stroke(Color(hex: "FFD485"), lineWidth: 25)
                                .rotationEffect(.degrees(-90))
                        }
                        .frame(height: 200)
                        .padding(.vertical)
                        
                        // Legend
                        VStack(spacing: 10) {
                            legendItem(color: Color(hex: "3A366E"), label: "Core Sleep", value: "45%")
                            legendItem(color: Color(hex: "5CBDB9"), label: "REM Sleep", value: "20%")
                            legendItem(color: Color(hex: "B8B5E1"), label: "Deep Sleep", value: "30%")
                            legendItem(color: Color(hex: "FFD485"), label: "Awake", value: "5%")
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // Sleep trends
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Sleep Trends")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack {
                            trendItem(label: "Bedtime", value: "11:38 PM", change: "-12 min", improved: true)
                            Divider()
                            trendItem(label: "Wake time", value: "6:42 AM", change: "+5 min", improved: false)
                        }
                        .padding()
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Sleep Stats")
        }
    }
    
    private func sleepStatItem(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "5CBDB9"))
                .font(.title3)
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private func sleepBar(day: Int) -> some View {
        // Generate random but consistent bar heights for demo
        let seed = day * 10
        let deep = CGFloat(35 + (seed % 20))
        let rem = CGFloat(25 + ((seed + 5) % 15))
        let core = CGFloat(100 + ((seed + 10) % 50))
        let awake = CGFloat(5 + (seed % 10))
        
        return VStack(spacing: 0) {
            // Awake
            Rectangle()
                .fill(Color(hex: "FFD485"))
                .frame(width: 22, height: awake)
            
            // Core
            Rectangle()
                .fill(Color(hex: "B8B5E1"))
                .frame(width: 22, height: core)
            
            // REM
            Rectangle()
                .fill(Color(hex: "5CBDB9"))
                .frame(width: 22, height: rem)
            
            // Deep
            Rectangle()
                .fill(Color(hex: "3A366E"))
                .frame(width: 22, height: deep)
        }
        .cornerRadius(4)
    }
    
    private func dayLabel(offset: Int) -> String {
        let date = Calendar.current.date(byAdding: .day, value: -offset, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    private func legendItem(color: Color, label: String, value: String) -> some View {
        HStack {
            Rectangle()
                .fill(color)
                .frame(width: 14, height: 14)
                .cornerRadius(2)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
    
    private func trendItem(label: String, value: String, change: String, improved: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            
            HStack(spacing: 4) {
                Image(systemName: improved ? "arrow.down" : "arrow.up")
                    .font(.caption)
                    .foregroundColor(improved ? .green : .orange)
                
                Text(change)
                    .font(.caption)
                    .foregroundColor(improved ? .green : .orange)
                
                Text("vs last week")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

struct SleepStatsView_Previews: PreviewProvider {
    static var previews: some View {
        SleepStatsView()
            .environmentObject(AppState())
    }
}
