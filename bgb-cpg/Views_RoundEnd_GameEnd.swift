import SwiftUI

struct RoundEndView: View {
    @EnvironmentObject var store: GameStore

    var body: some View {
        let r = store.roundScores[store.currentRound.rawValue] ?? RoundScore()

        VStack(alignment: .leading, spacing: 16) {
            Text("Round Complete!")
                .font(.largeTitle.bold())

            Scoreboard(round: store.currentRound.rawValue, r: r, cumA: store.cumulativeA, cumB: store.cumulativeB)

            if store.settings.stats.showBetweenRounds {
                Text("Highlights")
                    .font(.title3.bold())
                    .padding(.top, 8)

                let hi = store.roundHighlights()
                if hi.isEmpty {
                    Text("More stats coming soon.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(hi) { h in
                        Text("• \(h.text)")
                            .font(.callout)
                    }
                }
            }

            Spacer()

            BigButton(title: store.currentRound == .three ? "See Final Scores" : "Round \(store.currentRound.rawValue + 1) Rules") {
                store.proceedToNextRoundOrEnd()
            }
        }
        .padding(24)
    }
}

struct Scoreboard: View {
    let round: Int
    let r: RoundScore
    let cumA: Int
    let cumB: Int

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Round \(round)")
                    .font(.title3.bold())
                Spacer()
                HStack(spacing: 12) {
                    ScoreBadge(team: .A, score: r.teamA)
                    ScoreBadge(team: .B, score: r.teamB)
                }
            }
            Divider()
            HStack {
                Text("Cumulative")
                    .font(.title3.bold())
                Spacer()
                HStack(spacing: 12) {
                    ScoreBadge(team: .A, score: cumA)
                    ScoreBadge(team: .B, score: cumB)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }
}

struct ScoreBadge: View {
    let team: Team
    let score: Int

    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(team.color).frame(width: 10, height: 10)
            Text("\(team.name): \(score)")
                .font(.headline)
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(team.color.opacity(0.12))
        .clipShape(Capsule())
    }
}

struct GameEndView: View {
    @EnvironmentObject var store: GameStore
    @State private var showConfetti = true

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                Text("Game Over")
                    .font(.largeTitle.bold())

                if store.isTie {
                    Text("It’s a tie!")
                        .font(.title)
                } else if store.cumulativeA > store.cumulativeB {
                    Text("Team A wins!")
                        .font(.title)
                        .foregroundStyle(Team.A.color)
                } else {
                    Text("Team B wins!")
                        .font(.title)
                        .foregroundStyle(Team.B.color)
                }

                Scoreboard(round: 3,
                           r: store.roundScores[3] ?? RoundScore(),
                           cumA: store.cumulativeA,
                           cumB: store.cumulativeB)

                Spacer()

                BigButton(title: "Rematch (same settings)") {
                    store.rematchSameSettings()
                }

                OutlineButton(title: "New Game") {
                    store.newGame()
                }
            }
            .padding(24)

            if showConfetti {
                ConfettiView()
                    .onAppear {
                        // small celebration window
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                            showConfetti = false
                        }
                    }
            }
        }
    }
}
