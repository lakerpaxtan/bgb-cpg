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

            BigButton(title: "I'm \(store.clueGiver?.name ?? "Next") — Get Ready",
                      action: { store.stage = .turnReady },
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
                // Header (blurred) - matches current TurnView layout
                VStack(spacing: 8) {
                    // Top controls row with fixed sizing (blurred)
                    HStack {
                        Text("\(store.settings.timerSeconds)s")
                            .font(.system(size: 40, weight: .heavy, design: .rounded))
                            .foregroundStyle(store.currentTeam.color.opacity(0.3))
                            .monospacedDigit()
                            .frame(minWidth: 80, alignment: .leading)

                        Spacer()
                        
                        // Control buttons (disabled/blurred)
                        HStack(spacing: 8) {
                            // Pause button pill
                            HStack(spacing: 4) {
                                Image(systemName: "pause.fill")
                                    .font(.caption.weight(.semibold))
                                Text("Pause")
                                    .font(.caption.weight(.semibold))
                            }
                            .foregroundStyle(.orange.opacity(0.4))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color.orange.opacity(0.06))
                            .clipShape(Capsule())
                            .frame(width: 70, height: 28)
                            
                            // End turn button pill
                            HStack(spacing: 4) {
                                Image(systemName: "stop.fill")
                                    .font(.caption.weight(.semibold))
                                Text("End")
                                    .font(.caption.weight(.semibold))
                            }
                            .foregroundStyle(.red.opacity(0.4))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color.red.opacity(0.06))
                            .clipShape(Capsule())
                            .frame(width: 60, height: 28)
                        }
                    }
                    
                    // Game status info row (blurred)
                    HStack {
                        Text("Ready to start")
                            .font(.footnote.weight(.semibold))
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Color.black.opacity(0.03))
                            .clipShape(Capsule())
                        
                        Spacer()
                        
                        Text("Cards: \(store.deck.count) | Ready to play")
                            .font(.caption2)
                            .foregroundStyle(.secondary.opacity(0.6))
                    }
                }

                Divider().opacity(0.3)

                // Card area (blurred)
                if store.deck.first != nil {
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

                // Placeholder buttons (disabled/blurred) - matches new layout
                VStack(spacing: 12) {
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
                    
                    // Placeholder diagnostic info
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 8) {
                                Text("Skipped: 0")
                                    .font(.caption2.weight(.medium))
                                    .foregroundStyle(.secondary.opacity(0.4))
                                
                                Text("•")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary.opacity(0.4))
                                
                                Text("Correct: 0")
                                    .font(.caption2.weight(.medium))
                                    .foregroundStyle(.secondary.opacity(0.4))
                                
                                Text("•")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary.opacity(0.4))
                                
                                Text("Out of: \(store.deck.count)")
                                    .font(.caption2.weight(.medium))
                                    .foregroundStyle(.secondary.opacity(0.4))
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding(24)
            .blur(radius: 3)
            
            // Center start button
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("Get ready!")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    // Cards remaining info
                    Text("\(store.deck.count) cards remaining")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    // Bonus time continuation info
                    if let bonusPlayer = store.bonusTimePlayer, 
                       bonusPlayer.id == store.clueGiver?.id,
                       store.savedBonusTime > 0 {
                        Text("🎉 Bonus time: \(store.savedBonusTime)s")
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(.green)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
                
                BigButton(title: "Start Timer", action: {
                    store.beginTurn()
                }, fill: store.currentTeam.color)
                
                VStack(spacing: 8) {
                    Image(systemName: "eye.slash")
                        .font(.title3)
                        .foregroundStyle(.orange)
                    
                    Text("Only the clue-giver should see the screen")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
                .padding(.vertical, 16)
                .background(Color.orange.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            }
            .padding(32)
            .background(Color.white.opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.1), radius: 12, y: 8)
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Turn Screen

struct TurnView: View {
    @EnvironmentObject var store: GameStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header with top controls row
            VStack(spacing: 8) {
                // Top controls row with fixed sizing
                HStack {
                    Text("\(store.timeRemaining)s")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(store.currentTeam.color)
                        .monospacedDigit()
                        .frame(minWidth: 80, alignment: .leading)

                    Spacer()
                    
                    // Control buttons as horizontal pills
                    HStack(spacing: 8) {
                        // Pause button pill
                        Button(action: {
                            store.pauseTurn()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "pause.fill")
                                    .font(.caption.weight(.semibold))
                                Text("Pause")
                                    .font(.caption.weight(.semibold))
                            }
                            .foregroundStyle(.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color.orange.opacity(0.15))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .frame(width: 70, height: 28)
                        
                        // End turn button pill
                        Button(action: {
                            store.showEndTurnConfirmation()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "stop.fill")
                                    .font(.caption.weight(.semibold))
                                Text("End")
                                    .font(.caption.weight(.semibold))
                            }
                            .foregroundStyle(.red)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color.red.opacity(0.15))
                            .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .frame(width: 60, height: 28)
                        .disabled(store.deck.isEmpty)
                    }
                }
                
                // Primary info: Cards remaining until turn ends
                HStack {
                    Text("Cards Remaining")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    let cardsRemaining = store.initialDeckSize - store.skipCount - store.thisTurnCorrect.count
                    Text("\(max(0, cardsRemaining))")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Capsule())
                }
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

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    if store.currentRound != .one {
                        OutlineButton(title: "Skip") {
                            store.skipCard()
                        }
                        .disabled(store.deck.isEmpty)
                    }
                    BigButton(title: "Correct",
                              action: { store.markCorrect() },
                              fill: .green)
                    .disabled(store.deck.isEmpty)
                }
                
                // Diagnostic info
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 8) {
                            // Skip status
                            Group {
                                if store.currentRound == .one {
                                    Text("Skip: Off")
                                        .foregroundStyle(.gray)
                                } else {
                                    Text("Skipped: \(store.skipCount)")
                                        .foregroundStyle(.orange)
                                }
                            }
                            .font(.caption2.weight(.medium))
                            
                            Text("•")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            
                            Text("Correct: \(store.thisTurnCorrect.count)")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.green)
                            
                            Text("•")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            
                            Text("Out of: \(store.initialDeckSize)")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(24)
        .onDisappear { /* defensive */ }
        .alert("End Turn?", isPresented: $store.showingEndTurnConfirmation) {
            Button("Cancel", role: .cancel) {
                store.cancelEndTurn()
            }
            Button("End Turn", role: .destructive) {
                store.confirmEndTurn()
            }
        } message: {
            Text("You can't undo this action. Your turn will end immediately.")
        }
    }
}

