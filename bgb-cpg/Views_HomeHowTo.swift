import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: GameStore

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Wiki-Celebrity")
                .font(.system(size: 42, weight: .heavy, design: .rounded))
                .tracking(0.5)

            Text("3 rounds. Same cards. Rules get stricter.")
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
        .transition(.opacity.combined(with: .scale))
    }
}

struct HowToView: View {
    @EnvironmentObject var store: GameStore

    let slides: [String] = [
        "3 rounds. Same cards, rules get stricter.",
        "Round 1 = Describe (don’t say title parts).",
        "Round 2 = One Word.",
        "Round 3 = Charades (no words).",
        "Timer 60s. Phone tells you who holds it.",
        "Leading “The/A/An” not required when guessing.",
        "Note: These slides are placeholders. Final version should include clearer examples and edge-case clarifications for players."
    ]

    var body: some View {
        VStack(spacing: 16) {
            TabView {
                ForEach(slides.indices, id: \.self) { i in
                    Text(slides[i])
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(24)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            BigButton(title: "Back") { store.goHome(resetAll: false) }
        }
        .padding(.bottom, 24)
    }
}
