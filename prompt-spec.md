# SlumberWise Code Generation Prompts

## Phase 1: Project Setup and Basic Structure

### Prompt 1: Project Initialization
```
Create a new SwiftUI iOS project named "SlumberWise" that uses Swift Data. Set up the following folder structure:
- Models
- Views
- ViewModels
- Utilities
- Resources

Initialize the project with iOS 17.0 as the deployment target. Set up a basic AppDelegate and SceneDelegate structure, and create a main App struct with a basic ContentView. Include comments explaining the project's purpose: an app that reads Apple HealthKit sleep data, processes it through GPT, and provides personalized "Next Best Action" recommendations to improve sleep.
```

### Prompt 2: Core Models
```
Create the core data models for the SlumberWise app:

1. Create a `Challenge` model as a Swift Data `@Model` class with the following properties:
   - id: UUID (with @Attribute(.unique) modifier)
   - date: Date
   - challengeName: String
   - challengeDescription: String (optional)
   - category: String
   - completed: Bool (default: false)
   - dateCompleted: Date? (optional)

2. Create a `SleepDay` struct (not a persistence model) with:
   - date: Date
   - stages: [SleepStage] (where SleepStage is defined next)

3. Create a `SleepStage` struct with:
   - stage: SleepStageType (enum)
   - minutes: Double

4. Create a `SleepStageType` enum with cases:
   - core
   - deep
   - rem
   - awake
   
   Include a method to convert from HKCategoryValueSleepAnalysis.

5. Include sample data for development purposes.

The Challenge model will be used with Swift Data, while the sleep-related structs will be used to process HealthKit data for sending to the GPT API.
```

### Prompt 3: Basic UI Shell
```
Create the basic UI shell for the SlumberWise app:

1. Design an app icon in Asset Catalog with a sleep-related theme (e.g., moon, stars, or bed).

2. Create a ThemeManager or Constants file that defines:
   - Color palette (calming blues, purples for sleep theme)
   - Typography settings (font sizes, weights)
   - Layout constants (padding, corner radius)
   - Animation durations

3. Implement the main navigation structure using TabView or NavigationSplitView with:
   - Home tab (for current challenge)
   - History tab (for past challenges)
   - Settings tab (optional)

4. Create placeholder screens:
   - OnboardingView (with placeholder for HealthKit permissions)
   - HomeView (with empty state for challenge display)
   - HistoryView (with empty state)

5. Add a simple splash screen with the app logo.

Keep the design minimalist, focusing on a clean and calming aesthetic suitable for a sleep improvement app. Use SwiftUI's built-in components and standard iOS patterns.
```

## Phase 2: HealthKit Integration

### Prompt 4: HealthKit Authorization
```
Implement HealthKit authorization in the SlumberWise app:

1. Add the necessary HealthKit entitlements to the app:
   - Add HealthKit to the app's capabilities
   - Update Info.plist with privacy descriptions for health data access

2. Create a HealthKitManager class that:
   - Initializes HKHealthStore
   - Checks if HealthKit is available on the device
   - Requests authorization specifically for sleep analysis data (HKCategoryTypeIdentifierSleepAnalysis)
   - Handles permission results with completion handlers

3. Create an extension for HealthKitManager that provides convenience methods:
   - checkAuthorizationStatus() -> Bool
   - requestAuthorization() -> async throws -> Bool

4. Implement a permission handling flow that:
   - Checks current authorization status on app launch
   - Guides user to Settings app if permissions were previously denied
   - Updates app state based on permission status

Make sure to include proper error handling and user feedback for each possible state. This implementation should focus solely on authorization, not yet retrieving data.
```

### Prompt 5: Sleep Data Fetching
```
Implement sleep data fetching functionality in the HealthKitManager:

1. Add methods to query sleep analysis data:
   - fetchSleepData(forDays: Int) -> async throws -> [HKCategorySample]
   - Fetch data for the specified number of days in the past
   - Use HKQuery with appropriate predicates and sort descriptors

2. Implement data aggregation by sleep stages:
   - processSleepSamples(_ samples: [HKCategorySample]) -> [SleepDay]
   - Group samples by day (midnight to midnight)
   - Calculate minutes in each sleep stage (Core, Deep, REM, Awake)
   - Map HKCategoryValueSleepAnalysis values to our SleepStageType

3. Create a JSON structure builder:
   - sleepDataToJSON(_ sleepDays: [SleepDay]) -> Data
   - Format according to the specified structure in the requirements
   - Handle date formatting properly (YYYY-MM-DD)

4. Add a convenience method that combines the above:
   - fetchProcessedSleepData(forDays: Int) -> async throws -> Data
   - Returns JSON-formatted data ready for GPT API

Include proper error handling with custom error types for different failure cases. Make sure to handle time zone considerations and sleep periods that cross midnight boundaries.
```

