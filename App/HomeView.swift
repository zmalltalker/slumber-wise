import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @State private var animateCompletion = false
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Date header
                    Text(formattedDate())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if let challenge = appState.todaysChallenge {
                        // Challenge Card
                        VStack(alignment: .leading, spacing: 0) {
                            // Sleep Summary Section
                            VStack(alignment: .leading, spacing: 4) {
                                Text("SLEEP SUMMARY")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                if appState.isLoadingSleepData {
                                    HStack {
                                        Text("Loading sleep data...")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        LoadingSpinner(lineWidth: 2, size: 16)
                                    }
                                } else {
                                    Text(appState.todaySleepSummary)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(15, corners: [.topLeft, .topRight])
                            
                            // Challenge Content
                            VStack(alignment: .leading, spacing: 15) {
                                Text(challenge.challengeName)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text(challenge.category)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                
                                Text(challenge.challengeDescription)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 5)
                                
                                if challenge.completed {
                                    completedView
                                } else if challenge.isAccepted {
                                    Button(action: {
                                        withAnimation {
                                            animateCompletion = true
                                            appState.completeChallenge(challenge)
                                        }
                                    }) {
                                        Text("Complete Challenge")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color(hex: "5CBDB9"))
                                            .cornerRadius(20)
                                    }
                                    .padding(.top, 10)
                                } else {
                                    Button(action: {
                                        appState.acceptChallenge(challenge)
                                    }) {
                                        Text("Accept Challenge")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color(hex: "5CBDB9"))
                                            .cornerRadius(20)
                                    }
                                    .padding(.top, 10)
                                }
                            }
                            .padding()
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    } else {
                        // Empty state
                        VStack(spacing: 20) {
                            Image(systemName: "moon.zzz")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .foregroundColor(Color(hex: "3A366E"))
                            
                            Text("No Challenge Today")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("Check back tomorrow for your next sleep challenge")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                            
                            // New challenge button
                            Button(action: {
                                appState.pickRandomChallenge()
                            }) {
                                Text("Get New Challenge")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(hex: "5CBDB9"))
                                    .cornerRadius(20)
                            }
                            .padding(.top, 10)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                }
                .padding()
                .refreshable {
                    // Pull to refresh
                    isRefreshing = true
                    
                    // Refresh HealthKit data
                    if appState.healthKitService.isAuthorized {
                        await appState.loadSleepData()
                    }
                    
                    isRefreshing = false
                }
            }
            .navigationTitle("Today")
            .overlay(
                ZStack {
                    if animateCompletion {
                        Color.black.opacity(0.2)
                            .edgesIgnoringSafeArea(.all)
                        
                        ConfettiView()
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    animateCompletion = false
                                }
                            }
                    }
                }
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        // Health data refresh button
                        if appState.healthKitService.isAuthorized {
                            Button(action: {
                                Task {
                                    await appState.loadSleepData()
                                }
                            }) {
                                Image(systemName: "arrow.clockwise")
                            }
                            .disabled(appState.isLoadingSleepData)
                            .opacity(appState.isLoadingSleepData ? 0.5 : 1)
                        }
                        
                        // New challenge button
                        Button(action: {
                            appState.pickRandomChallenge()
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                    }
                }
            }
        }
    }
    
    private var completedView: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            
            Text("Challenge Completed")
                .font(.headline)
                .foregroundColor(.green)
            
            Spacer()
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(10)
    }
    
    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
}

// MARK: - Preview

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AppState())
    }
}
