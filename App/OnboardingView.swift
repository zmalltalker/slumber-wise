import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState
    @State private var currentPage = 0
    @State private var showingHealthPermission = false
    @State private var isRequestingPermission = false
    @State private var permissionGranted = false
    @State private var permissionError: String?
    
    var body: some View {
        if showingHealthPermission {
            healthKitPermissionView
        } else {
            mainOnboardingView
        }
    }
    
    // MARK: - Main Onboarding
    
    private var mainOnboardingView: some View {
        VStack {
            // Content pages
            TabView(selection: $currentPage) {
                onboardingPage(
                    title: "Welcome to SlumberWise",
                    subtitle: "Transform your sleep habits with personalized actions",
                    image: Image(.onboardingPageOne),
                    index: 0
                )
                
                onboardingPage(
                    title: "Sleep Insights",
                    subtitle: "We analyze your sleep data to find patterns and opportunities",
                    image: Image("Insights"),
                    index: 1
                )
                
                onboardingPage(
                    title: "Daily Challenges",
                    subtitle: "Get one personalized recommendation each day to improve your sleep",
                    image: Image("Challenges"),
                    index: 2
                )
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            // Navigation buttons
            HStack {
                if currentPage > 0 {
                    Button("Back") {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                if currentPage < 2 {
                    Button("Next") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .padding()
                } else {
                    Button("Continue") {
                        // Go to HealthKit permission screen
                        showingHealthPermission = true
                    }
                    .padding()
                    .padding(.horizontal)
                    .background(Capsule().fill(Color(hex: "5CBDB9")))
                    .foregroundColor(.white)
                    .cornerRadius(25)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "F8F9FF"),
                    Color(hex: "E6E7F8")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
        )
    }
    
    private func onboardingPage(title: String, subtitle: String, image: Image, index: Int) -> some View {
        VStack(spacing: 20) {
            Spacer()
            
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 200)
                .foregroundColor(Color(hex: "5CBDB9"))
                .padding()
                .background(
                    Circle()
                        .fill(Color(hex: "F0F1F8"))
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                )

            Text(title)
                .font(.system(size: 28, weight: .bold, design: .default))
                .foregroundColor(Color(hex: "3A366E"))
                .multilineTextAlignment(.center)
                .padding(.top, 30)
            
            Text(subtitle)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(hex: "5A5A6E"))
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .tag(index)
        .padding()
    }
    
    // MARK: - HealthKit Permission View
    
    private var healthKitPermissionView: some View {
        VStack(spacing: 25) {
            Spacer()
            
            Image(systemName: "heart.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(Color(hex: "5CBDB9"))
                .padding()
                .background(
                    Circle()
                        .fill(Color(hex: "F0F1F8"))
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                )
            
            Text("Allow Sleep Data Access")
                .font(.system(size: 24, weight: .bold, design: .default))
                .foregroundColor(Color(hex: "3A366E"))
                .multilineTextAlignment(.center)
            
            Text("SlumberWise needs access to your sleep data from Health to provide personalized recommendations")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(hex: "5A5A6E"))
                .padding(.horizontal, 40)
            
            if let error = permissionError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
            
            if isRequestingPermission {
                LoadingSpinner(color: Color(hex: "5CBDB9"))
                    .frame(width: 50, height: 50)
                    .padding()
            } else if permissionGranted {
                Button("Get Started") {
                    appState.completeOnboarding()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "5CBDB9"))
                .cornerRadius(25)
                .padding(.horizontal, 25)
            } else {
                Button(action: requestHealthKitPermission) {
                    Text("Allow Access")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "5CBDB9"))
                        .cornerRadius(25)
                        .padding(.horizontal, 25)
                }
                
                Button("Skip for Now") {
                    // Skip and continue with mock data
                    appState.completeOnboarding()
                }
                .foregroundColor(Color(hex: "5A5A6E"))
                .padding(.top, 10)
            }
            
            Spacer().frame(height: 25)
        }
        .padding()
        .background(
            Color(hex: "F8F9FF")
                .edgesIgnoringSafeArea(.all)
        )
    }
    
    // MARK: - Actions
    
    private func requestHealthKitPermission() {
        isRequestingPermission = true
        permissionError = nil
        
        Task {
            let granted = await appState.requestHealthKitAuthorization()
            
            DispatchQueue.main.async {
                isRequestingPermission = false
                permissionGranted = granted
                
                if granted {
                    // Start loading sleep data in the background
                    Task {
                        await appState.loadSleepData()
                    }
                } else {
                    // Show error if permission was denied
                    if let error = appState.healthKitService.errorMessage {
                        permissionError = error
                    } else {
                        permissionError = "Failed to get access to Health data. You can continue with sample data or try again."
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(AppState())
    }
}
