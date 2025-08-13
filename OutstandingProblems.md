# Learnings

## SwiftUI Button Touch Sensitivity
- `Color.clear` is completely transparent to touch events
- Use `Color.white.opacity(0.001)` for invisible but tappable areas
- OutlineButton needed `.background(Color.white.opacity(0.001))` to make the entire button area clickable, not just the border and text

## UI Consistency 
- Matching gradient backgrounds across views (Home and How to Play) reduces jarring transitions
- iOS-native back button style: `chevron.left` + "Back" text in blue, more subtle than custom OutlineButton

---

# Outstanding Problems
# (do not cross off problems without checking with me first)

1. Let's just in general collect stats on players --- times, number of successes --- then at the end of the game lets show a stats screen. This is in addition to the fun stats thing we already have in between rounds (i think we have this --- if we dont add something --- also add it to the app flow or readme if its not there I was having a hard time finding it)

2. Right now it seems like we are doing haptics when you click on more than 3 things in Your Picks --- haptics should indicate good thigns not bad --- so lets do haptics when you select a title at all 

3. Let's actually allow players to select more than their allotted X titles in the Your Picks screen --- but when they select too many lets grey out the review and submit button and have it say "Please select exactly X titles" --- and lets similarly do that when you havent selected enough

4. Lets change the button on Your Picks screen to just say submit when you are good to submit --- there is no reviewing being done 

5. Let's add a tip somewhere on the "Your Picks" screen that says something along the lines of "Do your best to remember the titles you selected --- It's an advantage for your team that only you know the title to start out!" 

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