### Prompt 6: Data Processing Logic
```
Enhance the sleep data processing logic with additional functionality:

1. Implement date range filtering:
   - Add method to fetch data between specific dates
   - Create option to fetch only the latest complete day of sleep data
   - Handle situations where a user might not have data for every day

2. Add sleep metrics calculations:
   - totalSleepTime: Calculate total minutes across all sleep stages
   - sleepEfficiency: Calculate percentage of time in bed actually asleep
   - sleepQualityScore: Create a simple quality metric based on proportions of Deep/REM sleep

3. Implement data validation and error handling:
   - Check for missing data or unusual patterns
   - Handle edge cases like no data available or corrupted samples
   - Provide fallback values where appropriate

4. Create a SleepDataProcessor class that:
   - Takes raw HealthKit data and applies the processing logic
   - Outputs clean, validated SleepDay objects
   - Includes debugging methods for development

The focus should be on creating robust data processing that handles real-world sleep data patterns and provides useful metrics for the GPT API to generate meaningful recommendations.
```

## Phase 3: GPT Integration

### Prompt 7: API Client Setup
```
Implement GPT API integration for the SlumberWise app:

1. Create a GPTManager class with:
   - API endpoint configuration
   - URLSession setup with appropriate timeouts and configuration
   - Response models matching the GPT API structure

2. Implement secure API key handling:
   - Create a secure method to store and retrieve the API key
   - Add configuration for development vs. production environments
   - Never hardcode the API key in the source code

3. Develop the basic request/response flow:
   - sendRequest(with: Data) -> async throws -> GPTResponse
   - Handle HTTP errors, timeouts, and other network failures
   - Parse JSON responses into Swift models

4. Add API rate limiting and retry logic:
   - Implement exponential backoff for retries
   - Handle rate limit responses appropriately
   - Cache responses when applicable to reduce API usage

The implementation should follow best practices for iOS networking, including proper error handling, cancelable requests, and background task handling for requests that might take time to complete.
```

### Prompt 8: Prompt Engineering
```
Implement GPT prompt engineering for sleep recommendations:

1. Create a system prompt with:
   - Clear instructions for GPT to provide a single "Next Best Action"
   - Medical disclaimers ("not a medical professional")
   - Format requirements for the response (brief, actionable)
   - Guidelines for types of recommendations (e.g., bedtime routine, screen time)

2. Design a user prompt template that:
   - Takes the JSON sleep data
   - Asks for a specific, concise recommendation
   - Includes any user preferences or constraints
   - Specifies character limits for responses

3. Implement response parsing that:
   - Extracts the core recommendation text
   - Identifies a category for the recommendation
   - Separates title from description if applicable
   - Handles unexpected response formats

4. Add prompt versioning and management:
   - Enable A/B testing different prompt structures
   - Include version tracking for prompts used
   - Allow runtime prompt adjustments

The implementation should focus on creating a reliable prompt structure that generates consistent, helpful, and safe sleep recommendations based on the user's actual sleep data patterns.
```

### Prompt 9: Challenge Generation
```
Implement the challenge generation system connecting HealthKit data to GPT:

1. Create a ChallengeGenerator class that:
   - Takes processed sleep data from HealthKitManager
   - Formats and sends it to GPTManager
   - Parses responses into Challenge objects

2. Implement the main generation flow:
   - generateDailyChallenge() -> async throws -> Challenge
   - Fetches the latest sleep data
   - Gets a recommendation from GPT
   - Creates and returns a new Challenge object

3. Add Swift Data integration to:
   - Save newly generated challenges
   - Update challenge status (accepted, completed)
   - Query for active or completed challenges

4. Implement error handling with fallbacks:
   - Provide generic challenges when API fails
   - Cache previous successful challenges for reuse
   - Log errors for analytics and debugging

5. Create a challenge scheduling system:
   - Determine when to generate new challenges
   - Prevent duplicate challenges on the same day
   - Handle edge cases like missing data days

The implementation should create a seamless flow from HealthKit data to stored Challenge objects, with appropriate error handling at each step.
```

## Phase 4: User Interface

