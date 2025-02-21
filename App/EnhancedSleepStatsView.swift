import SwiftUI
import Charts

struct EnhancedSleepStatsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTimeRange: TimeRange = .week
    @State private var isRefreshing = false
    
    enum TimeRange: String, CaseIterable, Identifiable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
        
        var id: String { self.rawValue }
        
        var days: Int {
            switch self {
            case .day: return 1
            case .week: return 7
            case .month: return 30
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    timeRangePicker
                    
                    if appState.isLoadingSleepData {
                        loadingView
                    } else if appState.sleepData.isEmpty {
                        emptyStateView
                    } else {
                        // Sleep overview
                        sleepScoreCard
                        
                        // Sleep duration chart
                        sleepDurationChart
                        
                        // Sleep stages
                        sleepStagesBreakdown
                        
                        // Sleep trends
                        sleepTrendsCard
                    }
                }
                .padding(.vertical)
                .refreshable {
                    await refreshData()
                }
            }
            .navigationTitle("Sleep Stats")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if appState.healthKitService.isAuthorized {
                        Button(action: {
                            Task {
                                await refreshData()
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                        }
                        .disabled(appState.isLoadingSleepData)
                        .opacity(appState.isLoadingSleepData ? 0.5 : 1)
                    }
                }
            }
        }
    }
    
    // MARK: - Component Views
    
    private var timeRangePicker: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
        .onChange(of: selectedTimeRange) { newValue in
            Task {
                await refreshData()
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            LoadingSpinner(color: Color(hex: "5CBDB9"), size: 50)
            Text("Loading sleep data...")
                .foregroundColor(.secondary)
        }
        .frame(height: 300)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "moon.zzz")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .foregroundColor(Color(hex: "3A366E"))
            
            Text("No Sleep Data Available")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("We couldn't find any sleep data for this period. Try adding sleep data in the Health app or switch to a different time range.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
        }
        .frame(height: 300)
    }
    
    private var sleepScoreCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Sleep Score")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(alignment: .top, spacing: 15) {
                // Sleep score circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(appState.sleepScore) / 100)
                        .stroke(scoreColor, lineWidth: 10)
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 2) {
                        Text("\(appState.sleepScore)")
                            .font(.system(size: 32, weight: .bold))
                        
                        Text("/ 100")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                
                VStack(alignment: .leading, spacing: 15) {
                    // Average metrics
                    summaryMetric(
                        title: "Avg. Sleep Duration",
                        value: appState.averageSleepTime,
                        icon: "clock.fill",
                        color: Color(hex: "5CBDB9")
                    )
                    
                    summaryMetric(
                        title: "Deep Sleep",
                        value: appState.deepSleepPercentage,
                        icon: "moon.fill",
                        color: Color(hex: "3A366E")
                    )
                }
                .padding(.vertical)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    private var sleepDurationChart: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Sleep Duration")
                .font(.headline)
                .padding(.horizontal)
            
            if selectedTimeRange == .day && !filteredSleepData.isEmpty {
                // Special view for single day - show duration with text instead
                let day = filteredSleepData[0]
                VStack(spacing: 25) {
                    Text(day.formatTotalSleepTime())
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Color(hex: "5CBDB9"))
                    
                    HStack(spacing: 20) {
                        stageTimeItem(label: "Deep", minutes: day.deepSleepMinutes, color: Color(hex: "3A366E"))
                        stageTimeItem(label: "REM", minutes: day.remSleepMinutes, color: Color(hex: "5CBDB9"))
                        stageTimeItem(label: "Core", minutes: day.coreSleepMinutes, color: Color(hex: "B8B5E1"))
                        stageTimeItem(label: "Awake", minutes: day.totalAwakeMinutes, color: Color(hex: "FFD485"))
                    }
                    
                    HStack {
                        Text("Last night:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(day.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                .frame(height: 180)
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                // SwiftUI Chart for week/month
                Chart {
                    ForEach(filteredSleepData) { day in
                        let date = day.date
                        let totalMinutes = day.totalSleepMinutes
                        let hours = totalMinutes / 60
                        
                        BarMark(
                            x: .value("Date", date, unit: .day),
                            y: .value("Hours", hours)
                        )
                        .foregroundStyle(Color(hex: "5CBDB9"))
                        .cornerRadius(6)
                    }
                    
                    // Target line
                    RuleMark(y: .value("Target", 8))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        .foregroundStyle(Color.secondary)
                        .annotation(position: .trailing) {
                            Text("Target")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel("\(value.index * 2)h")
                    }
                }
                .frame(height: 180)
                .padding()
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    private func stageTimeItem(label: String, minutes: Double, color: Color) -> some View {
        VStack(spacing: 5) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(formatMinutes(minutes))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
        }
    }
    
    private func formatMinutes(_ minutes: Double) -> String {
        let hours = Int(minutes) / 60
        let mins = Int(minutes) % 60
        
        if hours > 0 {
            return "\(hours)h \(mins)m"
        } else {
            return "\(mins)m"
        }
    }
    
    private var sleepStagesBreakdown: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Sleep Stages")
                .font(.headline)
                .padding(.horizontal)
            
            if selectedTimeRange == .day {
                if let day = appState.sleepData.first {
                    // For single day view, we'll show a more detailed stage breakdown
                    VStack(spacing: 15) {
                        pieChartView(for: day)
                            .frame(height: 200)
                            .padding(.top)
                        
                        // Legend with more details for single day
                        VStack(spacing: 12) {
                            detailedLegendItem(
                                color: Color(hex: "3A366E"),
                                label: "Deep Sleep",
                                value: "\(Int(day.deepSleepPercentage))%",
                                detail: formatMinutes(day.deepSleepMinutes)
                            )
                            
                            detailedLegendItem(
                                color: Color(hex: "5CBDB9"),
                                label: "REM Sleep",
                                value: "\(Int(day.remSleepPercentage))%",
                                detail: formatMinutes(day.remSleepMinutes)
                            )
                            
                            detailedLegendItem(
                                color: Color(hex: "B8B5E1"),
                                label: "Core Sleep",
                                value: "\(Int(100 - day.deepSleepPercentage - day.remSleepPercentage - day.totalAwakeMinutes / (day.totalSleepMinutes + day.totalAwakeMinutes) * 100))%",
                                detail: formatMinutes(day.coreSleepMinutes)
                            )
                            
                            detailedLegendItem(
                                color: Color(hex: "FFD485"),
                                label: "Awake",
                                value: "\(Int(day.totalAwakeMinutes / (day.totalSleepMinutes + day.totalAwakeMinutes) * 100))%",
                                detail: formatMinutes(day.totalAwakeMinutes)
                            )
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
            } else {
                // For week/month view, we keep the simpler view
                if let day = appState.sleepData.first {
                    VStack(spacing: 20) {
                        // Pie chart
                        pieChartView(for: day)
                            .frame(height: 200)
                            .padding(.top)
                        
                        // Legend
                        VStack(spacing: 8) {
                            legendItem(color: Color(hex: "3A366E"), label: "Deep Sleep", value: "\(Int(day.deepSleepPercentage))%")
                            legendItem(color: Color(hex: "5CBDB9"), label: "REM Sleep", value: "\(Int(day.remSleepPercentage))%")
                            legendItem(color: Color(hex: "B8B5E1"), label: "Core Sleep", value: "\(Int(100 - day.deepSleepPercentage - day.remSleepPercentage - day.totalAwakeMinutes / (day.totalSleepMinutes + day.totalAwakeMinutes) * 100))%")
                            legendItem(color: Color(hex: "FFD485"), label: "Awake", value: "\(Int(day.totalAwakeMinutes / (day.totalSleepMinutes + day.totalAwakeMinutes) * 100))%")
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    private func detailedLegendItem(color: Color, label: String, value: String, detail: String) -> some View {
        HStack {
            Rectangle()
                .fill(color)
                .frame(width: 14, height: 14)
                .cornerRadius(2)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(detail)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var sleepTrendsCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Sleep Trends")
                .font(.headline)
                .padding(.horizontal)
            
            if selectedTimeRange == .day {
                // For day view, show detailed sleep session metrics instead of trends
                if let day = filteredSleepData.first {
                    VStack(spacing: 20) {
                        HStack(spacing: 24) {
                            metricCard(
                                title: "Sleep Efficiency",
                                value: "\(Int(day.sleepEfficiency))%",
                                icon: "bed.double.fill",
                                color: Color(hex: "5CBDB9")
                            )
                            
                            metricCard(
                                title: "Deep Sleep",
                                value: "\(Int(day.deepSleepPercentage))%",
                                icon: "moon.fill",
                                color: Color(hex: "3A366E")
                            )
                        }
                        
                        HStack(spacing: 24) {
                            metricCard(
                                title: "REM Sleep",
                                value: "\(Int(day.remSleepPercentage))%",
                                icon: "sparkles",
                                color: Color(hex: "B8B5E1")
                            )
                            
                            metricCard(
                                title: "Time Awake",
                                value: formatMinutes(day.totalAwakeMinutes),
                                icon: "eye.fill",
                                color: Color(hex: "FFD485")
                            )
                        }
                    }
                    .padding()
                }
            } else {
                // Average sleep time trends
                Chart {
                    ForEach(filteredSleepData) { day in
                        LineMark(
                            x: .value("Date", day.date, unit: .day),
                            y: .value("Efficiency", day.sleepEfficiency)
                        )
                        .foregroundStyle(Color(hex: "5CBDB9"))
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("Date", day.date, unit: .day),
                            y: .value("Efficiency", day.sleepEfficiency)
                        )
                        .foregroundStyle(Color(hex: "5CBDB9"))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel("\(value.index * 20)%")
                    }
                }
                .frame(height: 180)
                .padding()
                
                Text("Sleep Efficiency")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    private func metricCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Components
    
    @ViewBuilder
    private func pieChartView(for day: SleepDay) -> some View {
        Chart {
            SectorMark(
                angle: .value("Deep", day.deepSleepMinutes),
                innerRadius: .ratio(0.5),
                angularInset: 1.5
            )
            .cornerRadius(3)
            .foregroundStyle(Color(hex: "3A366E"))
            
            SectorMark(
                angle: .value("REM", day.remSleepMinutes),
                innerRadius: .ratio(0.5),
                angularInset: 1.5
            )
            .cornerRadius(3)
            .foregroundStyle(Color(hex: "5CBDB9"))
            
            SectorMark(
                angle: .value("Core", day.coreSleepMinutes),
                innerRadius: .ratio(0.5),
                angularInset: 1.5
            )
            .cornerRadius(3)
            .foregroundStyle(Color(hex: "B8B5E1"))
            
            SectorMark(
                angle: .value("Awake", day.totalAwakeMinutes),
                innerRadius: .ratio(0.5),
                angularInset: 1.5
            )
            .cornerRadius(3)
            .foregroundStyle(Color(hex: "FFD485"))
        }
        .padding()
    }
    
    private func summaryMetric(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 16))
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.headline)
            }
        }
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
    
    // MARK: - Helper Properties
    
    private var filteredSleepData: [SleepDay] {
        if selectedTimeRange == .day {
            // For day view, only show the most recent sleep session
            if let mostRecentSleep = appState.sleepData.first {
                return [mostRecentSleep]
            }
            return []
        } else {
            // For week/month view, return the appropriate number of days
            return appState.sleepData.prefix(selectedTimeRange.days).reversed()
        }
    }
    
    private var scoreColor: Color {
        switch appState.sleepScore {
        case 0..<60: return .orange
        case 60..<80: return .yellow
        default: return Color(hex: "5CBDB9")
        }
    }
    
    // MARK: - Actions
    
    private func refreshData() async {
        isRefreshing = true
        if appState.healthKitService.isAuthorized {
            await appState.loadSleepData(days: selectedTimeRange.days)
        }
        isRefreshing = false
    }
}

// MARK: - Preview

struct EnhancedSleepStatsView_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedSleepStatsView()
            .environmentObject(AppState())
    }
}