// MARK: - Turn Complete (all turn end reasons except skip cycle)

struct TurnCompleteView: View {
    @EnvironmentObject var store: GameStore
    
    private var endReasonText: String {
        switch store.lastTurnEndReason {
        case .timerExpired:
            return "Time's up!"
        case .manual:
            return "Turn ended early"
        case .completedAllCards:
            return "Amazing! All cards completed!"
        case .skipCycleComplete:
            return "Cycled through all cards"
        }
    }
    
    private var endReasonSubtext: String {
        switch store.lastTurnEndReason {
        case .timerExpired:
            return "Timer ran out - current card moved to bottom"
        case .manual:
            return "Turn ended manually by player"
        case .completedAllCards:
            return "Bonus time earned for next turn!"
        case .skipCycleComplete:
            return "You've seen all available cards"
        }
    }

    var body: some View {
        ZStack {
            // Blurred background showing the turn content
            VStack(alignment: .leading, spacing: 14) {
                // Header (blurred)
                VStack(spacing: 8) {
                    HStack {
                        Text("\(store.timeRemaining)s")
                            .font(.system(size: 40, weight: .heavy, design: .rounded))
                            .foregroundStyle(store.currentTeam.color.opacity(0.3))
                            .monospacedDigit()
                            .frame(minWidth: 80, alignment: .leading)

                        Spacer()
                        
                        Text("Turn Complete")
                            .font(.footnote.weight(.semibold))
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Color.black.opacity(0.03))
                            .clipShape(Capsule())
                    }
                    
                    HStack {
                        Text("Skip: \(store.currentRound == .one ? "Off" : "Limited")")
                            .font(.footnote.weight(.semibold))
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Color.black.opacity(0.03))
                            .clipShape(Capsule())
                        
                        Spacer()
                        
                        Text("Cards: \(store.deck.count) | Correct: \(store.thisTurnCorrect.count)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Divider().opacity(0.3)

                // Card area (blurred)
                VStack(alignment: .leading, spacing: 12) {
                    Text("████████")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background(Color.white.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: .black.opacity(0.03), radius: 8, y: 6)

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
            
            // Center confirmation
            VStack(spacing: 16) {
                Text(endReasonText)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Text(endReasonSubtext)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                BigButton(title: "Continue to Recap", action: {
                    store.proceedFromTurnComplete()
                }, fill: store.currentTeam.color)
            }
            .padding(32)
            .background(Color.white.opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.1), radius: 12, y: 8)
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Turn Skip Complete

struct TurnSkipCompleteView: View {
    @EnvironmentObject var store: GameStore

    var body: some View {
        ZStack {
            // Blurred background showing the turn content
            VStack(alignment: .leading, spacing: 14) {
                // Header (blurred)
                HStack {
                    Text("\(store.timeRemaining)s")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(store.currentTeam.color.opacity(0.3))
                        .monospacedDigit()

                    Spacer()

                    Text("Turn Complete")
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(Color.black.opacity(0.03))
                        .clipShape(Capsule())
                }

                Divider().opacity(0.3)

                // Card area (blurred)
                VStack(alignment: .leading, spacing: 12) {
                    Text("████████")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background(Color.white.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: .black.opacity(0.03), radius: 8, y: 6)

                Spacer()

                // Placeholder buttons (disabled/blurred)
                VStack(spacing: 12) {
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
                    
                    OutlineButton(title: "End Turn") {}
                        .disabled(true)
                        .opacity(0.4)
                }
            }
            .padding(24)
            .blur(radius: 3)
            
            // Center confirmation
            VStack(spacing: 16) {
                Text("Turn Complete")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Text("You've cycled through all cards")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                BigButton(title: "Continue to Recap", action: {
                    store.proceedFromSkipComplete()
                }, fill: store.currentTeam.color)
            }
            .padding(32)
            .background(Color.white.opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.1), radius: 12, y: 8)
            .padding(.horizontal, 24)
        }
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

            BigButton(title: "Done Reviewing") {
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

// MARK: - Turn Paused

struct TurnPausedView: View {
    @EnvironmentObject var store: GameStore

    var body: some View {
        ZStack {
            // Blurred background showing the paused turn content
            VStack(alignment: .leading, spacing: 14) {
                // Header (blurred)
                HStack {
                    Text("\(store.timeRemaining)s")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(store.currentTeam.color.opacity(0.3))
                        .monospacedDigit()

                    Spacer()

                    Text("Paused")
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(Color.black.opacity(0.03))
                        .clipShape(Capsule())
                }

                Divider().opacity(0.3)

                // Card area (blurred)
                if store.deck.first != nil {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Game is paused")
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
            
            // Center pause menu
            VStack(spacing: 16) {
                Text("Game Paused")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
                
                VStack(spacing: 12) {
                    BigButton(title: "Unpause", action: {
                        store.unpauseTurn()
                    }, fill: store.currentTeam.color)
                    
                    OutlineButton(title: "View Rules") {
                        store.showRulesFromPause()
                    }
                    
                    OutlineButton(title: "Timer Settings") {
                        store.showPauseSettings()
                    }
                    
                    OutlineButton(title: "End Game & Return to Menu") {
                        store.showEndGameConfirmation()
                    }
                }
            }
            .padding(32)
            .background(Color.white.opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.1), radius: 12, y: 8)
        }
        .alert("End Game?", isPresented: $store.showingEndGameConfirmation) {
            Button("Cancel", role: .cancel) {
                store.cancelEndGame()
            }
            Button("End Game", role: .destructive) {
                store.confirmEndGame()
            }
        } message: {
            Text("This will end the current game and return to the main menu. All progress will be lost.")
        }
        .sheet(isPresented: $store.showingPauseSettings) {
            NavigationView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Timer Settings")
                        .font(.largeTitle.bold())
                    
                    Text("Changes will take effect starting next round")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Stepper("Turn timer: \(store.pendingTimerSeconds)s", 
                           value: $store.pendingTimerSeconds, 
                           in: 30...120, step: 5)
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        OutlineButton(title: "Cancel") {
                            store.cancelPauseSettings()
                        }
                        
                        BigButton(title: "Save Changes") {
                            store.savePauseSettings()
                        }
                    }
                }
                .padding(24)
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $store.showingRulesFromPause) {
            NavigationView {
                HowToView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                store.hideRulesFromPause()
                            }
                        }
                    }
            }
            .presentationDetents([.large])
        }
    }
}
