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
                    Stepper("Players: \(s.players)", value: $s.players, in: 4...20)
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

            BigButton(title: "I'm next") {
                store.intakeProceed()
            }
            
            RestartButton()
            
            Spacer()
        }
        .padding(24)
    }
}

struct IntakeNameView: View {
    @EnvironmentObject var store: GameStore
    @State private var hasStartedTyping = false
    @FocusState private var isTextFieldFocused: Bool
    
    private var nameValidationError: String? {
        // Only show validation errors after user has started typing
        guard hasStartedTyping else { return nil }
        
        let trimmed = store.pendingName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return "Name cannot be blank"
        }
        
        let existingNames = Set(store.players.map { $0.name.lowercased() })
        if existingNames.contains(trimmed.lowercased()) {
            return "Name must be unique"
        }
        
        return nil
    }
    
    private var isNameValid: Bool {
        let trimmed = store.pendingName.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && !Set(store.players.map { $0.name.lowercased() }).contains(trimmed.lowercased())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Enter Your Name")
                .font(.title.bold())

            VStack(alignment: .leading, spacing: 8) {
                // Larger, more prominent text field with invisible tap area
                ZStack {
                    // Invisible tap area around the text field
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 80)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isTextFieldFocused = true
                        }
                    
                    TextField("Enter your name", text: $store.pendingName)
                        .font(.title3)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color.white.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                        .submitLabel(.done)
                        .focused($isTextFieldFocused)
                        .onChange(of: store.pendingName) { _, _ in
                            if !hasStartedTyping {
                                hasStartedTyping = true
                            }
                        }
                }
                
                if let error = nameValidationError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 4)
                }
            }

            let currentTeamCount = store.players.filter { $0.team == store.pendingTeam }.count
            let playersPerTeam = store.settings.players / 2
            let playerNumber = currentTeamCount + 1
            
            Text("You're joining \(store.pendingTeam == .A ? "Team A" : "Team B") as Player \(playerNumber) out of \(playersPerTeam)!")
                .font(.headline)
                .foregroundStyle(store.pendingTeam == .A ? .blue : .green)
                .padding(.vertical, 8)

            Spacer()
            
            VStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.title3)
                    .foregroundStyle(.orange)
                
                Text("Game tip: Always start your turn by signaling the number of words in the title!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
            .padding(.vertical, 16)
            .background(Color.orange.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(maxWidth: .infinity)

            Spacer()

            VStack(spacing: 12) {
                BigButton(title: "Next") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    store.intakeSaveNameAndShowPicks()
                }
                .disabled(!isNameValid)
                
                RestartButton()
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

            VStack(spacing: 12) {
                let isCorrectCount = store.selectedPicks.count == store.settings.picksPerPlayer
                let buttonTitle = isCorrectCount ? "Submit" : "Please select exactly \(store.settings.picksPerPlayer) titles"
                
                BigButton(title: buttonTitle) {
                    store.submitPlayerAndPicks()
                }
                .disabled(!isCorrectCount)
                
                VStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.title3)
                        .foregroundStyle(.orange)
                    
                    Text("Remember your selected titles! Your team gains an advantage when only you know which cards are coming up.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
                .padding(.vertical, 16)
                .background(Color.orange.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .frame(maxWidth: .infinity)
                
                RestartButton()
                    .padding(.top, 4)
            }
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
        Button(action: onToggle) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(selected ? Color.green : Color.secondary)

                VStack(alignment: .leading, spacing: 6) {
                    Text(card.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
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
        }
        .buttonStyle(.plain)
        .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: selected)
    }
}
