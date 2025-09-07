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



## Key Learnings & Development Insights

### SwiftUI Touch & UI Patterns
- Use `Color.white.opacity(0.001)` for invisible but tappable areas, not `Color.clear`
- Modifier order matters: padding after background creates visual borders, padding before affects the background
- Fixed button sizing prevents layout shifts when dynamic content changes

### State Management & Timing
- Timer logic needs both `turnActive` AND `!turnPaused` checks for proper pause handling 
- Skip logic requires count-based detection: `skipCount + correctCount ≥ initialDeckSize && skipCount > 0`
- Bonus time system: check for bonus player first before normal team rotation

### User Experience Design
- Validation errors should only appear after user interaction begins (e.g., after typing starts)
- Information hierarchy is crucial: primary actions prominent, diagnostic info clearly secondary
- Turn completion notifications should explain different end scenarios clearly

### Game Flow Management
- Mid-game settings changes should affect future rounds, not current gameplay
- Turn end detection should trigger immediately, not just lock further actions
- Remove obsolete logic entirely when changing flow to avoid confusing UI states