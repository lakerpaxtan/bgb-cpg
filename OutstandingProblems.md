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

---

# Outstanding Problems
# (do not cross off problems without checking with me first)

1. Let's get rid of the loading screen between when player turns where it shows the hand and loads the next view --- I want it to go straight from the screen saying pass to Player X --- to the greyed out screen where you can start whenever you are ready --- so basically just get rid of the "only the clue giver should see the screen" screen with the hand. In addition --- lets add that tip (the only the clue giver should see the screen) --- to the "get ready" start timer greyed out screen. Clarify with me if you are unsure what I mean here

2. When you cycle through all the words from skipping (IE there are still cards left in the deck, but you've gotten back to the beginning of the deck from turn start) --- your turn should end immediately with a notification / confirmation window saying as such 

3. This one is a bit more complicated. If your turn ends from guessing all the words successfully --- you need to actually save down the remaining time for THAT PLAYER, then switch to the next round as usual, but have the same player go again, but start the timer with the remaining time left they had from the previous round.... in addition, if they UNSELECT one of the cards after their turn (after their turn, before the round switches) --- they technically didnt win the round --- so their turn ends as it does from skipping back to the beginning of the deck and the round conitnues with the next player as usual. The idea here is that if you finish the round and make it through all the cards you get rewarded by starting the next round with your remaining time --- but you dont get that if you didnt actually complete all the remaining words (hence the unchecking clause)

4. Dont let players submit their names without having a unique name. Also dont let it be blank or just spaces. 

5. Change cumulative to total on the round complete screen so both team names fit lol

6. Let's add a counter to the main gameplay screen that shows cards left in the deck and how many you've skipped and how many you've marked as correct. You can somehow combine this with the skip explanation you have --- since the number of skips is equal to the number of cards in the deck you have remaining to look through --- make it clear even in round 1 and round 2 though since one doesnt allow skips but you still want to see the counter 

7. Let's move the end turn button on the main gameplay screen to the top near the pause button --- not right next to but in the same row

8. The view player stats screen at the end is weirdly offset --- the Player Stats should be a title at the top and so should the back button --- right now the whole thing starts like 1/3 of the way to the bottom of the screen and there is a weirdly large gap between player stats and the scrolling stats view 

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