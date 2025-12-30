# bgb-cpg — Charade Barrage (Fishbowl-style party game)

A fast party charades game played in **3 rounds** with the **same deck** each time, getting progressively stricter.

This README is the single source of truth for:
- **How to play (rules + UX behavior)**
- **How the app works (architecture + state machine + workflows)**

---

## Quick Start (Player view)
1. Tap **Start Game** → configure players, starting team, timer, words per player, and manual word count.
2. **Pass the phone** to collect player names, pack picks, and any manual word entries (Team A first, then Team B).
3. Play **Round 1 → Round 2 → Round 3**. Scores show between rounds.
4. Final scoreboard + confetti. **Main Menu** returns to home.

---

## Rules of the Game

### Rounds
All rounds use the **same deck** (reshuffled between rounds). Gestures are always allowed.

**Round 1 — Describe**
- Say anything **except any part of the title**.
- No spelling, initials, translations, or rhymes.
- Skips: **Not allowed** (Skip button hidden).

**Round 2 — One Word**
- You may say **one word only** per card.
- Skips: allowed until you’ve processed all cards available at turn start; then your turn **auto-ends**.

**Round 3 — Charades**
- **No words**.
- Non-verbal sounds and gestures are OK.
- Skips: allowed until you’ve processed all cards available at turn start; then your turn **auto-ends**.

### Turns (what the app does)
- The app tells you who holds the phone each turn and shows **cards remaining** for that turn.
- Hit **Correct** when the guessers get it.
- **Complete all cards** in your turn → save remaining time as **bonus time** for your next turn.
- **Get Ready** screen shows bonus time when available and lets you start when ready.
- **Top controls**: **Pause** and **End** buttons with icons stay fixed as timer changes.
- **Turn notifications** explain why the turn ended (timer end, manual end, completing all cards, or skip-cycle completion).
- **Pause menu**: unpause, adjust timer settings (affects next round), or end game entirely.
- **Cards counter**: shows cards remaining this turn + diagnostics (skipped/correct/total).
- **Turn Recap**: only read out loud the **highlighted** correct answers (toggle highlight per item).
- **Undo** on recap removes that correct, reinserts the card at its prior position for this round, and reduces score.

### Guessing & “No-say” chips
- Title words render as **chips** for the clue-giver; those are the words you cannot say.
- If the title begins with **The/A/An**, that chip is **grey/optional** for guessing.
- All other tokens (including “of/and/in”) are considered required by the rules.
- Rules are **case-insensitive** and ignore punctuation.
- Plurals are **not** auto-forgiven (“cat” ≠ “cats”).
> The app doesn’t do speech recognition; players enforce guesses. Chips keep everyone honest.

### Skips (detail)
- **Round 1**: none (Skip hidden).
- **Rounds 2–3**: unlimited skips **until** you’ve processed all cards available at turn start
  (via skips + correct answers); then your turn ends automatically with a confirmation screen.

### Deck & scoring
- Deck order is **stable within a round**.
- Cards you **Skip** or **time out on** are sent to the **bottom**.
- Between rounds, the deck is **shuffled**, but it’s the **same cards**.
- Scores show **this round** and **cumulative** totals after the round ends.
- Ties are fine; the app calls it out.

---

## Content Sources & Packs
The app offers **3 curated content packs**:

### Standard (283 titles)
Familiar idioms, movies, food, and everyday phrases. Great for casual play.
- Categories: Movies & TV, Music, Brands, Food, Everyday Things
- Difficulty: Easy to Medium (obscurity 1–3)
- Length: Short titles (1–4 words)
- Examples: "The Matrix", "Avocado toast", "Elephant in the room"

### Obscure (89 titles)
Science facts, internet culture, and mind-bending concepts.
- Categories: Nerdy Stuff, Science & Nature, Random Facts, Internet Culture
- Difficulty: Medium to Hard (obscurity 3–5)
- Length: Longer titles (2–6 words)
- Examples: "Fermi paradox", "Trolley problem", "Mandela effect"

### Custom
Build your own pack with custom filters.
- Select from 12 categories
- Set obscurity (1–5) and word count (1–10)
- Perfect for themed game nights or specific interests
- Filters the full 370+ title database based on preferences

---

## Player Intake (how setup works)
- Collect Team A first, then Team B.
- **Name validation**: must be unique and non-blank; errors appear only after typing begins.
- Each player sees **N word pool options** and must pick **M non-manual words**.
- If manual words are enabled, each player enters **K manual words** after picking.
- **Reroll** swaps a single candidate word.
- Selection UX: tap anywhere on a card to select it (not just the circle).
- Submitting words:
  - Adds the new player.
  - Adds chosen cards with case-insensitive de-dupe.
  - If de-dupe shrinks the count, replacements are drawn to keep “one card per submitted pick”.
  - Adds manual words (6 words or fewer each).
