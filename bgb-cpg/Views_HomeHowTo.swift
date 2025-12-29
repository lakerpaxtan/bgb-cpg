import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: GameStore

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Wiki-Celebrity")
                .font(.system(size: 42, weight: .heavy, design: .rounded))
                .tracking(0.5)
                .foregroundStyle(.primary)

            Text("R1: Infinite Words | R2: One word | R3: No words")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            BigButton(title: "Start Game") {
                store.startSettings()
            }
            OutlineButton(title: "How to Play") {
                store.showHowTo()
            }

            Spacer()
        }
        .padding(24)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.25),
                    Color.purple.opacity(0.15),
                    Color.cyan.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .transition(.opacity.combined(with: .scale))
    }
}

struct HowToView: View {
    @EnvironmentObject var store: GameStore
    @Environment(\.presentationMode) var presentationMode

    let slides: [String] = [
        "Wiki-Celebrity is a 3-round party game where teams guess Wikipedia-style titles using the same deck each round, with progressively harder rules. Test your knowledge and creativity!",
        
        "GAME SETUP\n\n• 4-10 players split automatically into Team A and Team B\n\n• Each player contributes 3 titles from categories like People, Places, Movies, etc.\n\n• All titles go into one shared deck\n\n• Teams alternate having one \"clue-giver\" while teammates guess",
        
        "BASIC TURN FLOW\n\n• Clue-giver takes phone and faces their team\n\n• Timer starts (default 60 seconds)\n\n• See a title → give clues → team guesses → tap \"Correct\"\n\n• Keep going until time runs out or cards finished\n\n• Review which answers to highlight for scoring\n\n• Pass to other team",
        
        "THE FORBIDDEN WORDS SYSTEM\n\n• You CANNOT say any word from the title\n\n• Forbidden words appear as gray chips below the title\n\n• Example: \"The Great Wall of China\" → can't say \"Great,\" \"Wall,\" or \"China\"\n\n• Articles within the phrase (like \"of\") are required when guessing\n\n• Leading articles (The/A/An) are optional - teams can say them or not\n\n• Breaking this rule = immediate skip to next card",
        
        "ROUND 1 — DESCRIBE\n\n• Say anything except forbidden words from the title\n\n• No spelling, initials, translations, rhymes, or gestures\n\n• NO SKIPS - must work through every card\n\n• Most open round: tell stories, give context, describe freely\n\n• Strategy example: \"The Great Wall of China\" → \"4 words, proper noun, ancient barrier built to keep invaders out of Asia\"",
        
        "ROUND 2 — ONE WORD\n\n• Say exactly ONE WORD per card, then stop\n\n• Choose your single word carefully!\n\n• SKIPS ALLOWED until you've processed every card once\n\n• When you've seen all cards → turn automatically ends\n\n• Same deck, much harder: \"Great Wall of China\" → \"Barrier\" (and that's it!)",
        
        "ROUND 3 — CHARADES\n\n• NO WORDS AT ALL - only gestures and non-verbal sounds\n\n• Act it out, make sound effects, point, mime\n\n• Skip rules same as Round 2\n\n• Hardest but most entertaining: act out \"Great Wall of China\" with building motions",
        
        "SCORING & TURN ENDINGS\n\n• Each correct = 1 point, scores accumulate across rounds\n\n• Turn ends when: timer expires, clue-giver manually ends, or all available cards processed\n\n• After each turn: review and toggle off any highlights where you made mistakes (accidentally hit correct or realized you cheated)",
        
        "BONUS TIME SYSTEM\n\n• Complete ALL cards in your turn WITHOUT skipping = save remaining time\n\n• That saved time becomes your timer for next round\n\n• Huge advantage! Completing deck in 30s = 30s timer next round\n\n• Rewards having extra time and not needing skips",
        
        "ADDITIONAL CONSIDERATIONS\n\n• Deck maintains same order during each round, but reshuffles between rounds\n\n• Pause anytime to adjust timer or review rules\n\n• We may add other features here later"
    ]
    
    // Detect if we're in a NavigationView (like when accessed from pause menu)
    private var isInNavigationView: Bool {
        // When accessed from pause menu, we're in a presented sheet context
        // When accessed from main menu, presentationMode.isPresented is false
        presentationMode.wrappedValue.isPresented
    }

    var body: some View {
        VStack(spacing: 0) {
            TabView {
                ForEach(slides.indices, id: \.self) { i in
                    Text(slides[i])
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 40)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .padding(.bottom, 16)

            // Only show Back button when not in a NavigationView (i.e., accessed from main menu)
            if !isInNavigationView {
                BigButton(title: "Back") { store.goHome(resetAll: false) }
                    .padding(.horizontal, 24)
            }
        }
        .padding(.bottom, 24)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.25),
                    Color.purple.opacity(0.15),
                    Color.cyan.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}
