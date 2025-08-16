import SwiftUI

struct RoundEndView: View {
    @EnvironmentObject var store: GameStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Round Complete!")
                .font(.largeTitle.bold())

            // Use the shared score display component
            ScoreDisplayView(
                title: "Running Total",
                cumulativeA: store.cumulativeA,
                cumulativeB: store.cumulativeB,
                roundScores: store.roundScores,
                currentRound: store.currentRound.rawValue
            )

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
                Text("Total")
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

                // Use the shared score display component
                ScoreDisplayView(
                    title: "Final Score",
                    cumulativeA: store.cumulativeA,
                    cumulativeB: store.cumulativeB,
                    roundScores: store.roundScores,
                    currentRound: 3
                )

                Spacer()

                BigButton(title: "View Player Stats") {
                    store.showGameStats()
                }

                OutlineButton(title: "Rematch (same settings)") {
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

struct GameStatsView: View {
    @EnvironmentObject var store: GameStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with back button and title
            HStack {
                Button(action: {
                    store.hideGameStats()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 17))
                    }
                    .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
            .padding(.bottom, 8)
            
            Text("Player Stats")
                .font(.largeTitle.bold())
                .padding(.bottom, 16)
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(store.players.sorted { $0.name < $1.name }) { player in
                        PlayerStatsCard(player: player, stats: store.playerStats[player.id])
                    }
                }
                .padding(.bottom, 16)
            }
            
            BigButton(title: "Done") {
                store.hideGameStats()
            }
        }
        .padding(24)
    }
}

struct PlayerStatsCard: View {
    let player: Player
    let stats: PlayerStats?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(player.team.color)
                    .frame(width: 12, height: 12)
                
                Text(player.name)
                    .font(.headline.bold())
                
                Spacer()
                
                Text(player.team.name)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(player.team.color.opacity(0.12))
                    .clipShape(Capsule())
                    .foregroundStyle(player.team.color)
            }
            
            if let stats = stats {
                VStack(alignment: .leading, spacing: 8) {
                    StatRow(label: "Correct Answers", value: "\(stats.totalCorrectAnswers)")
                    StatRow(label: "Turns as Clue Giver", value: "\(stats.turnsAsClueGiver)")
                    
                    if stats.totalCorrectAnswers > 0 {
                        StatRow(label: "Average Answer Time", value: String(format: "%.1fs", stats.averageAnswerTime))
                        
                        if let fastest = stats.fastestAnswer {
                            StatRow(label: "Fastest Answer", value: String(format: "%.1fs", fastest))
                        }
                        
                        if let slowest = stats.slowestAnswer {
                            StatRow(label: "Slowest Answer", value: String(format: "%.1fs", slowest))
                        }
                    }
                }
            } else {
                Text("No stats available")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption.bold())
        }
    }
}

// MARK: - Shared Score Display Component

struct ScoreDisplayView: View {
    let title: String
    let cumulativeA: Int
    let cumulativeB: Int
    let roundScores: [Int: RoundScore]
    let currentRound: Int
    
    var body: some View {
        VStack(spacing: 16) {
            // Prominent Total Score
            VStack(spacing: 12) {
                Text(title)
                    .font(.title2.bold())
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 16) {
                    ScoreBadge(team: .A, score: cumulativeA)
                    ScoreBadge(team: .B, score: cumulativeB)
                }
            }
            .padding()
            .background(Color.white.opacity(0.98))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.08), radius: 10, y: 6)
            
            // Divider
            Divider()
                .padding(.vertical, 8)
            
            // Round Breakdown
            VStack(spacing: 8) {
                Text("Round Breakdown")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                ForEach(1...currentRound, id: \.self) { roundNum in
                    let roundScore = roundScores[roundNum] ?? RoundScore()
                    HStack {
                        Text("Round \(roundNum)")
                            .font(.subheadline.weight(.medium))
                        Spacer()
                        HStack(spacing: 8) {
                            Text("A: \(roundScore.teamA)")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Team.A.color)
                            Text("B: \(roundScore.teamB)")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Team.B.color)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.03))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}
