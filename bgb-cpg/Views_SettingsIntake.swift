import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: GameStore
    @State private var s: Settings = .default

    var body: some View {
        VStack(spacing: 0) {
            // Header - Top aligned
            Text("Settings")
                .font(.title.bold())
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 24)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
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

                    Text("Hint: Players add their names during the pass-around.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                }
                .padding(24)
            }

            // Action buttons - Fixed at bottom
            VStack(spacing: 12) {
                BigButton(title: "Next — Choose Pack") {
                    store.settings = s
                    print("⚙️ Settings saved, proceeding to pack selection")
                    store.stage = .packSelection
                    print("✅ Stage changed to: .packSelection")
                }

                // Back button
                Button(action: {
                    store.goHome(resetAll: false)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back to Home")
                            .font(.system(size: 17))
                    }
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
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
                    print("➡️ Moving from name entry to title selection")
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
                    print("📝 Submitting player with \(store.selectedPicks.count) selected titles")
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

// MARK: - Pack Selection Views

struct PackSelectionView: View {
    @EnvironmentObject var store: GameStore
    @State private var selectedPack: Pack = .offlineStandard
    
    var body: some View {
        VStack(spacing: 0) {
            // Header - Top aligned
            VStack(spacing: 24) {
                Text("Choose Pack")
                    .font(.title.bold())
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("Select a curated pack of titles for your game")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 16)

            // Pack cards scrollview - No background color
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(Pack.allCases, id: \.self) { pack in
                        PackCard(
                            pack: pack,
                            isSelected: selectedPack == pack
                        ) {
                            selectedPack = pack
                            Haptics.tap()
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
            }
            .frame(height: 250)

            // Selected pack info - Fixed position
            VStack(spacing: 8) {
                Text(selectedPack.displayName)
                    .font(.title2.bold())
                    .foregroundStyle(.primary)

                Text(selectedPack.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(Color.black.opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 24)
            .frame(height: 100)

            Spacer()

            // Action buttons - Fixed at bottom
            VStack(spacing: 12) {
                if selectedPack == .offlineCustom {
                    BigButton(title: "Customize Your Pack") {
                        var settings = store.settings
                        settings.selectedPack = selectedPack
                        store.settings = settings
                        print("📦 Selected pack: \(selectedPack.displayName)")
                        store.stage = .customPackBuilder
                        print("✅ Stage changed to: .customPackBuilder")
                    }
                } else {
                    BigButton(title: "Continue to Player Setup") {
                        var settings = store.settings
                        settings.selectedPack = selectedPack
                        store.settings = settings
                        print("📦 Selected pack: \(selectedPack.displayName)")
                        store.startIntakeWithPack(selectedPack)
                    }
                }

                // Back to settings button
                Button(action: {
                    store.stage = .settings
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back to Settings")
                            .font(.system(size: 17))
                    }
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .onAppear {
            selectedPack = store.settings.selectedPack
        }
    }
}

struct PackCard: View {
    let pack: Pack
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Pack type indicator
                HStack {
                    Circle()
                        .fill(pack.isWikipedia ? Color.orange : Color.blue)
                        .frame(width: 8, height: 8)
                    Text(pack.isWikipedia ? "Wikipedia" : "Offline")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(pack.isWikipedia ? .orange : .blue)
                    Spacer()
                    if pack.isCustom {
                        Image(systemName: "slider.horizontal.3")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(pack.displayName)
                        .font(.headline.bold())
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(pack.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                }
                
                Spacer()
                
                // Sample titles preview (if available)
                if !pack.isWikipedia && !pack.isCustom {
                    let sampleTitles = TitleBank.titlesForPack(pack).prefix(3)
                    if !sampleTitles.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Sample titles:")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.tertiary)
                            ForEach(Array(sampleTitles.enumerated()), id: \.offset) { _, card in
                                Text("• \(card.title)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            }
            .padding(16)
            .frame(width: 220, height: 200)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(
                        color: isSelected ? Color.blue.opacity(0.3) : Color.black.opacity(0.08),
                        radius: isSelected ? 12 : 8,
                        y: isSelected ? 6 : 4
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color.blue : Color.clear,
                                lineWidth: isSelected ? 2 : 0
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Custom Pack Builder

struct CustomPackBuilderView: View {
    @EnvironmentObject var store: GameStore
    @State private var customFilters: CustomPackFilters = .default

    var body: some View {
        VStack(spacing: 0) {
            // Header - Top aligned
            VStack(spacing: 24) {
                Text("Custom Pack")
                    .font(.title.bold())
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 32)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Categories Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Categories")
                            .font(.title3.bold())
                        
                        Text("Select which types of titles to include")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        CategoryChips(selected: $customFilters.categories)
                    }
                    
                    Divider()
                    
                    // Obscurity Range
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Difficulty Level")
                            .font(.title3.bold())
                        
                        Text("1 = Very well-known, 5 = Very obscure")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Min: \(customFilters.obscurityRange.lowerBound)")
                                    .font(.subheadline.weight(.semibold))
                                Slider(
                                    value: Binding(
                                        get: { Double(customFilters.obscurityRange.lowerBound) },
                                        set: { newValue in
                                            let intValue = Int(newValue)
                                            let upperBound = customFilters.obscurityRange.upperBound
                                            customFilters.obscurityRange = intValue...max(intValue, upperBound)
                                        }
                                    ),
                                    in: 1...5,
                                    step: 1
                                )
                            }
                            
                            Spacer().frame(width: 20)
                            
                            VStack(alignment: .leading) {
                                Text("Max: \(customFilters.obscurityRange.upperBound)")
                                    .font(.subheadline.weight(.semibold))
                                Slider(
                                    value: Binding(
                                        get: { Double(customFilters.obscurityRange.upperBound) },
                                        set: { newValue in
                                            let intValue = Int(newValue)
                                            let lowerBound = customFilters.obscurityRange.lowerBound
                                            customFilters.obscurityRange = min(lowerBound, intValue)...intValue
                                        }
                                    ),
                                    in: 1...5,
                                    step: 1
                                )
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Word Count Range
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Phrase Length")
                            .font(.title3.bold())
                        
                        Text("Number of words in each title")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Min: \(customFilters.wordCountRange.lowerBound)")
                                    .font(.subheadline.weight(.semibold))
                                Slider(
                                    value: Binding(
                                        get: { Double(customFilters.wordCountRange.lowerBound) },
                                        set: { newValue in
                                            let intValue = Int(newValue)
                                            let upperBound = customFilters.wordCountRange.upperBound
                                            customFilters.wordCountRange = intValue...max(intValue, upperBound)
                                        }
                                    ),
                                    in: 1...10,
                                    step: 1
                                )
                            }
                            
                            Spacer().frame(width: 20)
                            
                            VStack(alignment: .leading) {
                                Text("Max: \(customFilters.wordCountRange.upperBound)")
                                    .font(.subheadline.weight(.semibold))
                                Slider(
                                    value: Binding(
                                        get: { Double(customFilters.wordCountRange.upperBound) },
                                        set: { newValue in
                                            let intValue = Int(newValue)
                                            let lowerBound = customFilters.wordCountRange.lowerBound
                                            customFilters.wordCountRange = min(lowerBound, intValue)...intValue
                                        }
                                    ),
                                    in: 1...10,
                                    step: 1
                                )
                            }
                        }
                    }
                    
                    // Preview
                    let previewTitles = TitleBank.titlesForPack(.offlineCustom, customFilters: customFilters)
                    if !previewTitles.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Preview (\(previewTitles.count) titles available)")
                                .font(.headline)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                ForEach(Array(previewTitles.prefix(6).enumerated()), id: \.offset) { _, card in
                                    Text(card.title)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.black.opacity(0.05))
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                        .lineLimit(1)
                                }
                            }
                            
                            if previewTitles.count > 6 {
                                Text("...and \(previewTitles.count - 6) more")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.top, 8)
                    } else {
                        Text("No titles match your current filters. Try adjusting your selection.")
                            .font(.caption)
                            .foregroundStyle(.orange)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }

            // Error display area - Fixed height so it doesn't push buttons
            VStack {
                if let error = store.candidateLoadingError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .transition(.opacity)
                }
            }
            .frame(height: 60)
            .padding(.horizontal, 24)
            .animation(.easeInOut(duration: 0.2), value: store.candidateLoadingError != nil)

            // Action buttons - Fixed at bottom
            VStack(spacing: 12) {
                let hasValidTitles = !TitleBank.titlesForPack(.offlineCustom, customFilters: customFilters).isEmpty

                BigButton(title: hasValidTitles ? "Use Custom Pack" : "Adjust Filters") {
                    if hasValidTitles {
                        var settings = store.settings
                        settings.selectedPack = .offlineCustom
                        settings.customPackFilters = customFilters
                        store.settings = settings
                        print("📦 Custom pack configured with \(TitleBank.titlesForPack(.offlineCustom, customFilters: customFilters).count) titles")
                        store.startIntakeWithCustomPack(customFilters)
                    }
                }
                .disabled(!hasValidTitles)

                // Back button
                Button(action: {
                    store.stage = .packSelection
                    print("✅ Stage changed to: .packSelection")
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back to Pack Selection")
                            .font(.system(size: 17))
                    }
                    .foregroundStyle(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .onAppear {
            customFilters = store.settings.customPackFilters
            store.candidateLoadingError = nil // Clear any previous errors
        }
    }
}

struct CategoryChips: View {
    @Binding var selected: Set<Category>

    var body: some View {
        FlowLayout {
            ForEach(Category.allCases, id: \.self) { category in
                let isOn = selected.contains(category)
                Button {
                    if isOn {
                        selected.remove(category)
                    } else {
                        selected.insert(category)
                    }
                    // Ensure at least one category is selected
                    if selected.isEmpty {
                        selected = [.movies]
                    }
                    Haptics.tap()
                } label: {
                    Text(category.displayName)
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