- Intake repeats until `settings.players` is reached, then starts Round 1.

---

# Technical Overview

## Build / Test / Targets (Xcode)
- Build & run: open `bgb-cpg.xcodeproj` → Cmd+R
- Run on simulator: Xcode iOS Simulator
- Run tests: Cmd+U (or Test Navigator)
- Testing framework: **Swift Testing** (not XCTest)
  - Tests in `bgb-cpgTests/` and `bgb-cpgUITests/`
  - Primary test file: `bgb_cpgTests.swift`
- Targets:
  - Main target: bgb-cpg (iOS app)
  - Bundle IDs: `board-game-barrage.bgb-cpg` (iOS), `board-game-barrage-bgb-cpg` (iPhone specific)
  - Deployment: iOS 18.5+, macOS 15.5+, visionOS 2.5+
  - Swift 5.0, Xcode 16.4

## Architecture (high level)
Single source of truth:
- `GameStore` (`ObservableObject`) holds settings, players, deck, scores, timers, bonus-time state, and stats.
- `ContentView` switches on a `Stage` enum to render the active screen.
- Views call `GameStore` methods; they do not mutate state directly (unidirectional flow).

Entry graph:
`bgb_cpgApp → ContentView → Stage-based view routing → GameStore methods → @Published updates → UI re-renders`

## Core files (what/why)
- `GameStore.swift`: central state + business logic (turn lifecycle, scoring, intake, round transitions, bonus time, stats).
- `GameModels.swift`: core types (`Team`, `Stage`, `RoundPhase`, `Settings`, `Player`, `Card`, `Token`, `CorrectEvent`, `RoundScore`, etc).
- `ContentView.swift`: view router; gradient background changes by stage/round.
- `TitleBank.swift`: premade title pools + filtering so the app works without network.
- `Components.swift`: shared UI components (`BigButton`, `OutlineButton`, `TokenChips`, `FlowLayout`, `ConfettiView`).
- View files:
  - `Views_HomeHowTo.swift`: home + tutorial
  - `Views_SettingsIntake.swift`: setup + intake
  - `Views_RoundturnRecap.swift`: gameplay (note: filename has typo)
  - `Views_RoundEnd_GameEnd.swift`: scoring + end states

## Lifecycle & control flow (screens)
Home:
- Start Game → `.settings`
- How to Play → `.howTo`

Settings:
- Edits local copy of `Settings`, then commits to `store.settings`
- Next: either
  - `.packSelection` (when non-manual words are needed), or
  - `.intakeHandoff` (manual-only setup)

Pack selection:
- Choose Standard / Obscure / Custom
- Set word pool size per player
- Custom → `.customPackBuilder` → `.intakeHandoff`
- Standard/Obscure → `.intakeHandoff`

Intake (Team A then Team B):
`.intakeHandoff → .intakeName → .intakePicks → .intakeManualWords` (manual-only skips picks) repeating until full player count → `.roundIntro`

Round start:
- `startRound()` shuffles `allCards` into `deck` (if needed) and sets clue-giver rotation → `.turnHandoff`

Turn:
- `beginTurn()` starts timer and sets `startCardID`
- Bonus time: if earned previously, uses saved time instead of default
- Correct: removes top card, records a `CorrectEvent` (duration + stats); if deck becomes empty, saves remaining time and ends turn
- Skip (R2/R3 only): moves top card to bottom; if the “processed all starting cards” condition is met, auto-ends via `.turnSkipComplete`
- Pause: `.turnPaused` (unpause / end / adjust settings)
- End Turn: confirmation → `.turnComplete`
- Timer end: pushes current top to bottom, applies score, then `.turnComplete` → recap

Recap:
- Toggle highlight per correct
- Undo reinserts card at its prior position and decrements score
- Next: if deck empty → `.roundEnd`, else alternate team → `.turnHandoff`

Round end / game end:
- RoundEnd shows round + cumulative scores + highlights
- Proceed:
  - Round N+1 rules: reshuffle same cards → next round intro
  - After Round 3 → game end (winner or tie + confetti)
- Main Menu returns to `.home`

## Development & debugging
- Logging: keep comprehensive logs in `GameStore` and stage transitions; watch Xcode Console
- Prefer emoji prefixes for quick scanning (🏠 home, ⚙️ settings, 🎯 turns, etc.)
