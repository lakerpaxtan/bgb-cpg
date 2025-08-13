import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: GameStore
    @State private var s: Settings = .default

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                HStack {
                    Button(action: {
                        store.goHome(resetAll: false)
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
                    
                    Text("Settings")
                        .font(.largeTitle.bold())
                    
                    Spacer()
                    
                    // Invisible spacer to center the title
                    Color.clear
                        .frame(width: 60)
                }

                // Players
                Group {
                    Stepper("Players: \(s.players)", value: $s.players, in: 4...12)
                }

                Divider().padding(.vertical, 8)

                // Wikipedia Cards
                Group {
                    Text("Wikipedia Cards").font(.title3.bold())

                    Stepper("Candidates per player: \(s.titlesPerPlayer)", value: $s.titlesPerPlayer, in: 6...15)
                    Stepper("Picks per player: \(s.picksPerPlayer)", value: $s.picksPerPlayer, in: 2...5)

                    Text("Subjects")
                        .font(.headline)
                    SubjectsChips(selected: $s.filters.subjects)

                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("No years/dates", isOn: $s.filters.excludeYearsDates)
                        Toggle("No disambiguation", isOn: $s.filters.excludeDisambiguation)
                        Toggle("No lists/categories", isOn: $s.filters.excludeListsCategories)
                        Toggle("Block NSFW", isOn: $s.filters.blockNSFW)
                    }
                }

                Divider().padding(.vertical, 8)

                // Gameplay
                Group {
                    Text("Gameplay").font(.title3.bold())
                    Stepper("Turn timer: \(s.timerSeconds)s", value: $s.timerSeconds, in: 30...120, step: 5)
                    Text("Skips handled by round rules.")
                        .font(.footnote).foregroundStyle(.secondary)
                }

                Text("Hint: Players add their names during the pass-around.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)

                BigButton(title: "Next — Player Intake") {
                    store.settings = s
                    store.startIntake()
                }
                .padding(.top, 10)
            }
            .padding(24)
        }
        .onAppear { s = store.settings }
    }
}

struct SubjectsChips: View {
    @Binding var selected: Set<Subject>

    var body: some View {
        FlowLayout {
            ForEach(Subject.allCases, id: \.self) { sub in
                let isOn = selected.contains(sub)
                Button {
                    if sub == .everything {
                        selected = [.everything]
                    } else {
                        if selected.contains(.everything) { selected.remove(.everything) }
                        if isOn { selected.remove(sub) } else { selected.insert(sub) }
                        if selected.isEmpty { selected = [.everything] }
                    }
                    Haptics.tap()
                } label: {
                    Text(sub.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(isOn ? Color.blue.opacity(0.18) : Color.gray.opacity(0.12))
                        .foregroundStyle(isOn ? Color.blue : Color.secondary)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Intake

struct IntakeHandoffView: View {
    @EnvironmentObject var store: GameStore

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Pass-Around")
                .font(.title.bold())

            Text("Hand the phone to the next \(store.intakeTeamCollecting == .A ? "Team A" : "Team B") player.")
                .font(.title3)
                .multilineTextAlignment(.center)

            BigButton(title: "I’m next") {
                store.intakeProceed()
            }
            Spacer()
        }
        .padding(24)
    }
}

struct IntakeNameView: View {
    @EnvironmentObject var store: GameStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Enter Your Name")
                .font(.title.bold())

            TextField("Name", text: $store.pendingName)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.done)

            let currentTeamCount = store.players.filter { $0.team == store.pendingTeam }.count
            let playersPerTeam = store.settings.players / 2
            let playerNumber = currentTeamCount + 1
            
            Text("You're joining \(store.pendingTeam == .A ? "Team A" : "Team B") as Player \(playerNumber)/\(playersPerTeam)!")
                .font(.headline)
                .foregroundStyle(store.pendingTeam == .A ? .blue : .green)
                .padding(.vertical, 8)

            Spacer()
            
            VStack(spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                
                Text("Game tip: Always start your turn by signaling the number of words in the title!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
            .padding(.vertical, 20)
            .background(Color.blue.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(maxWidth: .infinity)

            Spacer()

            BigButton(title: "Next") {
                store.intakeSaveNameAndShowPicks()
            }
        }
        .padding(24)
    }
}

struct IntakePicksView: View {
    @EnvironmentObject var store: GameStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Picks")
                    .font(.title.bold())
                Spacer()
                let count = store.selectedPicks.count
                Text("\(count)/\(store.settings.picksPerPlayer)")
                    .font(.headline)
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(Color.black.opacity(0.06))
                    .clipShape(Capsule())
            }

            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(store.candidateTitles) { card in
                        CandidateRow(card: card,
                                     selected: store.selectedPicks.contains(card.id),
                                     onToggle: { store.togglePick(card.id) },
                                     onReroll: { store.reroll(card: card.id) })
                    }
                }
            }

            BigButton(title: "Review & Submit") {
                guard store.selectedPicks.count == store.settings.picksPerPlayer else {
                    Haptics.warning(); return
                }
                store.submitPlayerAndPicks()
            }
            .disabled(store.selectedPicks.count != store.settings.picksPerPlayer)
        }
        .padding(24)
    }
}

private struct CandidateRow: View {
    let card: Card
    let selected: Bool
    var onToggle: () -> Void
    var onReroll: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(selected ? Color.green : Color.secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 6) {
                Text(card.title)
                    .font(.headline)
                Text(card.subject.rawValue)
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()

            Button(action: onReroll) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.title3.bold())
                    .foregroundStyle(.blue)
                    .padding(10)
                    .background(Color.blue.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Reroll")
        }
        .padding(12)
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: selected)
    }
}
