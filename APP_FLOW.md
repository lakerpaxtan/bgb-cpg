# APP_FLOW.md (Technical Overview)

## Project Overview

**bgb-cpg** is a SwiftUI iOS party game app implementing "Wiki-Celebrity" - a 3-round progressive guessing game where teams cycle through the same deck with increasingly restrictive rules (Describe → One Word → Charades).

## Overview

SwiftUI app with a single source of truth: **`GameStore`** (`ObservableObject`) injected via `.environmentObject`. Views render off a simple **state machine** (`Stage` enum) and call `GameStore` methods to transition.

```
Entry → App State → Stage-driven Views → Actions update GameStore → Stage changes → UI updates
```

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

---

## Entry & Dependency Graph

* **`bgb_cpgApp.swift`**

  * Creates `@StateObject var store = GameStore()`
  * Injects into `ContentView().environmentObject(store)`

* **`ContentView.swift`**

  * Renders a gradient background and a `switch` on `store.stage`:

    * `.home` → `HomeView`
    * `.howTo` → `HowToView`
    * `.settings` → `SettingsView`
    * `.intakeHandoff` → `IntakeHandoffView`
    * `.intakeName` → `IntakeNameView`
    * `.intakePicks` → `IntakePicksView`
    * `.roundIntro` → `RoundIntroView`
    * `.turnHandoff` → `TurnHandoffView`
    * `.turn` → `TurnView`
    * `.turnPaused` → `TurnPausedView`
    * `.turnSkipComplete` → `TurnSkipCompleteView`
    * `.turnComplete` → `TurnCompleteView`
    * `.recap` → `RecapView`
    * `.roundEnd` → `RoundEndView`
    * `.gameEnd` → `GameEndView`
    * `.gameStats` → `GameStatsView`

---

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

### Key Game Rules Implementation
- **Deck consistency**: Same cards used across all 3 rounds, reshuffled between rounds
- **Skip logic**: Rounds 2-3 allow skips until processing all initially available cards (skipCount + correctCount ≥ initialDeckSize && skipCount > 0), then **turn auto-ends** with confirmation
- **Bonus time system**: Complete all cards in a turn → save remaining time for next round with priority queue
- **Auto-end triggers**: Turn ends when (1) timer expires, (2) processed all available cards, (3) all cards completed, (4) manual end
- **Token system**: Title words broken into "no-say" chips with special handling for articles (The/A/An)
- **Scoring**: Cumulative across rounds with per-round breakdowns
- **Player statistics**: Real-time tracking of turns, correct answers, fastest/slowest times

---

## Key Files (what/why)

* **`GameModels.swift`**
  Core types: `Team`, `Stage`, `RoundPhase`, `Settings` (with defaults), `Filters`, `Acceptance`, `SkipsRule`, `StatsPref`, `Player`, `Card`, `Token`, `CorrectEvent`, `RoundScore`.

* **`GameStore.swift`**
  App state + logic:

  * Global state (`stage`, `settings`, `players`, `allCards`, `deck`, scores).
  * Intake pipeline (candidate generation, picks, de-dupe + replacement).
  * Round/turn lifecycle (timer, skip rules, correct handling, recap/undo, round end, next round).
  * Simple highlight generation between rounds.
  * Tokenization for “no-say” chips (leading article optional).

* **`TitleBank.swift`**
  Offline "Wikipedia-ish" title pools per subject + simple filters (years, lists, disambiguation). Lets the app run with no network.

* **`WikipediaService.swift`**
  Optional Wikipedia integration that fetches live articles based on categories and filters. Provides fallback to offline mode if Wikipedia is unavailable.

* **`Components.swift`**
  Shared UI: `BigButton`, `OutlineButton`, `TokenChips`, `FlowLayout`, lightweight `ConfettiView`.

* **`Views_*`**
  Feature screens split by concern:

  * `Views_HomeHowTo.swift` — Home + How To slides
  * `Views_SettingsIntake.swift` — Settings + Intake flow
  * `Views_RoundTurnRecap.swift` — Round intro, handoff, primer, turn UI, recap
  * `Views_RoundEnd_GameEnd.swift` — Round summary, final screen

* **`Haptics.swift`**
  Small wrapper for impact/notification feedback.

---

## App Lifecycle & Control Flow

### 1) Home → Settings

* `HomeView`

  * **Start Game** → `store.startSettings()` → `.settings`
  * **How to Play** → `.howTo`

* `SettingsView`

  * Edits a local copy of `Settings`, then commits to `store.settings`.
  * **Next — Player Intake** → `store.startIntake()` → `.intakeHandoff`

### 2) Intake (Team A then Team B)

* `IntakeHandoffView` → **I'm next** → `store.intakeProceed()` → `.intakeName`
* `IntakeNameView` → **Next** → `store.intakeSaveNameAndShowPicks()` → `.intakePicks`
* `IntakePicksView`

  * Shows N candidates (`store.generateCandidates()`).
  * **Reroll** (`store.reroll`) swaps a single card.
  * **Select** limited to M; **Review & Submit** → `store.submitPlayerAndPicks()`:

    * Adds the new `Player`.
    * Adds chosen `Card`s to `allCards` with case-insensitive de-dupe.
    * If de-dupe shrinks count, draws replacements to keep “one card per pick”.
  * `store.advanceIntakePointer()` repeats until `settings.players` reached, then → `.roundIntro`.

