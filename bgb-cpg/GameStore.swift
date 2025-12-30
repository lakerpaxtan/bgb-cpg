import Foundation
import SwiftUI
import Combine

enum TurnEndReason {
    case timerExpired
    case manual
    case skipCycleComplete
    case completedAllCards
}

@MainActor
final class GameStore: ObservableObject {

    // MARK: - Published state

    @Published var stage: Stage = .home
    @Published var settings: Settings = .default

    @Published var players: [Player] = []
    @Published var teamAOrder: [Player] = []
    @Published var teamBOrder: [Player] = []

    // Master deck: all cards selected during player intake (de-duplicated)
    @Published private(set) var allCards: [Card] = []

    // Current round's working deck (shuffled between rounds, stable during play)
    @Published private(set) var deck: [Card] = []

    // Scores
    @Published private(set) var roundScores: [Int: RoundScore] = [:] // key = round
    @Published private(set) var cumulativeA: Int = 0
    @Published private(set) var cumulativeB: Int = 0
    
    // Player Statistics
    @Published private(set) var playerStats: [UUID: PlayerStats] = [:]

    // Round + turn
    @Published var currentRound: RoundPhase = .one
    @Published var currentTeam: Team = .A
    @Published var clueGiver: Player? = nil

    // Active turn state management
    @Published var timeRemaining: Int = 60
    @Published var turnActive: Bool = false
    @Published var turnPaused: Bool = false
    @Published var skipCount: Int = 0

    // Turn performance tracking and timing
    private var timerCancellable: AnyCancellable?
    @Published private(set) var initialDeckSize: Int = 0
    private var cardShownAt: Date = Date() // Tracks when current card was first shown for duration calculation
    @Published var thisTurnCorrect: [CorrectEvent] = []

    // Intake progress
    @Published var intakeExpectedCount: Int = 0
    @Published var intakeTeamCollecting: Team = .A
    @Published var intakeIndexInTeam: Int = 0

    // Staging buffers for intake
    @Published var pendingName: String = ""
    @Published var pendingTeam: Team = .A
    @Published var candidateTitles: [Card] = []
    @Published var selectedPicks: Set<UUID> = []
    @Published var pendingManualWords: [String] = []
    @Published var loadingCandidates: Bool = false
    @Published var candidateLoadingError: String? = nil
    @Published var manualEntryError: String? = nil
    @Published var sharedTitles: [Card] = []
    @Published var showingRestartConfirmation: Bool = false
    @Published var showingEndTurnConfirmation: Bool = false
    @Published var showingEndGameConfirmation: Bool = false
    @Published var showingPauseSettings: Bool = false
    @Published var showingRulesFromPause: Bool = false
    
    // Mid-game settings adjustment
    @Published var pendingTimerSeconds: Int = 60
    
    // Turn end tracking
    @Published var lastTurnEndReason: TurnEndReason = .manual
    
    // Bonus time system: completing all cards in a turn saves remaining time for next round
    @Published private(set) var savedBonusTime: Int = 0
    @Published private(set) var bonusTimePlayer: Player? = nil

    // UI helpers
    var backgroundColors: [Color] {
        switch stage {
        case .home, .howTo:
            return [Color.white, Color(white: 0.95)]
        case .settings, .packSelection, .customPackBuilder, .intakeHandoff, .intakeName, .intakePicks, .intakeManualWords:
            return [Color(.systemTeal).opacity(0.12), Color(.systemBlue).opacity(0.10)]
        case .roundIntro, .turnHandoff:
            return [currentTeam.color.opacity(0.12), Color(.systemGray6)]
        case .turn, .turnPaused, .turnSkipComplete, .turnComplete:
            return [currentTeam.color.opacity(0.18), .white]
        case .recap:
            return [Color(.systemGray6), .white]
        case .roundEnd:
            return [Color(.systemIndigo).opacity(0.14), .white]
        case .gameEnd, .gameStats:
            return [Color(.systemYellow).opacity(0.18), .white]
        }
    }

    // MARK: - Home / How To

    func goHome(resetAll: Bool = true) {
        print("🏠 GameStore.goHome() called with resetAll: \(resetAll)")
        if resetAll {
            print("🔄 Resetting all game state to defaults")
            settings = .default
            players = []
            teamAOrder = []
            teamBOrder = []
            allCards = []
            deck = []
            roundScores = [:]
            cumulativeA = 0
            cumulativeB = 0
            playerStats = [:]
            savedBonusTime = 0
            bonusTimePlayer = nil
            currentRound = .one
            currentTeam = settings.startingTeam
        }
        stage = .home
        print("✅ Stage changed to: .home")
    }

    func showHowTo() { 
        print("📖 GameStore.showHowTo() - transitioning to how-to screen")
        stage = .howTo 
        print("✅ Stage changed to: .howTo")
    }
    
    func showRestartConfirmation() { showingRestartConfirmation = true }
    
