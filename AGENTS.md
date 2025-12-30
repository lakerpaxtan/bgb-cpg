# AGENTS.md

## Project: bgb-cpg (Wiki-Celebrity / Fishbowl-style party game)
SwiftUI app with a single source of truth (`GameStore`) and a stage-based router (`Stage` enum → `ContentView` switch).
Keep changes small, testable, and easy to review.

## Quick commands (Xcode)
- Build & run: open `bgb-cpg.xcodeproj` → Cmd+R
- Run tests: Cmd+U (Swift Testing, not XCTest)
- Run a single test: Test Navigator → click the diamond next to the test

## Repo workflow: OutstandingProblems.md
If the user asks you to work from **OutstandingProblems.md**:
1. Pick one or more remaining problems and implement a fix.
2. Mark each fixed item as **[In Progress, Please Test]** (do NOT move it yet).
3. Stop and ask the user to test.
4. ONLY after the user confirms: move items to **Completed Problems**, renumber both sections,
   and add ONLY durable gotchas/insights to “Learnings” (no long feature dumps).
5. After confirmation, provide a short, review-friendly summary of the diffs.

## Engineering conventions (important)
- SwiftUI-only. Unidirectional flow:
  - Views read from `@EnvironmentObject var store: GameStore`
  - Views call `store.someMethod()` to change state
  - No direct state mutation from views
- Prefer clarity over cleverness. Avoid wide refactors unless asked.
- Add logging that explains the logical flow (this is a learning codebase).
  - Use emoji prefixes to group logs by area (🏠 home, ⚙️ settings, 🎯 turns, etc.)

## Game invariants to preserve (don’t regress)
- Deck is rebuilt only between rounds; stable ordering within a round.
- Skips are R2/R3 only; the “processed all starting cards” rule must still auto-end the turn.
- Bonus time: completing all cards can save remaining time for next-round turns.
- Undo must revert both score and deck position for that round.

## When you finish a task
- Ensure the app builds and relevant tests pass.
- Update docs when behavior changes:
  - `README.md` (this is the single source for rules + technical flow)
  - `AGENTS.md` if you changed workflow/conventions
  - `OutstandingProblems.md` only using the workflow above

## Review guidelines (used by @codex review too)
- No regressions in turn end conditions (timer end vs skip-cycle end vs manual end vs deck-empty end).
- No silent behavior changes: update README when rules/flow change.
- Keep diffs minimal and easy to reason about.
