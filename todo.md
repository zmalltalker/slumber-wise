# SlumberWise Todo Checklist

## Project Setup and Initial Configuration

- [ ] Create GitHub repository
- [ ] Add initial.md and prompt-spec.md to repo
- [ ] Add README.md to repo
- [ ] Create .gitignore file for Swift/iOS projects
- [ ] Set up branch structure (main, development, feature branches)

## Phase 1: Project Setup and Basic Structure

### Project Initialization
- [ ] Create new SwiftUI iOS project with Swift Data support
- [ ] Set deployment target to iOS 17.0
- [ ] Configure project settings and capabilities
- [ ] Set up folder structure (Models, Views, ViewModels, Utilities, Resources)
- [ ] Create basic AppDelegate and SceneDelegate
- [ ] Initialize main App struct with ContentView

### Core Models
- [ ] Create Challenge Swift Data model with required fields
  - [ ] id: UUID (unique)
  - [ ] date: Date
  - [ ] challengeName: String
  - [ ] challengeDescription: String (optional)
  - [ ] category: String
  - [ ] completed: Bool
  - [ ] dateCompleted: Date (optional)
- [ ] Create SleepDay struct
  - [ ] date: Date
  - [ ] stages: [SleepStage]
- [ ] Create SleepStage struct
  - [ ] stage: SleepStageType
  - [ ] minutes: Double
- [ ] Create SleepStageType enum with cases
  - [ ] core, deep, rem, awake
  - [ ] Add conversion from HKCategoryValueSleepAnalysis
- [ ] Create sample data for development

### Basic UI Shell
- [ ] Design app icon and add to Asset Catalog
- [ ] Create ThemeManager or Constants file
  - [ ] Define color palette
  - [ ] Define typography settings
  - [ ] Define layout constants
  - [ ] Define animation durations
- [ ] Set up main navigation structure
  - [ ] Home tab
  - [ ] History tab
  - [ ] Settings tab (optional)
- [ ] Create placeholder screens
  - [ ] OnboardingView
  - [ ] HomeView
  - [ ] HistoryView
- [ ] Add splash screen with app logo

## Phase 2: HealthKit Integration

### HealthKit Authorization
- [ ] Add HealthKit to app capabilities
- [ ] Update Info.plist with privacy descriptions
- [ ] Create HealthKitManager class
  - [ ] Initialize HKHealthStore
  - [ ] Add method to check if HealthKit is available
  - [ ] Implement authorization request for sleep analysis data
- [ ] Create HealthKitManager extensions
  - [ ] Add checkAuthorizationStatus() method
  - [ ] Add requestAuthorization() async method
- [ ] Implement permission handling flow
  - [ ] Check status on app launch
  - [ ] Handle denied permissions with guidance
  - [ ] Update app state based on permission status

### Sleep Data Fetching
- [ ] Add methods to query sleep analysis data
  - [ ] Implement fetchSleepData(forDays:) method
  - [ ] Set up proper predicates and sort descriptors
- [ ] Implement data aggregation by sleep stages
  - [ ] Create processSleepSamples(_:) method
  - [ ] Group samples by day
  - [ ] Calculate minutes in each sleep stage
  - [ ] Map HK values to SleepStageType
- [ ] Create JSON structure builder
  - [ ] Implement sleepDataToJSON(_:) method
  - [ ] Format according to specification
  - [ ] Handle date formatting correctly
- [ ] Add convenience method for complete process
  - [ ] Create fetchProcessedSleepData(forDays:) method
  - [ ] Include proper error handling

### Data Processing Logic
- [ ] Implement date range filtering
  - [ ] Add method to fetch between specific dates
  - [ ] Create option for latest complete day only
  - [ ] Handle missing data situations
- [ ] Add sleep metrics calculations
  - [ ] Calculate totalSleepTime
  - [ ] Calculate sleepEfficiency
  - [ ] Create sleepQualityScore
- [ ] Implement data validation and error handling
  - [ ] Check for missing or unusual data
  - [ ] Handle edge cases
  - [ ] Provide fallback values
- [ ] Create SleepDataProcessor class
  - [ ] Process raw HealthKit data
  - [ ] Output clean SleepDay objects
  - [ ] Add debugging methods

## Phase 3: GPT Integration

