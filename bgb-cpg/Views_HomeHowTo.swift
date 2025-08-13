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

            Text("3 rounds: Describe → One word → Charades!")
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

    let slides: [String] = [
        "Wiki-Celebrity is a 3-round party game where teams guess titles using the same deck of cards each round.",
        "Round 1: DESCRIBE\nSay anything except words from the title. No spelling, initials, or rhymes allowed.",
        "Round 2: ONE WORD\nYou can only say one word per card. Skips allowed until you cycle back to your starting card.",
        "Round 3: CHARADES\nNo words at all! Use gestures and sounds only. Skips work the same as Round 2.",
        "The app shows whose turn it is. Hit 'Correct' when teammates guess right. Timer runs for 60 seconds.",
        "Players enforce the rules themselves. Leading articles like 'The' or 'A' are optional when guessing.",
        "Cards you skip or time out on go to the bottom. Same deck reshuffles between rounds. Have fun!"
    ]

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

            BigButton(title: "Back") { store.goHome(resetAll: false) }
                .padding(.horizontal, 24)
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
