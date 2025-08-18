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

                // Gameplay
                Group {
                    Text("Gameplay").font(.title3.bold())
                    Stepper("Players: \(s.players)", value: $s.players, in: 4...20)
                    Stepper("Turn timer: \(s.timerSeconds)s", value: $s.timerSeconds, in: 30...120, step: 5)
                    Stepper("Candidates per player: \(s.titlesPerPlayer)", value: $s.titlesPerPlayer, in: 6...15)
                    Stepper("Picks per player: \(s.picksPerPlayer)", value: $s.picksPerPlayer, in: 2...5)
                    Text("Skips handled by round rules.")
                        .font(.footnote).foregroundStyle(.secondary)
                }

                Divider().padding(.vertical, 8)

                // Content Source
                Group {
                    Text("Content Source").font(.title3.bold())
                    
                    ContentSourcePicker(selected: $s.contentSource)
                    
                    // Show appropriate filters based on content source
                    if s.contentSource == .offline {
                        OfflineFilters(filters: $s.filters)
                    } else {
                        WikipediaFiltersView(filters: $s.wikipediaFilters, store: store)
                    }
                }

                Text("Hint: Players add their names during the pass-around.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)

                LoadingButton(
                    isLoading: store.loadingCandidates,
                    normalTitle: "Next — Player Intake",
                    loadingTitle: "Loading..."
                ) {
                    store.candidateLoadingError = nil // Clear any previous errors
                    store.settings = s
                    store.startIntake()
                }
                .alert("Loading Error", isPresented: .constant(store.candidateLoadingError != nil)) {
                    Button("OK") {
                        store.candidateLoadingError = nil
                    }
                } message: {
                    Text(store.candidateLoadingError ?? "")
                }
                .padding(.top, 10)
            }
            .padding(24)
        }
        .onAppear { s = store.settings }
    }
    
}

struct LoadingButton: View {
    let isLoading: Bool
    let normalTitle: String
    let loadingTitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundStyle(.white)
                    Text(loadingTitle)
                        .font(.title3.weight(.semibold))
                } else {
                    Text(normalTitle)
                        .font(.title3.weight(.semibold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isLoading ? Color.gray : Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(isLoading)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
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
            
            // Show loading error if any
            if let error = store.candidateLoadingError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
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
                    Text(card.subject)
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


// MARK: - Content Source Components

struct ContentSourcePicker: View {
    @Binding var selected: ContentSource
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(ContentSource.allCases, id: \.self) { source in
                let isSelected = selected == source
                Button {
                    selected = source
                    Haptics.tap()
                } label: {
                    Text(source.displayName)
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .background(isSelected ? Color.blue.opacity(0.18) : Color.gray.opacity(0.12))
                        .foregroundStyle(isSelected ? Color.blue : Color.secondary)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }
}


struct OfflineFilters: View {
    @Binding var filters: Filters
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Subjects")
                .font(.headline)
            SubjectsChips(selected: $filters.subjects)
        }
    }
}

struct WikipediaFiltersView: View {
    @Binding var filters: WikipediaFilters
    let store: GameStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if store.wikipediaService.status == .available {
                // Categories
                Text("Categories")
                    .font(.headline)
                WikipediaCategoryChips(selected: $filters.categories, availableCategories: store.wikipediaService.availableCategories)
                
                // Word Limit
                Text("Word Limit: \(filters.wordLimit.lowerBound)-\(filters.wordLimit.upperBound) words")
                    .font(.headline)
                RangeSlider(range: $filters.wordLimit, bounds: 1...10, step: 1)
                
                // Popularity
                VStack(alignment: .leading, spacing: 4) {
                    Text("Popularity (not in use): \(filters.popularityPercentile.lowerBound)%-\(filters.popularityPercentile.upperBound)%")
                        .font(.headline)
                    Text("Filters articles by how well-known they are. 0%=obscure, 100%=widely known")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                RangeSlider(range: $filters.popularityPercentile, bounds: 0...100, step: 5)
                
                // Creation Years
                Text("Created (not in use): \(filters.createdYears.lowerBound)-\(filters.createdYears.upperBound)")
                    .font(.headline)
                RangeSlider(range: $filters.createdYears, bounds: 2001...2025, step: 1)
                
                // Update Years
                Text("Updated (not in use): \(filters.updatedYears.lowerBound)-\(filters.updatedYears.upperBound)")
                    .font(.headline)
                RangeSlider(range: $filters.updatedYears, bounds: 2020...2025, step: 1)
            } else {
                Text("Wikipedia filters will appear when Wikipedia is available")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .italic()
            }
        }
    }
}

struct WikipediaCategoryChips: View {
    @Binding var selected: Set<WikipediaCategory>
    let availableCategories: [WikipediaCategory]
    
    var body: some View {
        FlowLayout {
            ForEach(availableCategories, id: \.self) { category in
                let isSelected = selected.contains(category)
                Button {
                    if isSelected {
                        selected.remove(category)
                    } else {
                        selected.insert(category)
                    }
                    if selected.isEmpty && !availableCategories.isEmpty {
                        selected = [availableCategories.first!] // Default to at least one
                    }
                    Haptics.tap()
                } label: {
                    Text(category.displayName)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(isSelected ? Color.blue.opacity(0.18) : Color.gray.opacity(0.12))
                        .foregroundStyle(isSelected ? Color.blue : Color.secondary)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct RangeSlider: View {
    @Binding var range: ClosedRange<Int>
    let bounds: ClosedRange<Int>
    let step: Int
    
    @State private var lowerValue: Double
    @State private var upperValue: Double
    
    init(range: Binding<ClosedRange<Int>>, bounds: ClosedRange<Int>, step: Int) {
        self._range = range
        self.bounds = bounds
        self.step = step
        self._lowerValue = State(initialValue: Double(range.wrappedValue.lowerBound))
        self._upperValue = State(initialValue: Double(range.wrappedValue.upperBound))
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("\(bounds.lowerBound)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(bounds.upperBound)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("Min: \(Int(lowerValue))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                
                Slider(value: $lowerValue, 
                       in: Double(bounds.lowerBound)...Double(bounds.upperBound),
                       step: Double(step)) { _ in
                    // Ensure lower doesn't exceed upper
                    if lowerValue > upperValue {
                        upperValue = lowerValue
                    }
                    updateRange()
                }
                .accentColor(.blue)
                
                HStack {
                    Text("Max: \(Int(upperValue))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                
                Slider(value: $upperValue,
                       in: Double(bounds.lowerBound)...Double(bounds.upperBound),
                       step: Double(step)) { _ in
                    // Ensure upper doesn't go below lower
                    if upperValue < lowerValue {
                        lowerValue = upperValue
                    }
                    updateRange()
                }
                .accentColor(.blue)
            }
        }
    }
    
    private func updateRange() {
        let newRange = Int(lowerValue)...Int(upperValue)
        if range != newRange {
            range = newRange
        }
    }
}
