# SlumberWise UI Design Recommendations

## Design Language

SlumberWise should embrace a calming, minimalist design language that promotes relaxation and sleep wellness:

### Color Palette
- **Primary**: Deep indigo (#3A366E) - Represents night sky and tranquility
- **Secondary**: Soft lavender (#B8B5E1) - Evokes relaxation and calmness
- **Accent**: Gentle teal (#5CBDB9) - For interactive elements and highlights
- **Background**: Near-white (#F8F9FF) - Light with subtle blue tint for less eye strain
- **Dark Mode Background**: Deep blue-gray (#1A1B2E) - Soothing dark mode experience
- **Text**: Dark gray (#2A2A35) and white (#FFFFFF) - Clear readability
- **Status Colors**:
  - Complete/Success: Soft mint green (#7ED8B2)
  - Pending: Warm amber (#FFD485)
  - Inactive: Light gray (#D0D1E1)

### Typography
- **Primary Font**: SF Pro Display (system font) for clean, modern look
- **Headings**: Light weight for large elements, medium weight for emphasis
- **Body Text**: Regular weight, generous line height for readability
- **Size Scale**: 
  - Extra Large (28pt): Screen titles
  - Large (22pt): Challenge titles
  - Medium (17pt): Primary content
  - Small (15pt): Secondary information
  - Extra Small (13pt): Supporting details

### Iconography
- Simple, outline-style icons with consistent 2px stroke weight
- Rounded corners on all icons for a friendly feel
- Animated subtle transitions for state changes
- Custom sleep-themed icons for sleep stages (moon, clouds, stars)

## Screen Designs

### 1. Splash & Onboarding Flow

#### Splash Screen
- **Style**: Centered app logo with night-themed gradient background
- **Animation**: Gentle fade-in of logo, followed by subtle breathing animation
- **Transition**: Smooth cross-fade to onboarding or main screen

#### Onboarding Screens
- **Layout**: Full-screen cards with large top illustration
- **Navigation**: Subtle page indicators and "Next" button at bottom
- **Content Flow**:
  1. **Welcome**: App logo with tagline "Better sleep insights, one action at a time"
  2. **Value Proposition**: Illustration of sleep stages with brief explanation
  3. **HealthKit Permission**: Visual showing HealthKit icon and SlumberWise connection
  4. **Notification Setup**: Time selection for evening reminder with toggle
  5. **Completion**: Success animation and "Get Started" button

### 2. Home Screen (Challenge View)

#### New Challenge State
- **Layout**: Card-based design with prominent challenge in center of screen
- **Header**: Date and sleep quality indicator (optional summary)
- **Challenge Card**:
  - Rounded corners with subtle shadow
  - Challenge title in large type at top
  - Brief description below
  - Category tag (sleep routine, environment, etc.)
  - "Challenge Accepted" button spanning bottom of card
  - Subtle background pattern related to challenge category
- **Bottom Area**: Sleep stats summary (total hours, efficiency)

#### Accepted Challenge State
- Card shifts to "in progress" state
- Progress indicator shows time remaining until bedtime
- "Challenge Accepted" button replaced with "Mark Complete" button
- Optional reminder toggle for this specific challenge

#### Completed Challenge State
- Celebration animation (gentle particle effect)
- Card shifts to completed state (color change)
- Success message with encouraging text
- Option to share achievement or view past challenges

#### Empty State
- Friendly illustration (moon, stars)
- "No current challenge" message
- "Generate New Challenge" button
- Option to view sleep statistics

### 3. History View

#### Layout
- Clean list view with cards for past challenges
- Calendar view toggle option at top
- Filtering options for completion status and categories

#### Challenge History Items
- Date and day of week
- Challenge title and category
- Completion status indicator
- Tap to expand for full challenge details

#### Statistics Section
- Completion rate visualization (circular progress)
- Current streak counter
- Weekly/monthly view toggle
- Best performing categories

### 4. Settings Screen

#### Layout
- Standard iOS settings list with grouped sections
- Clean, minimal design with right-aligned toggles/indicators

#### Sections
- **Account**: User preferences (no account needed, but personalization)
- **Notifications**: Morning and evening reminder time settings
- **HealthKit**: Connection status and reconnect option
- **Appearance**: Dark/light mode toggle (or system preference)
- **Privacy**: Clear explanation of data usage and API calls
- **About**: App version, credits, and support links

### 5. Notification Designs

#### Morning Notification
- Friendly greeting with sleep summary
- "New challenge ready" message
- Direct action to view challenge

#### Evening Reminder
- Gentle reminder about pending challenge
- Time until recommended bedtime
- Direct action to mark complete

## Micro-interactions & Animations

### Challenge Interactions
- Challenge cards should have subtle hover state
- Accept button grows slightly on press
- Complete action triggers celebration animation
- Swipe actions for quick completion or dismissal

### Transitions
- Smooth cross-fades between main screens
- Card flip animation when revealing new challenge
- Gentle bounce when challenge card appears
- Sleep data should "flow" into visualizations

### Reward Animations
- Completion triggers particle effect (stars/confetti)
- Streak milestones get enhanced animations
- Variable intensity based on challenge difficulty
- Haptic feedback accompanies visual rewards

## Special Components

### Sleep Data Visualization
- Simple, elegant circular graph for sleep stages
- Color-coded segments for each sleep stage
- Animation that builds the graph as data loads
- Tap to view detailed breakdown

### Challenge Progress Tracker
- Visual timeline of current and past challenges
- Calendar view option showing completion status by day
- Week-by-week view of progress and trends
- Milestone markers for significant achievements

### Demo Mode Elements
- Subtle "Demo Mode" indicator when activated
- Accelerated timeline visualization
- Sample data clearly labeled as demonstration
- Quick reset button for presentations

## Accessibility Considerations

- Support for Dynamic Type (all text scales appropriately)
- VoiceOver optimizations for all interactive elements
- Sufficient color contrast for all states and modes
- Reduced motion option for animations
- Support for system dark/light mode preferences

## Implementation Notes

- Use SwiftUI's built-in animations for consistent feel
- Leverage SF Symbols for iconography where possible
- Create custom ViewModifiers for consistent styling
- Use GeometryReader sparingly for responsive layouts
- Create reusable components for challenge cards and status indicators
