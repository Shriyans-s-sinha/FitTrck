# FitTrck – AI Nutritionist & Meal Planner (SwiftUI)

FitTrck is an iOS SwiftUI app that helps you plan meals, manage your pantry, track preferences, and chat with an AI chef for suggestions and nutrition guidance.

## Features
- AI Nutritionist Dashboard with daily insights and suggestions
- Pantry management and camera-assisted ingredient capture
- Weekly meal planner with calendar and recipe details
- Meal Plans list with filters, search, tags, and pagination
- Taste profile with insights and personalized recommendations
- Social screen (placeholder) for future sharing/community features

## Project Structure
- `FitTrckApp.swift` – App entry point
- `ContentView.swift` – TabView that hosts the main sections
- `DashboardView.swift` – AI chef dashboard
- `PantryView.swift` – Pantry management and insights
- `MealPlannerView.swift` – Weekly planner, recipes, and suggestions
- `MealPlansViewAll.swift` – All meal plans with filters and actions
- `TasteProfileView.swift` – Taste profile and analytics
- `MealPlanStore.swift` – Data persistence and CRUD for meal plans
- `OpenAIService.swift` – Network calls to OpenAI API (chat + image input)

## Requirements
- Xcode 15 or later
- iOS 16+ recommended (SwiftUI NavigationStack, toolbars)

## Getting Started
1. Clone the repository:
   ```bash
   git clone https://github.com/Shriyans-s-sinha/FitTrck.git
   cd FitTrck
   ```
2. Open the project in Xcode:
   - Double-click `FitTrck.xcodeproj`
3. Configure the OpenAI API key (for local dev/testing):
   - Open `FitTrck/OpenAIService.swift`
   - Replace the placeholder `YOUR_OPENAI_API_KEY_HERE` with your key
   - Note: Do not commit real keys to a public repository. For production, move to secure storage (Keychain or server-side).
4. Build and run on an iPhone simulator or device.

## Notes on Navigation & Headers (iOS)
- The app uses native `NavigationStack` and `toolbar` for back arrows and actions.
- The Meal Plans screen (`MealPlansViewAll.swift`) relies solely on the system navigation bar (one back arrow, one title, trailing plus button), with filters placed directly underneath for consistent hierarchy.

## Security
- API keys must never be committed to public repositories.
- This repo is public; use environment-specific secrets for any deployments.

## Roadmap
- Move API key handling to secure storage (Keychain or remote token exchange)
- Add README badges and screenshots (SVG only if added)
- Set up CI via GitHub Actions (format, lint, build)
- Add License and Contribution guidelines

## License
TBD – please specify your preferred license (MIT/Apache-2.0/GPL-3.0). I will add it accordingly.