### Prompt 10: Onboarding Flow
```
Implement the onboarding flow for the SlumberWise app:

1. Create a multi-page onboarding experience:
   - Welcome screen explaining the app's purpose
   - Sleep tracking value proposition screen
   - HealthKit permission request screen with friendly explanation
   - Notification permission request screen (to be implemented later)
   - Completion screen that transitions to the main app

2. Implement the HealthKit permission request UI:
   - Create a clear explanation of why sleep data is needed
   - Add a prominent "Grant Access" button that triggers the request
   - Show status indicators during the permission request

3. Develop permission denied fallback screens:
   - Friendly explanation of limitations without permissions
   - Clear instructions how to enable permissions in Settings
   - Button to retry permission request or continue with limited functionality

4. Add state management to:
   - Track onboarding completion status
   - Skip onboarding for returning users
   - Allow users to revisit onboarding from settings

Use SwiftUI animations for smooth transitions between screens and implement a skip button for users who want to bypass the full onboarding experience.
```

### Prompt 11: Home View
```
Implement the main HomeView for displaying and interacting with challenges:

1. Create a challenge display card that shows:
   - Challenge title in prominent typography
   - Optional descriptive text with more details
   - Category indicator (tag or icon)
   - Status indicator (new, accepted, completed)
   - Date the challenge was generated

2. Implement the "Challenge Accepted" button and logic:
   - Button with appropriate styling and prominence
   - Animation/transition when the user accepts a challenge
   - Update challenge status in Swift Data
   - Change UI to show the accepted state

3. Add the "Challenge Completed" action:
   - Button that appears for accepted challenges
   - Completion confirmation dialog or animation
   - Update challenge status and completion date
   - Trigger reward animation (to be implemented later)

4. Create an empty state for when no challenge exists:
   - Friendly message explaining no current challenge
   - Button to generate a new challenge manually
   - Visual indication of loading state during generation

5. Implement pull-to-refresh to manually update:
   - Fetch new sleep data
   - Generate a new challenge if appropriate
   - Show appropriate feedback during the process

The design should be clean, minimalist, and focused on the current challenge, with clear calls to action for the user.
```

### Prompt 12: Animations and Feedback
```
Implement animations and feedback for the SlumberWise app:

1. Create a completion reward animation:
   - Design a subtle confetti or celebration effect
   - Implement using SwiftUI animations or SpriteKit
   - Add variable intensity for more engaging rewards
   - Include accompanying sound effects (optional)

2. Add haptic feedback for interactions:
   - Success feedback when completing a challenge
   - Selection feedback when accepting a challenge
   - Error feedback when operations fail
   - Notification feedback for alerts

3. Implement visual state transitions:
   - Smooth animations between challenge states
   - Card flip or reveal animations for new challenges
   - Progress indicators for loading states
   - Fade transitions for content updates

4. Create micro-interactions to increase engagement:
   - Button press animations
   - Subtle background effects or parallax
   - Pulsing effects for call-to-action elements
   - Swipe gestures with visual feedback

The animations should enhance the user experience without being distracting, maintaining the calm, minimalist aesthetic of a sleep-focused app.
```

## Phase 5: Local Storage

### Prompt 13: Swift Data Integration
```
Implement comprehensive Swift Data integration for the SlumberWise app:

1. Set up the Swift Data container and schema:
   - Configure ModelContainer for the Challenge model
   - Set up schema versions for future migrations
   - Initialize the container in the app's startup sequence

2. Implement CRUD operations for challenges:
   - createChallenge(name:description:category:) -> Challenge
   - getActiveChallenge() -> Challenge?
   - updateChallenge(_ challenge: Challenge)
   - deleteChallenge(_ challenge: Challenge)
   - markChallengeCompleted(_ challenge: Challenge)

3. Add query predicates for common operations:
   - Challenges from the last week
   - Completed vs. uncompleted challenges
   - Challenges by category
   - Challenges by date range

4. Implement a DataManager class that:
   - Provides a clean API over Swift Data operations
   - Handles errors and edge cases
   - Includes logging for debugging
   - Manages the challenge lifecycle

Include proper error handling and implement the repository pattern to abstract Swift Data implementation details from the rest of the app.
```

### Prompt 14: Challenge History
```
Implement the challenge history functionality for the SlumberWise app:

1. Create a ChallengeHistoryView that displays:
   - A list of past challenges
   - Completion status and dates
   - Grouping by week or month
   - Visual indicators for completed vs. uncompleted

2. Implement filtering and sorting options:
   - Filter by completion status
   - Filter by category
   - Sort by date (newest/oldest)
   - Search by challenge name

3. Add completion statistics view:
   - Overall completion rate
   - Streaks of completed challenges
   - Calendar view of challenge history
   - Progress over time visualization

4. Implement detail view for past challenges:
   - Full challenge details
   - Date generated and completed
   - Option to recreate similar challenge
   - Option to share achievement (text only)

The history view should give users a sense of accomplishment and progress while maintaining the clean, minimal design aesthetic of the app.
```

