import SwiftUI

// MARK: - Round Intro

struct RoundIntroView: View {
    @EnvironmentObject var store: GameStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(store.currentRound.title).font(.largeTitle.bold())
            Text(store.currentRound.rules).font(.title3)
            HStack {
                Text("Note:").font(.headline)
                Text("Leading “The/A/An” optional when guessing.")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Text(store.currentRound.skipPolicy)
                .font(.callout)
                .foregroundStyle(.secondary)
                .padding(.top, 4)

            Spacer()

            BigButton(title: "Start Round \(store.currentRound.rawValue)") {
                store.startRound()
            }
        }
        .padding(24)
    }
}

// MARK: - Turn Handoff

struct TurnHandoffView: View {
    @EnvironmentObject var store: GameStore

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("Turn Handoff").font(.title.bold())

            if let cg = store.clueGiver {
                Text("Hand the phone to \(cg.name) on \(cg.team.name).")
                    .font(.title3)
                    .multilineTextAlignment(.center)
            }

            Text(store.currentRound.skipPolicy)
                .font(.callout)
                .foregroundStyle(.secondary)
                .padding(.top, 4)

            BigButton(title: "I’m \(store.clueGiver?.name ?? "Next") — Show Controls",
                      action: { store.showPrimer() },
                      fill: store.currentTeam.color)

            Spacer()
        }
        .padding(24)
    }
}

// MARK: - Primer

struct PrimerView: View {
    @EnvironmentObject var store: GameStore

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "hand.raised")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text("Only the clue-giver should see the screen.")
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Text("You'll see the title. Remember: don't say any words from the title!")
                .font(.callout)
                .foregroundStyle(.secondary)
            Spacer()
            Text("Starting…").font(.footnote).foregroundStyle(.secondary)
        }
        .padding(24)
        .transition(.opacity)
    }
}

// MARK: - Turn Ready Screen

struct TurnReadyView: View {
    @EnvironmentObject var store: GameStore

    var body: some View {
        ZStack {
            // Blurred background showing the upcoming turn content
            VStack(alignment: .leading, spacing: 14) {
                // Header (blurred)
                HStack {
                    Text("\(store.settings.timerSeconds)s")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(store.currentTeam.color.opacity(0.3))
                        .monospacedDigit()

                    Spacer()

                    Text("Ready to start")
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(Color.black.opacity(0.03))
                        .clipShape(Capsule())
                }

                Divider().opacity(0.3)

                // Card area (blurred)
                if let card = store.deck.first {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ready to see your card?")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color.white.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: .black.opacity(0.03), radius: 8, y: 6)
                }

                Spacer()

                // Placeholder buttons (disabled/blurred)
                HStack(spacing: 12) {
                    if store.currentRound != .one {
                        OutlineButton(title: "Skip") {}
                            .disabled(true)
                            .opacity(0.4)
                    }
                    BigButton(title: "Correct", action: {}, fill: .green)
                        .disabled(true)
                        .opacity(0.4)
                }
            }
            .padding(24)
            .blur(radius: 3)
            
            // Center start button
            VStack(spacing: 16) {
                Text("Get ready!")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
                
                BigButton(title: "Start Timer", action: {
                    store.beginTurn()
                }, fill: store.currentTeam.color)
            }
            .padding(32)
            .background(Color.white.opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.1), radius: 12, y: 8)
        }
    }
}

// MARK: - Turn Screen

struct TurnView: View {
    @EnvironmentObject var store: GameStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                Text("\(store.timeRemaining)s")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(store.currentTeam.color)
                    .monospacedDigit()

                Spacer()

                // Skip status badge
                Group {
                    if store.currentRound == .one {
                        Text("Skip: Off")
                    } else if store.skipLocked {
                        Text("Back at start — Skip off")
                    } else {
                        Text("Skip until start card")
                    }
                }
                .font(.footnote.weight(.semibold))
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(Color.black.opacity(0.06))
                .clipShape(Capsule())
            }

            Divider()

            // Card area
            if let card = store.deck.first {
                VStack(alignment: .leading, spacing: 12) {
                    Text(card.title)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background(Color.white.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: .black.opacity(0.06), radius: 8, y: 6)
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)))
                .animation(.spring(response: 0.45, dampingFraction: 0.85), value: store.deck.first?.id)
            } else {
                Text("No cards left.")
                    .font(.title3.weight(.semibold))
                    .padding()
            }

            Spacer()

            HStack(spacing: 12) {
                if store.currentRound != .one {
                    OutlineButton(title: "Skip") {
                        store.skipCard()
                    }
                    .disabled(store.skipLocked || store.deck.isEmpty)
                }
                BigButton(title: "Correct",
                          action: { store.markCorrect() },
                          fill: .green)
                .disabled(store.deck.isEmpty)
            }
        }
        .padding(24)
        .onDisappear { /* defensive */ }
    }
}

// MARK: - Recap

struct RecapView: View {
    @EnvironmentObject var store: GameStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Turn Recap")
                .font(.largeTitle.bold())

            Text("Highlight the correct answers and only read those out loud.")
                .font(.callout)
                .foregroundStyle(.secondary)

            if store.thisTurnCorrect.isEmpty {
                Text("No correct answers this turn.")
                    .font(.headline)
                    .padding(.top, 8)
            } else {
                List {
                    ForEach(store.thisTurnCorrect) { ev in
                        Toggle(isOn: binding(for: ev.id)) {
                            Text(ev.card.title).font(.headline)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                }
                .listStyle(.plain)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .frame(maxHeight: 320)
            }


            Spacer()

            BigButton(title: "Hand the phone to next — I’m \(store.currentTeam == .A ? (store.teamBOrder.first?.name ?? "Next") : (store.teamAOrder.first?.name ?? "Next"))") {
                store.recapDoneNextHandoff()
            }
        }
        .padding(24)
    }

    private func binding(for id: UUID) -> Binding<Bool> {
        Binding(get: {
            store.thisTurnCorrect.first(where: { $0.id == id })?.highlighted ?? true
        }, set: { new in
            if let idx = store.thisTurnCorrect.firstIndex(where: { $0.id == id }) {
                store.thisTurnCorrect[idx].highlighted = new
            }
        })
    }
}
