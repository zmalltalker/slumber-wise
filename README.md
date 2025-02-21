# SlumberWise

> Transforming sleep data into actionable insights with AI

## Overview

SlumberWise is an iOS app that leverages Apple HealthKit sleep data and GPT-powered analysis to provide personalized "Next Best Action" recommendations for improving sleep quality. Built for a hackathon, this app demonstrates the power of combining health data with AI to create meaningful user experiences.

## Project Documentation

This repository contains the following key documents:

- [`initial.md`](./initial.md) - The comprehensive project specification detailing the app's requirements, features, architecture, and implementation details
- [`prompt-spec.md`](./prompt-spec.md) - A structured implementation plan and LLM code generation prompts derived from the initial specification

## Key Features

- **HealthKit Integration**: Securely reads and analyzes Apple HealthKit sleep data
- **AI-Powered Insights**: Processes sleep patterns through GPT to generate personalized recommendations
- **Actionable Challenges**: Presents a single, focused "Next Best Action" to improve sleep
- **Engagement Loop**: Uses notifications, feedback, and rewards to encourage participation
- **Local-First**: All data stays on device, with only anonymized aggregated metrics sent to GPT

## Architecture

SlumberWise follows a clean architecture approach with these components:

- **SwiftUI** for the modern, reactive UI layer
- **Swift Data** for local persistence of challenges and user progress
- **Apple HealthKit** for secure access to sleep metrics
- **GPT Integration** via an external API for recommendation generation

## Implementation Approach

The repository is structured around a step-by-step implementation plan that breaks down the development into manageable chunks:

1. **Project Setup and Basic Structure**
2. **HealthKit Integration**
3. **GPT Integration**
4. **User Interface Development**
5. **Local Storage Implementation**
6. **Notification Systems**
7. **Polishing and Testing**
8. **Final Integration**

Each phase contains multiple small, incremental steps that build upon each other, allowing for focused development and testing.

## Getting Started

### Prerequisites

- Xcode 15.0+
- iOS 17.0+ deployment target
- Apple Developer Account (for HealthKit capabilities)
- GPT API access (e.g., OpenAI API key)

### Initial Setup

1. Clone this repository
2. Open the project in Xcode
3. Add your GPT API key to the appropriate configuration file
4. Configure the HealthKit capabilities in your app target
5. Build and run on a device with HealthKit data available

## Development Process

The [`prompt-spec.md`](./prompt-spec.md) file contains a detailed implementation plan with step-by-step code generation prompts. These prompts are designed to be used with a code-generation LLM to produce the necessary code for each component of the app.

To follow this development approach:

1. Start with Phase 1, Step 1 and work through each step in order
2. Use the corresponding code generation prompt to create the implementation
3. Test each component before moving to the next step
4. Integrate components as specified in the final phase

## Privacy and Security

SlumberWise takes privacy seriously:

- Sleep data is processed locally on device
- Only anonymized, aggregated metrics are sent to the GPT API
- No user identification information is transmitted
- All challenges and progress data are stored only on the user's device

## Contributing

This project was created for a hackathon but welcome contributions! If you'd like to improve SlumberWise:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

[MIT License](LICENSE) - Feel free to use, modify, and distribute this code for your own projects.

## Acknowledgments

- Apple for HealthKit and SwiftUI
- OpenAI for GPT capabilities
- The hackathon organizers and judges