## Phase 6: Notifications

### Prompt 15: Notification Permissions
```
Implement notification permission handling for the SlumberWise app:

1. Set up the notification permission request flow:
   - Create a NotificationManager class
   - Add methods to check current authorization status
   - Implement requestAuthorization() with proper callback
   - Handle all possible authorization outcomes

2. Add UI for notification permission request:
   - Explanation screen about notification benefits
   - "Allow Notifications" button that triggers the request
   - Visual feedback during the permission process
   - Custom handling for denied permissions

3. Create notification content templates:
   - Morning notification with "New challenge ready" message
   - Evening reminder to complete the day's challenge
   - Special notification for demo purposes
   - Include app icon and relevant action buttons

4. Set up notification categories and actions:
   - "Accept Challenge" action from notification
   - "Complete Challenge" action from notification
   - Configure for both lock screen and notification center

Include proper error handling and fallbacks for devices where notifications are disabled at the system level.
```

### Prompt 16: Notification Scheduling
```
Implement notification scheduling for the SlumberWise app:

1. Set up the morning notification logic:
   - Schedule for when new sleep data is available
   - For the hackathon, use a fixed time (e.g., 7:00 AM)
   - Include logic to check if a challenge already exists
   - Personalize with the user's name if available

2. Implement the evening reminder at 21:30:
   - Create repeating notification for 9:30 PM daily
   - Check if the current challenge needs attention
   - Customize message based on challenge status
   - Only send if there's an active, non-completed challenge

3. Add notification action handlers:
   - Handle "Accept Challenge" action by updating model
   - Handle "Complete Challenge" action with reward
   - Open appropriate app screen when notification is tapped
   - Track notification interaction for analytics

4. Implement notification management:
   - Remove outdated notifications
   - Update notifications when challenge status changes
   - Handle app foreground/background transitions
   - Respect system quiet hours and focus modes

Ensure notifications are helpful reminders rather than annoying interruptions, with clear value to the user and easy actions.
```

### Prompt 17: Demo Trigger
```
Implement the demo trigger functionality for the SlumberWise app:

1. Add a gesture recognizer for rapid taps:
   - Create a tap counter that resets after a timeout
   - Detect 10 rapid taps anywhere on the main screen
   - Show subtle visual feedback as tap count increases
   - Reset if taps are too slow or interrupted

2. Implement the demo notification trigger:
   - Create a method to generate a sample notification
   - Include rich content and interactive buttons
   - Display the notification immediately for demo purposes
   - Add a small delay for realistic effect

3. Create an artificial cycle for demo purposes:
   - Generate sample sleep data if HealthKit data is unavailable
   - Create a realistic-looking challenge from GPT (or from a predefined set)
   - Simulate the entire flow from data → GPT → challenge → notification
   - Include logging for presentation purposes

4. Add a hidden debug menu accessible via the tap gesture:
   - Show current app state and data statistics
   - Provide buttons to trigger different parts of the flow
   - Include options to reset data for demo purposes
   - Add settings to customize demo behavior

This implementation should create a seamless demo experience for hackathon presentations without requiring actual sleep data or waiting for notifications.
```

## Phase 7: Polishing and Testing

### Prompt 18: Error Handling
```
Implement comprehensive error handling for the SlumberWise app:

1. Create a custom error system:
   - Define AppError enum with specific error cases
   - Include user-friendly descriptions for each error
   - Add context and troubleshooting suggestions
   - Support for logging and analytics

2. Implement user-facing error messages:
   - Create an ErrorView for displaying errors
   - Design toast or alert components for transient errors
   - Include appropriate icons and colors for error severity
   - Add retry buttons where applicable

3. Add graceful fallbacks for all failure cases:
   - HealthKit permission denied → Suggest enabling in Settings
   - No sleep data → Provide generic sleep advice
   - GPT API failure → Use cached or predefined challenges
   - Network errors → Queue operations for retry when online

4. Implement a central error handling coordinator:
   - Create an ErrorCoordinator to manage error presentation
   - Add methods to handle errors consistently throughout the app
   - Include severity levels and appropriate UI responses
   - Provide debug information in development builds

The implementation should ensure that users never encounter a dead end in the app and always have a path forward, even when errors occur.
```

