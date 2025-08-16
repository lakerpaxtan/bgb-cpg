# CLAUDE.md

MAIN FLOW FOR CLAUDE: 

1. If I ask you to do outstanding problems --- look through the outstanding problems --- pick some set of the remaining problems --- and work through them with me. Once you've attempted a fix for the problem --- add a label to the problem **[In Progress, Please Test]** in Outstanding Problems markdown --- then tell me you are ready for me to test the problems 

2. NEVER move problems from outstanding to completed until I have tested and confirmed they work. The workflow is:
   - Work on problems 
   - Mark as **[In Progress, Please Test]**
   - Wait for me to test and confirm
   - ONLY THEN move to completed and add learnings

3. Once I've tested the problems and report back that it looks good to go (may take some iterating with you) --- remove the problems from the problem section --- move it to completed problems --- renumber both sections --- add ONLY gotchas/important insights to the learnings section at the top --- then give me a very short summary of everything done in the current diffs so I can commit --- also update app_flow / claude_md as well if necessary

4. Learnings section is for gotchas and important insights that will help future development - NOT comprehensive feature lists

5. If I dont ask you to do / work on outstanding problems --- just proceed as normal with the context on the project. 


CONTEXT: 

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Remember to always keep code clean and concise. 

Let's also remember to put logs that explain the logical flow of the code to anyone watching logs while running the app. The user is new to swift and iOS development and adding logs to the code to explain the general app_flow (see APP_FLOW.md) will help debug things 



## Project Overview

**bgb-cpg** is a SwiftUI iOS party game app implementing "Wiki-Celebrity" - a 3-round progressive guessing game where teams cycle through the same deck with increasingly restrictive rules (Describe → One Word → Charades).

## Build and Development Commands

### Building and Running
- **Build and run**: Open `bgb-cpg.xcodeproj` in Xcode and use Cmd+R
- **Run on simulator**: Use Xcode's built-in iOS Simulator
- **Run tests**: Cmd+U in Xcode or use Test Navigator
- **Run single test**: Navigate to specific test in Test Navigator and click the diamond icon

### Testing Framework
- Uses Swift Testing framework (not XCTest)
- Test files located in `bgb-cpgTests/` and `bgb-cpgUITests/`
- Primary test file: `bgb_cpgTests.swift`

### Target Information
- **Main target**: bgb-cpg (iOS app)
- **Bundle ID**: board-game-barrage.bgb-cpg (iOS), board-game-barrage-bgb-cpg (iPhone specific)
- **Deployment targets**: iOS 18.5+, macOS 15.5+, visionOS 2.5+
- **Swift version**: 5.0
- **Xcode version**: 16.4

## Architecture Overview

### State Management Pattern
The app uses a **single source of truth** pattern with `GameStore` as the central `ObservableObject`:

```
bgb_cpgApp → ContentView → Stage-based View Routing → GameStore methods → State updates → UI re-renders
```

### Core Components

#### 1. GameStore.swift
- **Purpose**: Central state manager and business logic
- **Key responsibilities**: 
  - Game state (stage, settings, players, deck, scores)
  - Turn lifecycle (timer, pause/unpause, skip rules, scoring)
  - Player intake pipeline (candidate generation, de-duplication)
  - Round transitions and deck management
  - Bonus time system (flow time for completing all cards)
  - Player statistics tracking and display
- **Main state**: `@Published` properties for stage, settings, players, deck, scores
- **Private state**: Bonus time tracking (`savedBonusTime`, `bonusTimePlayer`)

#### 2. GameModels.swift  
- **Purpose**: Core data types and game logic
- **Key types**: `Team`, `Stage`, `RoundPhase`, `Settings`, `Player`, `Card`, `Token`, `PlayerStats`
- **Enums**: Define game phases, team colors, round rules, skip policies
- **New stages**: `turnPaused`, `turnSkipComplete`, `gameStats` for enhanced turn control

#### 3. ContentView.swift
- **Purpose**: Main view router based on `store.stage`
- **Pattern**: Uses switch statement to render appropriate view for current game stage
- **Background**: Dynamic gradient that changes with stage/round

#### 4. TitleBank.swift
- **Purpose**: Offline content generation for game cards
- **Content**: "Wikipedia-ish" title pools with filtering capabilities
- **Why**: Allows app to function without network connectivity

#### 5. Components.swift
- **Purpose**: Shared UI components
- **Key components**: `BigButton`, `OutlineButton`, `TokenChips`, `FlowLayout`, `ConfettiView`