    func confirmRestart() {
        showingRestartConfirmation = false
        goHome(resetAll: true)
        startSettings()
    }
    
    func cancelRestart() { showingRestartConfirmation = false }

    func startSettings() {
        print("⚙️ GameStore.startSettings() - entering settings configuration")
        currentTeam = settings.startingTeam
        stage = .settings
        print("✅ Stage changed to: .settings")
        
    }

    // MARK: - Settings → Pack Selection → Intake

    func startIntakeWithPack(_ pack: Pack) {
        print("👥 GameStore.startIntakeWithPack() - beginning player intake with pack: \(pack.displayName)")
        if settings.nonManualWordsPerPlayer == 0 {
            startIntakeManualOnly()
            return
        }
        startIntakeProcess()
        print("💾 Using premade titles for pack: \(pack.displayName)")
        setupPremadeTitlesForPack(pack)
    }
    
    func startIntakeWithCustomPack(_ customFilters: CustomPackFilters) {
        print("👥 GameStore.startIntakeWithCustomPack() - beginning player intake with custom filters")
        if settings.nonManualWordsPerPlayer == 0 {
            startIntakeManualOnly()
            return
        }
        startIntakeProcess()
        
        // Custom packs are always premade
        print("💾 Using premade titles with custom filters")
        setupPremadeTitlesForCustomPack(customFilters)
    }
    
    // Legacy method for backward compatibility - now uses pack system
    func startIntake() {
        print("👥 GameStore.startIntake() - beginning player intake process with current pack: \(settings.selectedPack.displayName)")
        if settings.selectedPack == .premadeCustom {
            startIntakeWithCustomPack(settings.customPackFilters)
        } else {
            startIntakeWithPack(settings.selectedPack)
        }
    }

    func startIntakeManualOnly() {
        print("👥 GameStore.startIntakeManualOnly() - beginning player intake with manual-only words")
        startIntakeProcess()
        sharedTitles = []
        candidateTitles = []
        candidateLoadingError = nil
        manualEntryError = nil
        stage = .intakeHandoff
        print("✅ Stage changed to: .intakeHandoff")
    }
    
    private func startIntakeProcess() {
        // Reset game state
        players = []
        teamAOrder = []
        teamBOrder = []
        allCards = []
        deck = []
        playerStats = [:]
        savedBonusTime = 0
        bonusTimePlayer = nil
        currentRound = .one
        currentTeam = settings.startingTeam
        candidateTitles = []
        selectedPicks = []
        pendingManualWords = []
        manualEntryError = nil

        intakeExpectedCount = settings.players
        intakeTeamCollecting = .A
        intakeIndexInTeam = 0
    }
    
    private func setupPremadeTitlesForPack(_ pack: Pack) {
        let availableTitles = TitleBank.titlesForPack(pack)
        print("📦 Loaded \(availableTitles.count) titles for pack: \(pack.displayName)")
        
        loadingCandidates = false
        candidateLoadingError = nil
        if availableTitles.count < (settings.players * settings.wordPoolSizePerPlayer) {
            candidateLoadingError = "Pack '\(pack.displayName)' only has \(availableTitles.count) titles, need \(settings.players * settings.wordPoolSizePerPlayer). Try a different pack."
            return
        }
        
        sharedTitles = availableTitles
        stage = .intakeHandoff
        print("✅ Stage changed to: .intakeHandoff")
    }
    
    private func setupPremadeTitlesForCustomPack(_ customFilters: CustomPackFilters) {
        let availableTitles = TitleBank.titlesForPack(.premadeCustom, customFilters: customFilters)
        print("📦 Loaded \(availableTitles.count) titles for custom pack")
        
        if availableTitles.count < (settings.players * settings.wordPoolSizePerPlayer) {
            candidateLoadingError = "Custom pack only has \(availableTitles.count) titles, need \(settings.players * settings.wordPoolSizePerPlayer). Adjust your filters."
            return
        }
        
        sharedTitles = availableTitles
        stage = .intakeHandoff
        print("✅ Stage changed to: .intakeHandoff")
    }
    
    // DELETED: preloadTitles() - unused legacy function replaced by pack-specific preload methods

    // Next handoff prompt during intake
    func intakeProceed() {
        print("➡️ GameStore.intakeProceed() - moving to name entry for \(intakeTeamCollecting)")
        pendingName = ""
        pendingTeam = intakeTeamCollecting
        pendingManualWords = []
        manualEntryError = nil
        stage = .intakeName
        print("✅ Stage changed to: .intakeName")
    }

    func intakeSaveNameAndShowPicks() {
        print("📝 Player name entry: '\(pendingName)' joining \(pendingTeam)")
        selectedPicks = []
        manualEntryError = nil
        
        // Always use pre-loaded shared pool (regardless of source)
        if settings.nonManualWordsPerPlayer > 0 {
            print("🎲 Generating candidate words for player selection")
            generateCandidatesFromSharedPool()
        } else {
            prepareManualWordEntry()
            stage = .intakeManualWords
            print("✅ Stage changed to: .intakeManualWords")
        }
    }

