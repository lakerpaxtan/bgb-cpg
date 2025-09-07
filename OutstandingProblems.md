# Learnings

## SwiftUI Button Touch Sensitivity
- `Color.clear` is completely transparent to touch events
- Use `Color.white.opacity(0.001)` for invisible but tappable areas
- OutlineButton needed `.background(Color.white.opacity(0.001))` to make the entire button area clickable, not just the border and text

## UI Consistency 
- Matching gradient backgrounds across views (Home and How to Play) reduces jarring transitions
- iOS-native back button style: `chevron.left` + "Back" text in blue, more subtle than custom OutlineButton

## Timer and State Management
- Timer logic needs to check both `turnActive` AND `!turnPaused` to properly handle pause states
- New stages (like `turnPaused`) require updates to ContentView switch statement, background colors, and GameStore methods

## Skip Logic and Turn Ending
- Skip cycle detection should end turns immediately, not just lock skips
- Obsolete `skipLocked` logic can create confusing UI states - remove entirely when changing flow
- When deck becomes empty from markCorrect(), immediately call finishTurnToRecap() for smooth UX
- Count-based skip cycle detection must verify skipCount > 0 to distinguish between "completed all cards" vs "skipped through all cards"

## Bonus Time System Implementation
- Track bonus player and time in private GameStore properties, reset on new games/rounds
- setNextClueGiverIfNeeded() should check for bonus player first before normal team rotation
- beginTurn() should apply bonus time and clear it immediately after use

## SwiftUI Layout and Padding
- Modifier order matters: `.padding(.horizontal, 24)` must come AFTER background/styling modifiers to create proper visual borders
- Padding before background affects the background itself; padding after background creates spacing around the styled element

## User Experience Design
- Validation errors should only appear after user interaction begins (e.g., typing) to avoid appearing rude or presumptuous
- Information hierarchy is crucial: primary actions/info should be visually prominent, diagnostic info should be clearly secondary
- Fixed button sizing prevents layout shifts when dynamic content (like timers) changes width

## Game Flow and Turn Management
- Turn completion notifications provide clear explanations for different end scenarios (timer, manual, completed all cards)
- Mid-game settings changes should affect future rounds, not current gameplay, to avoid disrupting active play
- Bonus time systems need clear visual indicators when active to help players understand game state

---

# Outstanding Problems
# (do not cross off problems without checking with me first)

1. Remove rematch functionality entirely and rename "New Game" to "Main Menu" - eliminate all rematch-related code and flows, update button text and functionality to simply return to main menu **[In Progress, Please Test]**
---

# Completed Problems

*All completed problems have been cleared to keep the file focused on current work.*