### API Client Setup
- [ ] Create GPTManager class
  - [ ] Configure API endpoint
  - [ ] Set up URLSession with timeouts
  - [ ] Create response models
- [ ] Implement secure API key handling
  - [ ] Create secure storage method
  - [ ] Set up dev/prod configurations
  - [ ] Avoid hardcoding keys
- [ ] Develop request/response flow
  - [ ] Implement sendRequest(with:) method
  - [ ] Handle HTTP errors
  - [ ] Parse JSON responses
- [ ] Add rate limiting and retry logic
  - [ ] Implement exponential backoff
  - [ ] Handle rate limit responses
  - [ ] Add caching where appropriate

### Prompt Engineering
- [ ] Create system prompt
  - [ ] Add clear instructions
  - [ ] Include medical disclaimers
  - [ ] Specify format requirements
  - [ ] Add recommendation guidelines
- [ ] Design user prompt template
  - [ ] Format for JSON sleep data
  - [ ] Ask for specific recommendation
  - [ ] Include any user preferences
  - [ ] Specify response constraints
- [ ] Implement response parsing
  - [ ] Extract recommendation text
  - [ ] Identify category
  - [ ] Separate title from description
  - [ ] Handle unexpected formats
- [ ] Add prompt versioning
  - [ ] Enable A/B testing
  - [ ] Track prompt versions
  - [ ] Allow runtime adjustments

### Challenge Generation
- [ ] Create ChallengeGenerator class
  - [ ] Connect to HealthKitManager
  - [ ] Connect to GPTManager
  - [ ] Parse responses to Challenge objects
- [ ] Implement generation flow
  - [ ] Create generateDailyChallenge() method
  - [ ] Fetch latest sleep data
  - [ ] Get GPT recommendation
  - [ ] Create Challenge object
- [ ] Add Swift Data integration
  - [ ] Save new challenges
  - [ ] Update challenge status
  - [ ] Query for challenges
- [ ] Implement error handling with fallbacks
  - [ ] Provide generic challenges on failure
  - [ ] Cache successful challenges
  - [ ] Add error logging
- [ ] Create challenge scheduling
  - [ ] Determine generation timing
  - [ ] Prevent duplicates
  - [ ] Handle edge cases

## Phase 4: User Interface

### Onboarding Flow
- [ ] Create multi-page onboarding
  - [ ] Welcome screen
  - [ ] Value proposition screen
  - [ ] HealthKit permission screen
  - [ ] Notification permission screen
  - [ ] Completion screen
- [ ] Implement HealthKit permission UI
  - [ ] Add clear explanation
  - [ ] Create "Grant Access" button
  - [ ] Show status indicators
- [ ] Develop permission denied fallbacks
  - [ ] Create friendly explanation
  - [ ] Add Settings instructions
  - [ ] Include retry button
- [ ] Add state management
  - [ ] Track onboarding completion
  - [ ] Skip for returning users
  - [ ] Allow revisiting from settings

### Home View
- [ ] Create challenge display card
  - [ ] Show challenge title
  - [ ] Display description
  - [ ] Add category indicator
  - [ ] Show status indicator
  - [ ] Include date
- [ ] Implement "Challenge Accepted" button
  - [ ] Add appropriate styling
  - [ ] Create animation/transition
  - [ ] Update Swift Data
  - [ ] Change UI state
- [ ] Add "Challenge Completed" action
  - [ ] Create button for accepted challenges
  - [ ] Add confirmation dialog
  - [ ] Update status and date
  - [ ] Trigger reward animation
- [ ] Create empty state
  - [ ] Add friendly message
  - [ ] Include manual generation button
  - [ ] Show loading state
- [ ] Implement pull-to-refresh
  - [ ] Fetch new sleep data
  - [ ] Generate new challenge
  - [ ] Show appropriate feedback

### Animations and Feedback
- [ ] Create completion reward animation
  - [ ] Design celebration effect
  - [ ] Implement using SwiftUI or SpriteKit
  - [ ] Add variable intensity
  - [ ] Include sound effects (optional)
- [ ] Add haptic feedback
  - [ ] Success feedback
  - [ ] Selection feedback
  - [ ] Error feedback
  - [ ] Notification feedback
- [ ] Implement visual transitions
  - [ ] Animate between challenge states
  - [ ] Add card flip/reveal animations
  - [ ] Create progress indicators
  - [ ] Design fade transitions
