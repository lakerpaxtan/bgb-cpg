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

1. Update the how to play slides to actually have better versions of the rules --- and get rid of the placeholder at the end 

---

# Completed Problems

1. ~~Front page is too white --- let's make it colorful (or at least one color lol) --- remember to keep it clean~~ ✅

2. ~~On the How to Play tab --- there are no borders on the left and right edge of the Back button --- it collides with the edge of the iphone --- it should be approximately the same borders / dimensions of the start game / how to play buttons~~ ✅

3. ~~On the Enter your name page --- there is a lot of center white space --- lets add a cute tip for them to read --- ill let you decide what it says~~ ✅

4. ~~On the settings page there is no way to go back to the main menu --- lets add a standard back button to go back to main menu~~ ✅

5. ~~On the settings page after clicking start game --- there is no reason to have Team A and Team B picker be there~~ ✅

6. ~~On the enter your name page / flow --- the player should not be able to select their team --- lets just force the first x/2 players to be team A and the follow x/2 players to be team B --- get rid of the picker altogether --- but have a title showing that they are team A~~ ✅ 