### Prompt 19: UI Polish
```
Implement UI polish for the SlumberWise app:

1. Refine animations and transitions:
   - Ensure consistent animation timing and curves
   - Add subtle parallax or depth effects
   - Polish transitions between states and screens
   - Optimize performance for smooth 60fps animations

2. Ensure consistent theming and styling:
   - Audit all UI elements for consistent styling
   - Create a Theme struct with all design tokens
   - Implement dark mode support with appropriate colors
   - Add proper typography scaling for accessibility

3. Optimize for different device sizes:
   - Ensure proper layout on iPhone SE through Pro Max
   - Add iPad-specific layouts where appropriate
   - Test and optimize for different orientations
   - Handle dynamic type and font scaling properly

4. Add final visual touches:
   - Subtle background patterns or gradients
   - Refined iconography throughout the app
   - Custom button and control styles
   - Polished empty states and loading indicators

The focus should be on creating a premium, refined feel while maintaining the minimalist aesthetic appropriate for a sleep improvement app.
```

### Prompt 20: Testing
```
Implement testing for the SlumberWise app:

1. Write unit tests for core functionality:
   - HealthKitManager tests with mock data
   - GPTManager tests with sample responses
   - Data processing and transformation tests
   - Swift Data operations tests

2. Add UI tests for critical user flows:
   - Onboarding and permission request flow
   - Challenge acceptance and completion flow
   - Navigation between main sections
   - Error handling and recovery

3. Implement end-to-end testing:
   - Full flow from app launch to challenge completion
   - Notification handling and deep linking
   - Data persistence across app restarts
   - Performance under various conditions

4. Create test utilities and helpers:
   - Mock data generators for different scenarios
   - Test fixtures for common testing needs
   - Performance measurement utilities
   - Screenshot comparison for UI verification

Include both XCTest-based tests and manual testing procedures for aspects that are difficult to automate, such as animation smoothness and haptic feedback.
```

## Phase 8: Final Integration

### Prompt 21: Wiring Everything Together
```
Implement the final integration for the SlumberWise app:

1. Connect all components in a cohesive flow:
   - Create an AppCoordinator to manage the overall app flow
   - Implement proper dependency injection for all components
   - Ensure clean handoffs between different modules
   - Add logging at integration points for debugging

2. Ensure proper lifecycle management:
   - Handle app launch states (cold, warm, from notification)
   - Manage background/foreground transitions
   - Handle HealthKit data updates appropriately
   - Manage notification scheduling across app lifecycles

3. Test the complete user journey:
   - First launch and onboarding
   - Daily usage patterns with notifications
   - Challenge lifecycle (generation, acceptance, completion)
   - Edge cases like permission changes or data availability issues

4. Implement proper state restoration:
   - Save and restore app state during termination
   - Handle deep links and notification actions
   - Preserve user progress and preferences
   - Manage transient states properly

The final integration should create a seamless experience where all components work together smoothly without unnecessary coupling or dependencies.
```

### Prompt 22: Performance Optimization
```
Implement performance optimizations for the SlumberWise app:

1. Optimize data fetching and processing:
   - Add caching for HealthKit queries
   - Implement incremental data processing
   - Use background tasks for heavy operations
   - Add pagination for history and large datasets

2. Improve UI rendering performance:
   - Reduce view hierarchy depth
   - Optimize lists with cell recycling
   - Use appropriate lazy loading techniques
   - Profile and fix any frame drops during animations

3. Reduce battery and resource usage:
   - Minimize background operations
   - Optimize network requests and batching
   - Use efficient algorithms for data processing
   - Monitor and optimize memory usage

4. Add performance monitoring:
   - Instrument key operations with performance metrics
   - Add logging for slow operations
   - Implement crash reporting
   - Create performance test suite

The focus should be on creating a responsive app that feels lightweight and efficient, appropriate for daily use without significant battery impact.
```

### Prompt 23: Launch Preparation
```
Prepare the SlumberWise app for hackathon launch:

1. Create a demo script for the hackathon:
   - Write step-by-step flow for presenting the app
   - Highlight key features and technical achievements
   - Prepare answers for common questions
   - Include contingencies for demo issues

2. Prepare presentation materials:
   - Take screenshots of key screens and flows
   - Create a simple slide deck explaining the concept
   - Record a short demo video as backup
   - Write a concise project description

3. Final bug fixes and polish:
   - Conduct a final testing sweep
   - Fix any remaining issues or rough edges
   - Ensure clean builds without warnings
   - Test on multiple devices if possible

4. Add final documentation:
   - Document architecture and key components
   - Add code comments for complex sections
   - Create a simple README with setup instructions
   - Include future enhancement ideas

The hackathon preparation should ensure that the app can be effectively demonstrated even under suboptimal conditions, highlighting both the technical implementation and the value proposition.
```