- [ ] Create micro-interactions
  - [ ] Button press animations
  - [ ] Background effects
  - [ ] Call-to-action effects
  - [ ] Swipe gesture feedback

## Phase 5: Local Storage

### Swift Data Integration
- [ ] Set up Swift Data container
  - [ ] Configure ModelContainer
  - [ ] Set up schema versions
  - [ ] Initialize in app startup
- [ ] Implement CRUD operations
  - [ ] createChallenge method
  - [ ] getActiveChallenge method
  - [ ] updateChallenge method
  - [ ] deleteChallenge method
  - [ ] markChallengeCompleted method
- [ ] Add query predicates
  - [ ] Recent challenges
  - [ ] Completion status filtering
  - [ ] Category filtering
  - [ ] Date range filtering
- [ ] Implement DataManager class
  - [ ] Create clean API
  - [ ] Handle errors and edge cases
  - [ ] Add logging
  - [ ] Manage challenge lifecycle

### Challenge History
- [ ] Create ChallengeHistoryView
  - [ ] Show list of past challenges
  - [ ] Display completion status
  - [ ] Group by week/month
  - [ ] Add visual indicators
- [ ] Implement filtering and sorting
  - [ ] Filter by completion
  - [ ] Filter by category
  - [ ] Sort by date
  - [ ] Add search functionality
- [ ] Add completion statistics
  - [ ] Show overall completion rate
  - [ ] Track completion streaks
  - [ ] Create calendar view
  - [ ] Show progress visualization
- [ ] Implement detail view
  - [ ] Display full challenge details
  - [ ] Show dates
  - [ ] Add recreate option
  - [ ] Include share option

## Phase 6: Notifications

### Notification Permissions
- [ ] Set up permission request flow
  - [ ] Create NotificationManager
  - [ ] Add status check methods
  - [ ] Implement requestAuthorization()
  - [ ] Handle all outcomes
- [ ] Add permission request UI
  - [ ] Create explanation screen
  - [ ] Add "Allow Notifications" button
  - [ ] Show visual feedback
  - [ ] Handle denied permissions
- [ ] Create notification templates
  - [ ] Morning notification
  - [ ] Evening reminder
  - [ ] Demo notification
  - [ ] Include icon and actions
- [ ] Set up categories and actions
  - [ ] "Accept Challenge" action
  - [ ] "Complete Challenge" action
  - [ ] Configure for lock screen and center

### Notification Scheduling
- [ ] Set up morning notification
  - [ ] Schedule for new data availability
  - [ ] Use fixed time for hackathon
  - [ ] Check for existing challenges
  - [ ] Personalize if possible
- [ ] Implement evening reminder
  - [ ] Schedule for 21:30 daily
  - [ ] Check challenge status
  - [ ] Customize message
  - [ ] Only send when relevant
- [ ] Add notification action handlers
  - [ ] Handle "Accept Challenge"
  - [ ] Handle "Complete Challenge"
  - [ ] Open appropriate screen
  - [ ] Track interactions
- [ ] Implement notification management
  - [ ] Remove outdated notifications
  - [ ] Update on status changes
  - [ ] Handle app lifecycle transitions
  - [ ] Respect system settings

### Demo Trigger
- [ ] Add rapid tap gesture recognizer
  - [ ] Create tap counter with timeout
  - [ ] Detect 10 rapid taps
  - [ ] Show visual feedback
  - [ ] Handle interruptions
- [ ] Implement demo notification
  - [ ] Create sample notification
  - [ ] Add rich content and buttons
  - [ ] Display immediately
  - [ ] Add realistic delay
- [ ] Create artificial demo cycle
  - [ ] Generate sample sleep data
  - [ ] Create realistic challenge
  - [ ] Simulate complete flow
  - [ ] Add demo logging
- [ ] Add hidden debug menu
  - [ ] Show app state and stats
  - [ ] Create flow trigger buttons
  - [ ] Add data reset options
  - [ ] Include customization settings

## Phase 7: Polishing and Testing

### Error Handling
- [ ] Create custom error system
  - [ ] Define AppError enum
  - [ ] Add user-friendly descriptions
  - [ ] Include troubleshooting tips
  - [ ] Set up logging/analytics
