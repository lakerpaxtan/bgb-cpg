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