#### 6. View Files (Views_*.swift)
Organized by feature area:
- `Views_HomeHowTo.swift`: Home screen and game rules
- `Views_SettingsIntake.swift`: Game setup and player registration
- `Views_RoundTurnRecap.swift`: Core gameplay UI
- `Views_RoundEnd_GameEnd.swift`: Scoring and end states

### State Machine Flow
```
.home → .settings → .intakeHandoff → .intakeName → .intakePicks → .roundIntro → 
.turnHandoff → .turn → (.turnPaused | .turnSkipComplete | .recap) → 
(.turnHandoff | .roundEnd) → (.roundIntro | .gameEnd) → (.gameStats | .home | .roundIntro)
```

### Key Game Rules Implementation
- **Deck consistency**: Same cards used across all 3 rounds, reshuffled between rounds
- **Skip logic**: Rounds 2-3 allow skips until processing all initially available cards (skipCount + correctCount ≥ initialDeckSize && skipCount > 0), then **turn auto-ends** with confirmation
- **Bonus time system**: Complete all cards in a turn → save remaining time for next round with priority queue
- **Auto-end triggers**: Turn ends when (1) timer expires, (2) processed all available cards, (3) all cards completed, (4) manual end
- **Token system**: Title words broken into "no-say" chips with special handling for articles (The/A/An)
- **Scoring**: Cumulative across rounds with per-round breakdowns
- **Player statistics**: Real-time tracking of turns, correct answers, fastest/slowest times

## File Organization

```
bgb-cpg/
├── bgb_cpgApp.swift          # App entry point, GameStore injection
├── ContentView.swift         # Main view router
├── GameStore.swift           # Central state management
├── GameModels.swift          # Core data types
├── TitleBank.swift           # Offline content generation
├── Components.swift          # Reusable UI components
├── Haptics.swift            # Haptic feedback wrapper
├── Views_HomeHowTo.swift    # Home & tutorial screens
├── Views_SettingsIntake.swift # Setup flow
├── Views_RoundTurnRecap.swift # Gameplay screens
├── Views_RoundEnd_GameEnd.swift # End game screens
└── Assets.xcassets/         # App icons and colors
```

## Development Notes

### Documentation Maintenance
**CRITICAL**: After making ANY code changes, ALWAYS update documentation to keep it current:
- **README.md**: Update game rules, new features, user-facing behavior
- **CLAUDE.md**: Update architecture, state flows, component descriptions  
- **APP_FLOW.md**: Update technical flow, state machine, data patterns
- Check that all three files accurately reflect the current implementation

### UI Framework
- **SwiftUI-only** implementation with iOS 18.5+ target
- **Design style**: Clean, minimal UI inspired by Letterpress
- **Animations**: Spring-based transitions for card interactions, fade transitions for screens
- **Haptics**: Light impact feedback on key interactions

### Data Flow Patterns
- **Unidirectional data flow**: Views read from `@EnvironmentObject var store: GameStore`
- **Actions**: Views call `store.methodName()` to trigger state changes
- **No direct state mutation**: All state changes go through GameStore methods
- **Deck management**: Stable order within rounds, repositioning for skips/timeouts

### Extension Points
- **Additional stats**: Store per-turn event log in GameStore for richer analytics
- **Network content**: Replace TitleBank with Wikipedia API while keeping filter logic
- **Accessibility**: Add VoiceOver labels to turn controls and token chips
- **Multi-platform**: Current build supports iOS, macOS, and visionOS

## Common Workflows

### Adding New Game Rules
1. Update `RoundPhase` enum in `GameModels.swift` for rule text
2. Implement logic in `GameStore` turn methods (`markCorrect`, `skipCard`, `pauseTurn`, etc.)
3. Update UI in relevant `Views_*.swift` files
4. Consider impact on bonus time system and player statistics

### Adding New View Stages
1. Add case to `Stage` enum in `GameModels.swift`
2. Add case to switch statement in `ContentView.swift`
3. Create view implementation in appropriate `Views_*.swift` file
4. Add transition logic in `GameStore` methods

### Modifying Intake Flow
1. Update player collection logic in `GameStore` intake methods
2. Modify candidate generation in `TitleBank` if needed
3. Update UI flow in `Views_SettingsIntake.swift`
4. Initialize `PlayerStats` for new players in `submitPlayerAndPicks()`