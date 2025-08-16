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

No outstanding problems at this time! 🎉
---

# Completed Problems

1. ~~Front page is too white --- let's make it colorful (or at least one color lol) --- remember to keep it clean~~ ✅

2. ~~On the How to Play tab --- there are no borders on the left and right edge of the Back button --- it collides with the edge of the iphone --- it should be approximately the same borders / dimensions of the start game / how to play buttons~~ ✅

3. ~~On the Enter your name page --- there is a lot of center white space --- lets add a cute tip for them to read --- ill let you decide what it says~~ ✅

4. ~~On the settings page there is no way to go back to the main menu --- lets add a standard back button to go back to main menu~~ ✅

5. ~~On the settings page after clicking start game --- there is no reason to have Team A and Team B picker be there~~ ✅

6. ~~On the enter your name page / flow --- the player should not be able to select their team --- lets just force the first x/2 players to be team A and the follow x/2 players to be team B --- get rid of the picker altogether --- but have a title showing that they are team A~~ ✅

7. ~~Update the how to play slides to actually have better versions of the rules --- and get rid of the placeholder at the end~~ ✅

8. ~~After you are done typing your name and you hit Next --- while still having the keyboard open --- there is a weird highlighting render that remains on the transitioned screen for a monent after transitioning to the your picks screen~~ ✅

9. ~~If you select a card and then hit reload on that card -- things get wonky --- make sure to trigger the uncheck whenever the user hits reload (or at least do it functionally)~~ ✅

10. ~~I'm not 100% certain this is a problem it's hard to reproduce --- but can you make sure that once one person has selected a card --- its been removed from the possible selection pool. We can't have people picking the same title. Same thing with reloading --- make sure its not reloading randomly and its reloading from only the remaining cards (total cards - cards on screen - cards already selected by other players)~~ ✅

11. ~~Remove all one word titles in the safety word bank outside of wikipedia --- also skew away from people's names --- there can be some but really skew from the ones international players might not know~~ ✅

12. ~~After the "show controls button" it shouldnt be a set time before the timer automatically start --- we should show a blurred out version of the upcoming screen with a start button in the center so the player can set down the phone --- get themselves ready and familiar with the controls (without seeing the upcoming word) --- then hit start when you are ready --- you can keep the preceeding screen that says show controls though that's fine~~ ✅

13. ~~We dont need an undo button on the turn recap screen --- the toggle selector is perfect --- the ones that you untoggle should be put to the bottom of the deck --- im honeslty not sure wha tthe different between undo and toggle even is in the app right now --- but we dont need undo~~ ✅

14. ~~On the turn recap screen we dont need to show the skips this turn~~ ✅

15. ~~On the player selection screen --- let's have a difficult to press button that says (restart back to settings screen) --- which will take you back to the settings screen if you want to exit~~ ✅

16. ~~Add restart buttons with confirmation to all intake screens (Pass-Around, Enter Name, Your Picks) with shared component~~ ✅

17. ~~Collect stats on players (times, successes) and show stats screen at end of game~~ ✅

18. ~~Fix haptics on Your Picks - trigger on selection, not on error~~ ✅

19. ~~Allow players to select more than allotted titles in Your Picks with dynamic button text~~ ✅

20. ~~Change Your Picks button text to 'Submit' when ready and add tip about remembering titles~~ ✅

21. ~~Add pause button to main gameplay screen with pause view~~ ✅

22. ~~Add end turn button with confirmation alert~~ ✅

23. ~~Remove primer screen and go directly from turnHandoff to turnReady with clue giver tip~~ ✅

24. ~~Auto-end turn when skipping cycles back to start card with confirmation screen~~ ✅

25. ~~Implement bonus time system for completing all cards in a round~~ ✅

26. ~~Auto-end turn immediately when completing last card~~ ✅

27. ~~Create gray confirmation screen for skip cycle completion~~ ✅

28. ~~Fix skip logic bug and remove obsolete skip locking~~ ✅

29. ~~Fix critical skip logic bug where completing start card allowed infinite skipping. Implemented count-based detection (skipCount + correctCount ≥ initialDeckSize && skipCount > 0) to properly distinguish between completing all cards vs cycling through via skips. Updated all documentation.~~ ✅

30. ~~Change cumulative to total on the round complete screen so both team names fit lol~~ ✅

31. ~~The view player stats screen at the end is weirdly offset --- the Player Stats should be a title at the top and so should the back button --- right now the whole thing starts like 1/3 of the way to the bottom of the screen and there is a weirdly large gap between player stats and the scrolling stats view~~ ✅

32. ~~On the word selection screen --- make it so you can hit the whole card to trigger selection --- no need to make people aim and target the little circle~~ ✅

33. ~~On turn handoff page shortern the Skips explanation. Same message just shorter.~~ ✅

34. ~~On the get ready and turn complete notifications --- add left/right borders so it doesn't stretch edge to edge horizontally~~ ✅

35. ~~Dont let players submit their names without having a unique name. Also dont let it be blank or just spaces.~~ ✅

36. ~~Let's add a counter to the main gameplay screen that shows cards left in the deck and how many you've skipped and how many you've marked as correct.~~ ✅

37. ~~Let's move the end turn button on the main gameplay screen to the top near the pause button with static sizing.~~ ✅

38. ~~On pause menu let me end game altogether and return to main menu~~ ✅

39. ~~On pause menu create a little settings menu where you can adjust timer in the middle of the game.~~ ✅

40. ~~On the skip description in the turn view - put better text that's easier to interpret.~~ ✅

41. ~~Use turn complete notifications for all turn end transitions with explanations for all options.~~ ✅

42. ~~Redesign top buttons (pause/end) as horizontal pills with text+icon and static sizing.~~ ✅

43. ~~Enhance Get Ready screen with cards remaining and bonus time continuation info.~~ ✅

44. ~~Redesign deck counter with proper information hierarchy and move diagnostics below buttons.~~ ✅

45. ~~Fix name validation to only show errors after user starts typing to avoid appearing rude.~~ ✅