- [ ] Implement error messages
  - [ ] Create ErrorView
  - [ ] Design toast/alert components
  - [ ] Add appropriate icons
  - [ ] Include retry functionality
- [ ] Add graceful fallbacks
  - [ ] HealthKit permission fallback
  - [ ] Missing data fallback
  - [ ] API failure fallback
  - [ ] Network error fallback
- [ ] Implement error coordinator
  - [ ] Create ErrorCoordinator
  - [ ] Add consistent handling methods
  - [ ] Include severity levels
  - [ ] Provide debug information

### UI Polish
- [ ] Refine animations and transitions
  - [ ] Standardize timing and curves
  - [ ] Add depth effects
  - [ ] Polish state transitions
  - [ ] Optimize performance
- [ ] Ensure consistent theming
  - [ ] Audit all UI elements
  - [ ] Create Theme struct
  - [ ] Add dark mode support
  - [ ] Implement typography scaling
- [ ] Optimize for device sizes
  - [ ] Test on all iPhone sizes
  - [ ] Add iPad layouts if needed
  - [ ] Test in different orientations
  - [ ] Handle dynamic type
- [ ] Add final visual touches
  - [ ] Background patterns/gradients
  - [ ] Refine iconography
  - [ ] Custom control styles
  - [ ] Polish empty states

### Testing
- [ ] Write unit tests
  - [ ] Test HealthKitManager
  - [ ] Test GPTManager
  - [ ] Test data processing
  - [ ] Test Swift Data operations
- [ ] Add UI tests
  - [ ] Test onboarding flow
  - [ ] Test challenge flow
  - [ ] Test navigation
  - [ ] Test error handling
- [ ] Implement end-to-end testing
  - [ ] Test full app flow
  - [ ] Test notifications
  - [ ] Test data persistence
  - [ ] Test performance
- [ ] Create test utilities
  - [ ] Mock data generators
  - [ ] Test fixtures
  - [ ] Performance measurement
  - [ ] Screenshot comparison

## Phase 8: Final Integration

### Wiring Everything Together
- [ ] Create AppCoordinator
  - [ ] Manage overall app flow
  - [ ] Implement dependency injection
  - [ ] Ensure clean handoffs
  - [ ] Add integration logging
- [ ] Ensure lifecycle management
  - [ ] Handle app launch states
  - [ ] Manage background transitions
  - [ ] Handle HealthKit updates
  - [ ] Manage notification scheduling
- [ ] Test complete user journey
  - [ ] First launch experience
  - [ ] Daily usage patterns
  - [ ] Challenge lifecycle
  - [ ] Edge cases
- [ ] Implement state restoration
  - [ ] Save/restore app state
  - [ ] Handle deep links
  - [ ] Preserve user progress
  - [ ] Manage transient states

### Performance Optimization
- [ ] Optimize data operations
  - [ ] Add HealthKit caching
  - [ ] Implement incremental processing
  - [ ] Use background tasks
  - [ ] Add pagination
- [ ] Improve UI performance
  - [ ] Reduce view hierarchy
  - [ ] Optimize lists
  - [ ] Implement lazy loading
  - [ ] Fix frame drops
- [ ] Reduce resource usage
  - [ ] Minimize background work
  - [ ] Optimize network requests
  - [ ] Use efficient algorithms
  - [ ] Monitor memory usage
- [ ] Add performance monitoring
  - [ ] Add performance metrics
  - [ ] Log slow operations
  - [ ] Implement crash reporting
  - [ ] Create performance tests

### Launch Preparation
- [ ] Create demo script
  - [ ] Write step-by-step flow
  - [ ] Highlight key features
  - [ ] Prepare Q&A
  - [ ] Include contingencies
- [ ] Prepare presentation materials
  - [ ] Take screenshots
  - [ ] Create slide deck
  - [ ] Record demo video
  - [ ] Write project description
- [ ] Final bug fixes
  - [ ] Conduct final testing
  - [ ] Fix remaining issues
  - [ ] Clean up build warnings
  - [ ] Test on multiple devices
- [ ] Add documentation
  - [ ] Document architecture
  - [ ] Add code comments
  - [ ] Create setup instructions
  - [ ] Note enhancement ideas

## Post-Hackathon Tasks (Optional)

- [ ] Collect and review feedback
- [ ] Prioritize improvements
- [ ] Consider App Store preparation
- [ ] Plan next feature set