    func intakeProceedToManualWords() {
        prepareManualWordEntry()
        stage = .intakeManualWords
        print("✅ Stage changed to: .intakeManualWords")
    }

    private func prepareManualWordEntry() {
        pendingManualWords = Array(repeating: "", count: settings.manualWordsPerPlayer)
        manualEntryError = nil
    }

    private func wordCount(_ text: String) -> Int {
        text.split(whereSeparator: { $0.isWhitespace }).count
    }

    // MARK: - Candidate generation and selection

    private func categoryUniverse() -> [String] {
        let packFilters = settings.selectedPack.filters
        if settings.selectedPack.isCustom {
            // Use custom pack filters
            let categories = settings.customPackFilters.categories
            return Array(categories.map { $0.rawValue })
        } else {
            // Use predefined pack categories
            return Array(packFilters.categories.map { $0.rawValue })
        }
    }

    private func drawOneCard(avoid existing: Set<String>) -> Card? {
        return drawPremadeCard(avoid: existing)
    }
    
    private func drawPremadeCard(avoid existing: Set<String>) -> Card? {
        // try up to some attempts to avoid duplicates and honor pack filters
        let categories = categoryUniverse()
        guard let randomCategory = categories.randomElement() else { return nil }
        let pool = TitleBank.pool(for: randomCategory).shuffled()

        for title in pool {
            let norm = title.lowercased()
            if existing.contains(norm) { continue }
            // TitleBank is pre-curated, no filtering needed
            return Card(title: title, subject: randomCategory)
        }
        return nil
    }

    
    
    
    private func preloadPremadeTitles(totalNeeded: Int) {
        let subjects = categoryUniverse()
        var set = Set<String>()
        var allCards: [Card] = []
        var cardsPerSubjectCount: [String: Int] = [:]
        
        // Initialize counters
        for subject in subjects {
            cardsPerSubjectCount[subject] = 0
        }
        
        // Round-robin distribution to ensure each subject gets representation
        while allCards.count < totalNeeded {
            var foundCardThisRound = false
            
            for subject in subjects {
                if allCards.count >= totalNeeded { break }
                
                let pool = TitleBank.pool(for: subject).shuffled()
                
                // Find next available card from this subject
                for title in pool {
                    let norm = title.lowercased()
                    if !set.contains(norm) {
                        let card = Card(title: title, subject: subject)
                        allCards.append(card)
                        set.insert(norm)
                        cardsPerSubjectCount[subject]! += 1
                        foundCardThisRound = true
                        break
                    }
                }
            }
            
            // If no cards found in any subject this round, break to avoid infinite loop
            if !foundCardThisRound {
                break
            }
        }
        
        sharedTitles = allCards
    }
    
    private func generateCandidatesFromSharedPool() {
        print("🎲 GameStore.generateCandidatesFromSharedPool() - generating \(settings.wordPoolSizePerPlayer) candidates")
        let existingTitles = Set(allCards.map { $0.title.lowercased() })
        let availableTitles = sharedTitles.filter { card in
            !existingTitles.contains(card.title.lowercased())
        }
        print("📋 Available titles after deduplication: \(availableTitles.count)")
        
        let needed = settings.wordPoolSizePerPlayer
        
        // Group available titles by their subject for diversity
        let titlesBySubject = Dictionary(grouping: availableTitles) { $0.subject }
        let uniqueSubjects = Array(titlesBySubject.keys)
        print("🎨 Subject diversity: \(uniqueSubjects.joined(separator: ", "))")
        
        var diverseTitles: [Card] = []
        
        if !uniqueSubjects.isEmpty {
            // Round-robin distribution to ensure each subject gets representation
                var usedTitles = Set<UUID>()
            
            while diverseTitles.count < needed && diverseTitles.count < availableTitles.count {
                var foundCardThisRound = false
                
                for subject in uniqueSubjects {
                    if diverseTitles.count >= needed { break }
                    
                    if let subjectTitles = titlesBySubject[subject] {
                        // Find next unused title from this subject
                        for title in subjectTitles.shuffled() {
                            if !usedTitles.contains(title.id) {
                                diverseTitles.append(title)
                                usedTitles.insert(title.id)
                                foundCardThisRound = true
                                break
                            }
                        }
                    }
                }
                
                // If no cards found in any subject this round, break to avoid infinite loop
                if !foundCardThisRound {
                    break
                }
            }
        }
        
        // If we still don't have enough, fill with any remaining available titles
        if diverseTitles.count < needed {
            let usedIds = Set(diverseTitles.map { $0.id })
            let remaining = availableTitles.filter { !usedIds.contains($0.id) }
            let additionalNeeded = needed - diverseTitles.count
            diverseTitles.append(contentsOf: Array(remaining.shuffled().prefix(additionalNeeded)))
        }
        
        // Final shuffle and take what we need
        candidateTitles = Array(diverseTitles.shuffled().prefix(needed))
        print("✅ Generated \(candidateTitles.count) diverse candidates for player")
        
        // Go to picks screen immediately since we already have the titles
        stage = .intakePicks
        print("✅ Stage changed to: .intakePicks")
    }

