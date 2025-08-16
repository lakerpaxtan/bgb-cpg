# APP\_FLOW\.md (Technical Overview)

## Overview

SwiftUI app with a single source of truth: **`GameStore`** (`ObservableObject`) injected via `.environmentObject`. Views render off a simple **state machine** (`Stage` enum) and call `GameStore` methods to transition.

```
Entry → App State → Stage-driven Views → Actions update GameStore → Stage changes → UI updates
```

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
    * `.turnPaused` → `TurnPausedView`
    * `.turnSkipComplete` → `TurnSkipCompleteView`
    * `.turn` → `TurnView`
    * `.recap` → `RecapView`
    * `.roundEnd` → `RoundEndView`
    * `.gameEnd` → `GameEndView`
    * `.gameStats` → `GameStatsView`

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
  Offline “Wikipedia-ish” title pools per subject + simple filters (years, lists, disambiguation). Lets the app run with no network.

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

* `IntakeHandoffView` → **I’m next** → `store.intakeProceed()` → `.intakeName`
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

* `TurnHandoffView` → **I'm {ClueGiver} — Start Turn** → `store.beginTurn()` → `.turn`.

### 4) Turn

* `TurnView` starts the timer (`Timer.publish`) in `store.beginTurn()`:

  * `startCardID` = current top card; tracks skip cycle completion.
  * **Bonus time**: If player completed all cards previous round, uses saved time instead of default.
  * **Correct** → `store.markCorrect()`:

    * Removes current top; records `CorrectEvent` (with duration + player stats).
    * If deck empty → save remaining time as bonus, end turn immediately.
  * **Skip** (R2/R3 only) → move top card to bottom; if `skipCount + correctCount ≥ initialDeckSize && skipCount > 0` → auto-end turn via `.turnSkipComplete`.
  * **Pause** → `store.pauseTurn()` → `.turnPaused` (can unpause or end turn).
  * **End Turn** → confirmation → `store.finishTurnToRecap()`.
  * **Timer end** → `store.finishTurnToRecap()`:

    * Push current top to bottom.
    * Apply turn score to `RoundScore` + cumulative.
    * Stage → `.recap`.

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

  * **Rematch (same settings)** → `store.rematchSameSettings()` → `.roundIntro`
  * **New Game** → `store.newGame()` → `.home`

---

## State Machine (Stages)

```
.home
  → .howTo | .settings
.settings
  → .intakeHandoff
.intakeHandoff → .intakeName → .intakePicks → (repeat) … → .roundIntro
.roundIntro → .turnHandoff → .turn → (.turnPaused | .turnSkipComplete | .recap)
.turnPaused → (.turn | .recap)
.turnSkipComplete → .recap
.recap → (.turnHandoff | .roundEnd)
.roundEnd → (.roundIntro | .gameEnd)
.gameEnd → (.gameStats | .roundIntro via Rematch | .home via New Game)
.gameStats → .gameEnd
```

---

## Data Flow & Invariants

* **Single source of truth**: `GameStore` holds settings, players, deck, scores, timers.
* **Deck** is rebuilt only between rounds, never during; order is stable within a round.
* **Skips** follow round rules; auto-end turn after processing all initially available cards in R2/R3.
* **Bonus time** system rewards completing all cards with saved time for next round.
* **Player statistics** track all turns, correct answers, and timing data throughout game.
* **Undo** reverts both deck position and score (and removes bonus if cards untoggled).
* **Token chips** come from `GameStore.tokens(for:)` (split on non-alphanumerics; leading article optional per `settings.acceptance`).

---

## UI & Interaction

* Buttons: `BigButton` for primary, `OutlineButton` for secondary.
* Animations: springy inserts/removals for card transitions; short fades for screens.
* Haptics: light impact on taps; success/warning/error where it helps.

---

## Extending the App (where to plug in)

* **Enhanced stats**: current system tracks per-player stats; could expand to per-turn event logs.
* **Real Wikipedia fetch**: swap `TitleBank` for a service; keep `TitleFilter` rules.
* **Accessibility**: add VoiceOver labels to Turn view controls and chips.
* **Bonus time variations**: could implement team-based or cumulative bonus systems.

---