### 3) Round Start

* `RoundIntroView` → **Start Round N** → `store.startRound()`:

  * Shuffles `allCards` into `deck` if needed.
  * Sets next `clueGiver` based on team rotation.
  * Stage → `.turnHandoff`.

* `TurnHandoffView` → **I'm {ClueGiver} — Get Ready** → `store.beginTurn()` → `.turn`

### 4) Turn

* `TurnView` starts the timer (`Timer.publish`) in `store.beginTurn()`:

  * `startCardID` = current top card; tracks skip cycle completion.
  * **Bonus time**: If player completed all cards previous round, uses saved time instead of default.
  * **Correct** → `store.markCorrect()`:

    * Removes current top; records `CorrectEvent` (with duration + player stats).
    * If deck empty → save remaining time as bonus, end turn immediately.
  * **Skip** (R2/R3 only) → move top card to bottom; if `skipCount + correctCount ≥ initialDeckSize && skipCount > 0` → auto-end turn via `.turnSkipComplete`.
  * **Pause** → `store.pauseTurn()` → `.turnPaused` (can unpause, end turn, or adjust settings).
  * **End Turn** → confirmation → `store.finishTurnToRecap()` → `.turnComplete` (except skip cycle).
  * **Timer end** → `store.finishTurnToRecap()` → `.turnComplete`:

    * Push current top to bottom.
    * Apply turn score to `RoundScore` + cumulative.
    * Show turn end explanation, then → `.recap`.

### 5) Recap

* `RecapView`

  * Toggle **highlight** per correct.
  * **Undo** → `store.undo(event:)` reinserts the card at its prior position and decrements score.
  * **Next** → `store.recapDoneNextHandoff()`:

    * If `deck` empty → `.roundEnd`; else alternate team → `.turnHandoff`.

### 6) Round End / Next Round / Game End

* `RoundEndView` shows round & cumulative scores + lightweight highlights.

  * **Round N+1 Rules** → `store.proceedToNextRoundOrEnd()`: reshuffle same cards; start next round intro.
  * After Round 3 → `.gameEnd`.

* `GameEndView` shows winner or “It’s a tie!”, confetti, and:

  * **Main Menu** → `store.newGame()` → `.home`

---

## State Machine (Stages)

```
.home
  → .howTo | .settings
.settings
  → .intakeHandoff
.intakeHandoff → .intakeName → .intakePicks → (repeat) … → .roundIntro
.roundIntro → .turnHandoff → .turn → (.turnPaused | .turnSkipComplete | .turnComplete)
.turnPaused → (.turn | .recap | .home via End Game)
.turnSkipComplete → .recap
.turnComplete → .recap
.recap → (.turnHandoff | .roundEnd)
.roundEnd → (.roundIntro | .gameEnd)
.gameEnd → (.gameStats | .home via Main Menu)
.gameStats → .gameEnd
```

---

## Data Flow & Invariants

* **Single source of truth**: `GameStore` holds settings, players, deck, scores, timers.
* **Deck** is rebuilt only between rounds, never during; order is stable within a round.
* **Skips** follow round rules; auto-end turn after processing all initially available cards in R2/R3.
* **Bonus time** system rewards completing all cards with saved time for next round.
* **Player statistics** track all turns, correct answers, and timing data throughout game.
* **Name validation** prevents blank/duplicate names with polite UX (errors only after typing begins).
* **Turn notifications** provide contextual explanations for different turn end scenarios.
* **Pause menu** includes mid-game timer adjustment and emergency exit options.
* **Undo** reverts both deck position and score (and removes bonus if cards untoggled).
* **Token chips** come from `GameStore.tokens(for:)` (split on non-alphanumerics; leading article optional per `settings.acceptance`).

---

## UI & Interaction

* Buttons: `BigButton` for primary, `OutlineButton` for secondary.
* Animations: springy inserts/removals for card transitions; short fades for screens.
* Haptics: light impact on taps; success/warning/error where it helps.

## Development & Debugging

* **Logging**: Comprehensive logging throughout GameStore and ContentView provides detailed app flow tracking. Watch Xcode Console to understand the execution path, state transitions, and function calls in real-time.
* **Print statements**: Use emoji prefixes (🏠 for home, ⚙️ for settings, 🎯 for turns, etc.) to categorize log messages by feature area.

---

## File Organization

```
bgb-cpg/
├── bgb_cpgApp.swift          # App entry point, GameStore injection
├── ContentView.swift         # Main view router
├── GameStore.swift           # Central state management
├── GameModels.swift          # Core data types
├── TitleBank.swift           # Offline content generation
├── WikipediaService.swift    # Wikipedia API integration
├── Components.swift          # Reusable UI components
├── Haptics.swift            # Haptic feedback wrapper
├── Views_HomeHowTo.swift    # Home & tutorial screens
├── Views_SettingsIntake.swift # Setup flow
├── Views_RoundturnRecap.swift # Gameplay screens (note: filename has typo)
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

## Extending the App (where to plug in)

* **Enhanced stats**: current system tracks per-player stats; could expand to per-turn event logs.
* **Real Wikipedia fetch**: swap `TitleBank` for a service; keep `TitleFilter` rules.
* **Accessibility**: add VoiceOver labels to Turn view controls and chips.
* **Bonus time variations**: could implement team-based or cumulative bonus systems.

---