    func reroll(card id: UUID) {
        guard let idx = candidateTitles.firstIndex(where: { $0.id == id }) else { 
            print("❌ reroll() failed: card \(id) not found in candidates")
            return 
        }
        print("🎲 Rerolling candidate: '\(candidateTitles[idx].title)'")
        
        // If this card was selected, deselect it
        if selectedPicks.contains(id) {
            selectedPicks.remove(id)
        }
        
        var existing = Set(candidateTitles.map { $0.title.lowercased() })
        existing.remove(candidateTitles[idx].title.lowercased())
        
        // Also avoid cards already picked by other players
        let globalExisting = Set(allCards.map { $0.title.lowercased() })
        existing.formUnion(globalExisting)
        
        // keep trying until we find a replacement
        var newCard: Card? = nil
        
        newCard = drawOneCard(avoid: existing)
        
        if let new = newCard {
            print("✨ Reroll successful: '\(candidateTitles[idx].title)' -> '\(new.title)'")
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                candidateTitles[idx] = new
            }
            Haptics.soft()
        } else {
            print("⚠️ Reroll failed: no alternative cards available")
        }
    }

    func togglePick(_ id: UUID) {
        if selectedPicks.contains(id) {
            selectedPicks.remove(id)
            print("📝 Deselected pick (\(selectedPicks.count)/\(settings.nonManualWordsPerPlayer))")
            Haptics.tap()
        } else {
            selectedPicks.insert(id)
            print("📝 Selected pick (\(selectedPicks.count)/\(settings.nonManualWordsPerPlayer))")
            Haptics.tap()
        }
    }

    func submitPlayerAndWords() {
        manualEntryError = nil
        if settings.nonManualWordsPerPlayer > 0 && selectedPicks.count != settings.nonManualWordsPerPlayer {
            print("⚠️ submitPlayerAndWords() blocked: selectedPicks=\(selectedPicks.count), expected=\(settings.nonManualWordsPerPlayer)")
            return
        }

        let manualWords = pendingManualWords
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        if settings.manualWordsPerPlayer > 0 {
            if manualWords.count != settings.manualWordsPerPlayer {
                manualEntryError = "Please fill in all manual words."
                print("⚠️ submitPlayerAndWords() blocked: manual words incomplete")
                return
            }
            if manualWords.contains(where: { wordCount($0) > 6 }) {
                manualEntryError = "Manual words must be 6 words or fewer."
                print("⚠️ submitPlayerAndWords() blocked: manual words too long")
                return
            }
        }

        let chosen = candidateTitles.filter { selectedPicks.contains($0.id) }
        var globalLower = Set(allCards.map { $0.title.lowercased() })
        let disallowedManual = globalLower.union(chosen.map { $0.title.lowercased() })
        if settings.manualWordsPerPlayer > 0 {
            let manualLower = manualWords.map { $0.lowercased() }
            if Set(manualLower).count != manualLower.count {
                manualEntryError = "Manual words must be unique."
                print("⚠️ submitPlayerAndWords() blocked: duplicate manual words")
                return
            }
            if manualLower.contains(where: { disallowedManual.contains($0) }) {
                manualEntryError = "Manual words must be unique across the game."
                print("⚠️ submitPlayerAndWords() blocked: manual words duplicate existing entries")
                return
            }
        }

        // Save the player with trimmed name
        let trimmedName = pendingName.trimmingCharacters(in: .whitespacesAndNewlines)
        let p = Player(name: trimmedName.isEmpty ? defaultPlayerName() : trimmedName,
                       team: pendingTeam)
        print("✓ GameStore.submitPlayerAndWords() - player: '\(p.name)' (\(p.team)), picks: \(selectedPicks.count), manual: \(manualWords.count)")
        players.append(p)
        if p.team == .A { teamAOrder.append(p) } else { teamBOrder.append(p) }
        
        // Initialize player stats
        playerStats[p.id] = PlayerStats(playerId: p.id)

        // Add picks to shared deck (de-dupe); if we lose any to de-dupe, auto-draw replacements
        var added = 0
        print("🃏 Selected words: \(chosen.map { $0.title }.joined(separator: ", "))")

        for card in chosen {
            let low = card.title.lowercased()
            if !globalLower.contains(low) {
                allCards.append(card)
                globalLower.insert(low)
                added += 1
            }
        }

        while added < settings.nonManualWordsPerPlayer,
              let extra = drawOneCard(avoid: globalLower) {
            allCards.append(extra)
            globalLower.insert(extra.title.lowercased())
            added += 1
        }

        for manualWord in manualWords {
            let lower = manualWord.lowercased()
            if !globalLower.contains(lower) {
                allCards.append(Card(title: manualWord, subject: "Manual"))
                globalLower.insert(lower)
            }
        }
        print("🃋 Total cards in game deck: \(allCards.count)")

        pendingManualWords = []
        manualEntryError = nil
        // Move to next intake target
        advanceIntakePointer()
    }

    private func defaultPlayerName() -> String {
        // simple auto names if someone skips typing
        let count = players.count + 1
        return "Player \(count)"
    }

    private func advanceIntakePointer() {
        // Cycle through team A first, then team B, as spec says "collect Team A first"
        let totalCollected = players.count
        print("📊 GameStore.advanceIntakePointer() - collected \(totalCollected)/\(intakeExpectedCount) players")
        if totalCollected < intakeExpectedCount {
            // still collecting team A until half rounded down?
            let half = intakeExpectedCount / 2
            if teamAOrder.count < half {
                intakeTeamCollecting = .A
            } else {
                intakeTeamCollecting = .B
            }
            print("➡️ Next player from \(intakeTeamCollecting) (A: \(teamAOrder.count), B: \(teamBOrder.count))")
            stage = .intakeHandoff
            print("✅ Stage changed to: .intakeHandoff")
        } else {
            // Intake done → Round 1 intro
            print("🎉 Player intake complete! Starting game with \(allCards.count) cards")
            currentRound = .one
            currentTeam = settings.startingTeam
            stage = .roundIntro
            print("✅ Stage changed to: .roundIntro (Round \(currentRound.rawValue))")
        }
    }

    // MARK: - Round / Deck

    private func resetDeckForRound() {
        // Same cards, shuffle between rounds, stable during round
        print("🎲 GameStore.resetDeckForRound() - shuffling \(allCards.count) cards for round \(currentRound.rawValue)")
        deck = allCards.shuffled()
    }

    func startRound() {
        print("🏁 GameStore.startRound() - starting \(currentRound.title)")
        if deck.isEmpty { resetDeckForRound() }
        stage = .turnHandoff
        print("✅ Stage changed to: .turnHandoff")
        setNextClueGiverIfNeeded()
    }

    func setNextClueGiverIfNeeded() {
        // Check if we have a bonus time player who should go first
        if let bonusPlayer = bonusTimePlayer {
            print("⏱️ GameStore.setNextClueGiverIfNeeded() - bonus time player: \(bonusPlayer.name) gets priority")
            clueGiver = bonusPlayer
            currentTeam = bonusPlayer.team
            return
        }
        
        // Pick next in team rotation; alternate teams each turn
        let order = (currentTeam == .A) ? teamAOrder : teamBOrder
        guard !order.isEmpty else {
            print("⚠️ GameStore.setNextClueGiverIfNeeded() - no players in \(currentTeam)")
            clueGiver = nil
            return
        }
        // Rotate using modulo of how many turns this team has taken so far
        let turnsForTeam = turnsTaken(for: currentTeam)
        let idx = turnsForTeam % order.count
        clueGiver = order[idx]
        print("🎯 GameStore.setNextClueGiverIfNeeded() - \(currentTeam) turn \(turnsForTeam + 1): \(clueGiver?.name ?? "unknown")")
    }

    private func turnsTaken(for team: Team) -> Int {
        // Track turn count for fair rotation within each team
        if team == .A {
            return teamATurns
        } else {
            return teamBTurns
        }
    }

    private var teamATurns = 0
    private var teamBTurns = 0

    // MARK: - Turn lifecycle


    func beginTurn() {
        print("🗣️ GameStore.beginTurn() - \(clueGiver?.name ?? "unknown")'s turn begins")
        guard !deck.isEmpty else {
            print("🃏 Deck is empty, ending round")
            endRoundIfNeeded()
            return
        }
        thisTurnCorrect = []
        skipCount = 0
        
        // Use bonus time if this player completed the previous round
        if let bonusPlayer = bonusTimePlayer, bonusPlayer.id == clueGiver?.id, savedBonusTime > 0 {
            timeRemaining = min(savedBonusTime, settings.timerSeconds)
            print("⏱️ Using bonus time: \(timeRemaining)s (was \(savedBonusTime)s)")
            // Clear the bonus after using it
            savedBonusTime = 0
            bonusTimePlayer = nil
        } else {
            timeRemaining = settings.timerSeconds
            print("⏰ Standard timer: \(timeRemaining)s")
        }
        
        initialDeckSize = deck.count
        cardShownAt = Date()
        turnActive = true
        stage = .turn
        print("✅ Stage changed to: .turn")
        print("🃏 Deck size: \(deck.count), first card: \(deck.first?.title ?? "none")")
        
        // Track that this player is taking a turn
        if let clueGiver = clueGiver {
            playerStats[clueGiver.id]?.addTurn()
        }

        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.turnActive && !self.turnPaused && self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                    if self.timeRemaining == 0 {
                        print("⏰ Timer expired! Ending turn")
                        Haptics.rigid()
                        self.finishTurnToRecap(reason: .timerExpired)
                    }
                }
            }

        Haptics.tap()
    }
    
    func pauseTurn() {
        guard turnActive && !turnPaused else { 
            print("🎯 pauseTurn() blocked: turnActive=\(turnActive), turnPaused=\(turnPaused)")
            return 
        }
        print("⏸️ Turn paused at \(timeRemaining)s remaining")
        turnPaused = true
        stage = .turnPaused
        Haptics.soft()
    }
    
    func unpauseTurn() {
        guard turnActive && turnPaused else { 
            print("🎯 unpauseTurn() blocked: turnActive=\(turnActive), turnPaused=\(turnPaused)")
            return 
        }
        print("▶️ Turn resumed with \(timeRemaining)s remaining")
        turnPaused = false
        stage = .turn
        Haptics.soft()
    }
    
    func showEndTurnConfirmation() {
        showingEndTurnConfirmation = true
    }
    
    func confirmEndTurn() {
        showingEndTurnConfirmation = false
        finishTurnToRecap(reason: .manual)
    }
    
    func cancelEndTurn() {
        showingEndTurnConfirmation = false
    }
    
    func showEndGameConfirmation() {
        showingEndGameConfirmation = true
    }
    
    func confirmEndGame() {
        showingEndGameConfirmation = false
        goHome(resetAll: true)
    }
    
    func cancelEndGame() {
        showingEndGameConfirmation = false
    }
    
    func showPauseSettings() {
        pendingTimerSeconds = settings.timerSeconds
        showingPauseSettings = true
    }
    
    func savePauseSettings() {
        var updatedSettings = settings
        updatedSettings.timerSeconds = pendingTimerSeconds
        settings = updatedSettings
        showingPauseSettings = false
    }
    
    func cancelPauseSettings() {
        showingPauseSettings = false
    }
    
    func showRulesFromPause() {
        showingRulesFromPause = true
    }
    
    func hideRulesFromPause() {
        showingRulesFromPause = false
    }
    
    func proceedFromSkipComplete() {
        finishTurnToRecap(reason: .skipCycleComplete)
    }
    
    private func checkTurnEndConditions() {
        // Determine if turn should end based on progress through initial deck size
        // Check if we've processed all initially available cards
        if (skipCount + thisTurnCorrect.count >= initialDeckSize) && (skipCount > 0) {
            // Player has cycled through all cards - end turn
            print("🔄 Skip cycle complete: processed \(skipCount + thisTurnCorrect.count)/\(initialDeckSize) cards")
            turnActive = false
            stage = .turnSkipComplete
            Haptics.soft()
        } else if deck.isEmpty {
            // All cards completed! Save bonus time for this player
            // Note: This rarely triggers since skipCard() guards against empty deck
            savedBonusTime = timeRemaining
            bonusTimePlayer = clueGiver
            finishTurnToRecap(reason: .completedAllCards)
        }
    }

    func markCorrect() {
        guard turnActive, !deck.isEmpty else { 
            print("🎯 markCorrect() blocked: turnActive=\(turnActive), deck.isEmpty=\(deck.isEmpty)")
            return 
        }
        let now = Date()
        let d = now.timeIntervalSince(cardShownAt)

        // Remove current top
        let current = deck.removeFirst()
        print("✓ GameStore.markCorrect() - '\(current.title)' in \(String(format: "%.1f", d))s")
        // Original index is always 0 here (top of deck)
        let ev = CorrectEvent(card: current, originalIndex: 0, duration: d, highlighted: true)
        thisTurnCorrect.append(ev)
        
        // Track correct answer for the clue giver
        if let clueGiver = clueGiver {
            playerStats[clueGiver.id]?.addCorrectAnswer(duration: d)
        }

        Haptics.success()
        print("🎉 Total correct this turn: \(thisTurnCorrect.count), remaining cards: \(deck.count)")

        // Check for turn end conditions
        checkTurnEndConditions()
        
        // If turn is still active, show next card and reset timing
        if turnActive {
            cardShownAt = Date() // Reset timing for new card
            if !deck.isEmpty {
                print("📏 Next card: \(deck.first?.title ?? "none")")
            }
        }
    }

    func skipCard() {
        guard turnActive, !deck.isEmpty else { 
            print("🎯 skipCard() blocked: turnActive=\(turnActive), deck.isEmpty=\(deck.isEmpty)")
            return 
        }
        guard currentRound != .one else { 
            print("🎯 skipCard() blocked: skipping disabled in Round 1")
            return 
        }

        let card = deck.removeFirst()
        deck.append(card)
        skipCount += 1
        print("⏭️ GameStore.skipCard() - '\(card.title)' skipped (\(skipCount) total skips)")
        Haptics.tap()

        // Check for turn end conditions
        checkTurnEndConditions()

        // If turn is still active, reset timing for new card after skip
        if turnActive {
            cardShownAt = Date() // Reset timing after skip
            print("📏 Next card: \(deck.first?.title ?? "none")")
        }
    }

    func finishTurnToRecap(reason: TurnEndReason = .manual) {
        print("🏁 GameStore.finishTurnToRecap() - reason: \(reason), correct: \(thisTurnCorrect.count)")
        // Handle different turn end scenarios:
        // - Timer expired: move unfinished card to bottom (player was stuck)
        // - Manual/complete: leave deck as-is (player chose to end)
        if reason == .timerExpired && !deck.isEmpty {
            let top = deck.removeFirst()
            deck.append(top)
            print("📏 Timeout - moved '\(top.title)' to bottom of deck")
        }
        turnActive = false
        timerCancellable?.cancel()

        // Score add for this turn (cumulative, but also store round snapshot)
        var r = roundScores[currentRound.rawValue] ?? RoundScore()
        switch currentTeam {
        case .A:
            r.teamA += thisTurnCorrect.count
            cumulativeA += thisTurnCorrect.count
            teamATurns += 1
        case .B:
            r.teamB += thisTurnCorrect.count
            cumulativeB += thisTurnCorrect.count
            teamBTurns += 1
        }
        roundScores[currentRound.rawValue] = r
        print("📊 Scores updated - \(currentTeam): +\(thisTurnCorrect.count) (A: \(cumulativeA), B: \(cumulativeB))")

        // Store the reason and show notification for all turn ends except skip cycle complete
        lastTurnEndReason = reason
        if reason == .skipCycleComplete {
            stage = .recap
            print("✅ Stage changed to: .recap")
        } else {
            stage = .turnComplete
            print("✅ Stage changed to: .turnComplete")
        }
        Haptics.soft()
    }
    
    func proceedFromTurnComplete() {
        stage = .recap
    }

    func undo(event id: UUID) {
        guard let idx = thisTurnCorrect.firstIndex(where: { $0.id == id }) else { 
            print("❌ undo() failed: event \(id) not found in thisTurnCorrect")
            return 
        }
        let ev = thisTurnCorrect.remove(at: idx)
        print("↩️ Undoing correct answer: '\(ev.card.title)' back to deck position \(ev.originalIndex)")

        // Reinsert card at its original position (clamped)
        let pos = max(0, min(ev.originalIndex, deck.count))
        deck.insert(ev.card, at: pos)

        // Decrement score that we tentatively added for this turn
        if var r = roundScores[currentRound.rawValue] {
            if currentTeam == .A { r.teamA = max(0, r.teamA - 1); cumulativeA = max(0, cumulativeA - 1) }
            else { r.teamB = max(0, r.teamB - 1); cumulativeB = max(0, cumulativeB - 1) }
            roundScores[currentRound.rawValue] = r
        }
        
        // Update player stats to remove the undone answer
        if let clueGiver = clueGiver, let stats = playerStats[clueGiver.id] {
            var updatedStats = stats
            updatedStats.totalCorrectAnswers = max(0, updatedStats.totalCorrectAnswers - 1)
            updatedStats.totalTurnTime = max(0, updatedStats.totalTurnTime - ev.duration)
            playerStats[clueGiver.id] = updatedStats
        }
        
        Haptics.warning()
    }

    func recapDoneNextHandoff() {
        print("🗓️ GameStore.recapDoneNextHandoff() - processing recap and moving to next turn")
        // Process recap results: untoggled cards weren't actually correct, so remove from scoring
        let untoggled = thisTurnCorrect.filter { !$0.highlighted }
        if !untoggled.isEmpty {
            print("❌ Removing \(untoggled.count) untoggled cards from score")
        }
        for ev in untoggled {
            // Put card at bottom of deck
            deck.append(ev.card)
            
            // Remove from score
            if var r = roundScores[currentRound.rawValue] {
                if currentTeam == .A { r.teamA = max(0, r.teamA - 1); cumulativeA = max(0, cumulativeA - 1) }
                else { r.teamB = max(0, r.teamB - 1); cumulativeB = max(0, cumulativeB - 1) }
                roundScores[currentRound.rawValue] = r
            }
            
            // Remove from player stats as well
            if let clueGiver = clueGiver, let stats = playerStats[clueGiver.id] {
                var updatedStats = stats
                updatedStats.totalCorrectAnswers = max(0, updatedStats.totalCorrectAnswers - 1)
                updatedStats.totalTurnTime = max(0, updatedStats.totalTurnTime - ev.duration)
                playerStats[clueGiver.id] = updatedStats
            }
        }
        
        // If there were untoggled cards and this player had bonus time, remove the bonus
        if !untoggled.isEmpty && bonusTimePlayer?.id == clueGiver?.id {
            print("⏱️ Removing bonus time due to untoggled cards")
            savedBonusTime = 0
            bonusTimePlayer = nil
        }
        
        // Clear this turn's events
        thisTurnCorrect.removeAll()
        
        // All corrects are already counted. Move to next team handoff or end round.
        if deck.isEmpty {
            print("🃏 Deck empty after recap processing - ending round")
            endRoundIfNeeded()
            return
        }
        // Alternate to the other team for next turn
        let nextTeam: Team = (currentTeam == .A) ? .B : .A
        currentTeam = nextTeam
        print("➡️ Switching to \(currentTeam) for next turn")
        setNextClueGiverIfNeeded()
        stage = .turnHandoff
        print("✅ Stage changed to: .turnHandoff")
    }

    private func endRoundIfNeeded() {
        // Determine next stage based on round completion
        if deck.isEmpty {
            print("🏁 Round \(currentRound.rawValue) complete - all cards played")
            // Skip round complete screen for Round 3, go directly to game end
            if currentRound == .three {
                print("🏆 Game complete - moving to final scores")
                stage = .gameEnd
            } else {
                print("📊 Moving to round end summary")
                stage = .roundEnd
            }
        } else {
            print("⚠️ endRoundIfNeeded() called but deck not empty (\(deck.count) cards left)")
            stage = .turnHandoff
        }
    }

    func proceedToNextRoundOrEnd() {
        print("🔄 GameStore.proceedToNextRoundOrEnd() - current round: \(currentRound.rawValue)")
        switch currentRound {
        case .one:
            currentRound = .two
            print("✅ Advanced to Round 2")
        case .two:
            currentRound = .three
            print("✅ Advanced to Round 3")
        case .three:
            // End of game
            print("🏆 Game complete!")
            stage = .gameEnd
            print("✅ Stage changed to: .gameEnd")
            return
        }
        // Reset deck (same cards), shuffle again
        resetDeckForRound()
        // Starting team alternates by round? Spec only says "Starting team" in settings; keep it fixed.
        currentTeam = settings.startingTeam
        setNextClueGiverIfNeeded()
        stage = .roundIntro
        print("✅ Stage changed to: .roundIntro")
    }

    // MARK: - Stats (computed when round ends)

    struct Highlight: Identifiable {
        let id = UUID()
        let text: String
    }

    func roundHighlights() -> [Highlight] {
        // We have only per-team counts right now. For richer stats, we need per-turn data.
        // We'll approximate using thisTurnCorrect durations captured last turn; for a real build, store all turn logs.
        // To keep it simple and still fun, synthesize highlights from current round score + placeholders.
        let r = roundScores[currentRound.rawValue] ?? RoundScore()
        var out: [Highlight] = []

        if r.teamA > r.teamB {
            out.append(.init(text: "Team A led this round by \(r.teamA - r.teamB)."))
        } else if r.teamB > r.teamA {
            out.append(.init(text: "Team B led this round by \(r.teamB - r.teamA)."))
        } else {
            out.append(.init(text: "Round tied — nice balance."))
        }

        // Fake a slowest card using last turn durations if available
        if let slow = thisTurnCorrect.max(by: { $0.duration < $1.duration }) {
            let sec = Int(slow.duration.rounded())
            out.append(.init(text: "“\(slow.card.title)” took \(sec)s — slowest this turn."))
        }

        // Simple streak using this turn's data
        let streak = maxStreakCount(in: thisTurnCorrect.map { _ in 1 })
        if streak >= 3 {
            out.append(.init(text: "Fast streak: \(streak) in a row!"))
        }

        return Array(out.prefix(settings.stats.highlightsPerRound))
    }

    private func maxStreakCount(in arr: [Int]) -> Int {
        // arr is sequence of 1s (corrects). This is a placeholder for streaks.
        var best = 0, cur = 0
        for v in arr {
            if v > 0 { cur += 1; best = max(best, cur) } else { cur = 0 }
        }
        return best
    }

    // MARK: - Game End

    var isTie: Bool { cumulativeA == cumulativeB }


    func newGame() {
        print("🆕 Starting completely new game")
        goHome(resetAll: true)
    }
    
    func showGameStats() {
        stage = .gameStats
    }
    
    func hideGameStats() {
        stage = .gameEnd
    }

    // MARK: - Tokenization for "no-say chips"

    func tokens(for title: String) -> [Token] {
        let lower = title.lowercased()
        // Split title into individual words, ignoring punctuation and special characters
        let parts = lower.split { !$0.isLetter && !$0.isNumber }
        var out: [Token] = []

        for (i, p) in parts.enumerated() {
            let word = String(p)
            // Leading articles (The, A, An) are optional if configured - these appear as gray chips
            let isLeadingArticle = (i == 0) && settings.acceptance.ignoreLeadingArticle &&
                settings.acceptance.leadingArticles.contains(word)
            out.append(Token(text: word, required: !isLeadingArticle))
        }
        return out
    }
}
