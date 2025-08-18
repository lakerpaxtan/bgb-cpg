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

    // MARK: - Services
    
    @Published var wikipediaService = WikipediaService()
    
    // MARK: - Published state

    @Published var stage: Stage = .home
    @Published var settings: Settings = .default

    @Published var players: [Player] = []
    @Published var teamAOrder: [Player] = []
    @Published var teamBOrder: [Player] = []

    // The full set of cards for the game (after intake de-dupe)
    @Published private(set) var allCards: [Card] = []

    // Deck for current round (stable order until round ends)
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

    // Turn control
    @Published var timeRemaining: Int = 60
    @Published var turnActive: Bool = false
    @Published var turnPaused: Bool = false
    @Published var skipLocked: Bool = false
    @Published var skipCount: Int = 0

    // Tracking
    private var timerCancellable: AnyCancellable?
    @Published private(set) var initialDeckSize: Int = 0
    private var cardShownAt: Date = Date()
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
    @Published var loadingCandidates: Bool = false
    @Published var candidateLoadingError: String? = nil
    @Published var sharedWikipediaTitles: [Card] = [] // Pre-loaded titles for all players
    @Published var showingRestartConfirmation: Bool = false
    @Published var showingEndTurnConfirmation: Bool = false
    @Published var showingEndGameConfirmation: Bool = false
    @Published var showingPauseSettings: Bool = false
    @Published var showingRulesFromPause: Bool = false
    
    // Mid-game settings adjustment
    @Published var pendingTimerSeconds: Int = 60
    
    // Turn end tracking
    @Published var lastTurnEndReason: TurnEndReason = .manual
    
    // Bonus time tracking for completing all cards
    @Published private(set) var savedBonusTime: Int = 0
    @Published private(set) var bonusTimePlayer: Player? = nil

    // UI helpers
    var backgroundColors: [Color] {
        switch stage {
        case .home, .howTo:
            return [Color.white, Color(white: 0.95)]
        case .settings, .intakeHandoff, .intakeName, .intakePicks:
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
        
        // Check Wikipedia availability when entering settings
        Task {
            print("🌐 Checking Wikipedia availability in background...")
            await wikipediaService.checkAvailability()
        }
    }

    // MARK: - Settings → Intake

    func startIntake() {
        print("👥 GameStore.startIntake() - beginning player intake process")
        print("📋 Settings: \(settings.players) players, \(settings.titlesPerPlayer) titles/player, source: \(settings.contentSource)")
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

        intakeExpectedCount = settings.players
        intakeTeamCollecting = .A
        intakeIndexInTeam = 0
        
        // Set loading state but stay on settings screen
        loadingCandidates = true
        candidateLoadingError = nil
        print("🔄 Starting title preloading without changing stage")
        preloadTitles()
    }
    
    // Unified function to preload titles from any source
    private func preloadTitles() {
        print("📦 GameStore.preloadTitles() - starting title preloading")
        Task {
            await preloadTitlesAsync()
        }
    }
    
    @MainActor
    private func preloadTitlesAsync() async {
        loadingCandidates = true
        candidateLoadingError = nil
        sharedWikipediaTitles = []
        
        let totalNeeded = settings.players * settings.titlesPerPlayer
        print("📊 GameStore.preloadTitlesAsync() - need \(totalNeeded) total titles")
        
        switch settings.contentSource {
        case .wikipedia:
            print("🌐 Using Wikipedia content source")
            await preloadWikipediaTitlesAsync(totalNeeded: totalNeeded)
        case .offline:
            print("💾 Using offline content source")
            preloadOfflineTitles(totalNeeded: totalNeeded)
        }
        
        loadingCandidates = false
        print("✅ Title preloading complete")
        
        // Move to intake handoff when loading is complete and no errors
        if candidateLoadingError == nil {
            stage = .intakeHandoff
            print("✅ Stage changed to: .intakeHandoff")
        } else {
            print("❌ Staying on settings due to loading error")
        }
    }

    // Next handoff prompt during intake
    func intakeProceed() {
        print("➡️ GameStore.intakeProceed() - moving to name entry for \(intakeTeamCollecting)")
        pendingName = ""
        pendingTeam = intakeTeamCollecting
        stage = .intakeName
        print("✅ Stage changed to: .intakeName")
    }

    func intakeSaveNameAndShowPicks() {
        print("📝 GameStore.intakeSaveNameAndShowPicks() - name: '\(pendingName)', team: \(pendingTeam)")
        selectedPicks = []
        
        // Always use pre-loaded shared pool (regardless of source)
        generateCandidatesFromSharedPool()
    }

    // MARK: - Candidate generation and selection

    private func subjectUniverse() -> [String] {
        let subs = settings.filters.subjects
        if subs.contains(.everything) || subs.isEmpty {
            return Subject.allCases.filter { $0 != .everything }.map { $0.rawValue }
        }
        return Array(subs.map { $0.rawValue })
    }

    private func drawOneCard(avoid existing: Set<String>) -> Card? {
        switch settings.contentSource {
        case .offline:
            return drawOfflineCard(avoid: existing)
        case .wikipedia:
            // For individual card draws, fall back to offline
            // Wikipedia fetching will be done in bulk during generateCandidates
            return drawOfflineCard(avoid: existing)
        }
    }
    
    private func drawOfflineCard(avoid existing: Set<String>) -> Card? {
        // try up to some attempts to avoid duplicates and honor filters
        let subjects = subjectUniverse()
        guard let randomSubject = subjects.randomElement() else { return nil }
        let pool = TitleBank.pool(for: randomSubject).shuffled()

        for title in pool {
            let norm = title.lowercased()
            if existing.contains(norm) { continue }
            // TitleBank is pre-curated, no filtering needed
            return Card(title: title, subject: randomSubject)
        }
        return nil
    }

    
    
    
    @MainActor
    private func preloadWikipediaTitlesAsync(totalNeeded: Int) async {
        print("🌐 Fetching Wikipedia titles")
        do {
            let wikipediaCards = try await wikipediaService.fetchTitles(
                filters: settings.wikipediaFilters,
                count: totalNeeded
            )
            
            // Check if we got enough Wikipedia titles
            if wikipediaCards.count < totalNeeded {
                print("❌ Not enough Wikipedia titles: got \(wikipediaCards.count), need \(totalNeeded)")
                candidateLoadingError = "Only found \(wikipediaCards.count) Wikipedia articles (need \(totalNeeded)). Please adjust your filters."
                return
            }
            
            sharedWikipediaTitles = wikipediaCards
            print("✅ Successfully loaded \(wikipediaCards.count) Wikipedia titles")
        } catch {
            candidateLoadingError = "Wikipedia failed: \(error.localizedDescription). Please check your connection or adjust your filters."
            print("❌ Wikipedia pre-load failed: \(error)")
            sharedWikipediaTitles = []
            return
        }
    }
    
    private func preloadOfflineTitles(totalNeeded: Int) {
        let subjects = subjectUniverse()
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
        
        sharedWikipediaTitles = allCards
    }
    
    private func generateCandidatesFromSharedPool() {
        print("🎲 GameStore.generateCandidatesFromSharedPool() - generating \(settings.titlesPerPlayer) candidates")
        let existingTitles = Set(allCards.map { $0.title.lowercased() })
        let availableTitles = sharedWikipediaTitles.filter { card in
            !existingTitles.contains(card.title.lowercased())
        }
        print("📋 Available titles after deduplication: \(availableTitles.count)")
        
        let needed = settings.titlesPerPlayer
        
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
        guard let idx = candidateTitles.firstIndex(where: { $0.id == id }) else { return }
        
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
        
        if settings.contentSource == .wikipedia {
            // For Wikipedia, use shared pool
            let availableTitles = sharedWikipediaTitles.filter { card in
                !existing.contains(card.title.lowercased())
            }
            newCard = availableTitles.randomElement()
        } else {
            // For offline, use the old logic
            newCard = drawOneCard(avoid: existing)
        }
        
        if let new = newCard {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                candidateTitles[idx] = new
            }
            Haptics.soft()
        }
    }

    func togglePick(_ id: UUID) {
        if selectedPicks.contains(id) {
            selectedPicks.remove(id)
            Haptics.tap()
        } else {
            selectedPicks.insert(id)
            Haptics.tap()
        }
    }

    func submitPlayerAndPicks() {
        // Save the player with trimmed name
        let trimmedName = pendingName.trimmingCharacters(in: .whitespacesAndNewlines)
        let p = Player(name: trimmedName.isEmpty ? defaultPlayerName() : trimmedName,
                       team: pendingTeam)
        print("✓ GameStore.submitPlayerAndPicks() - player: '\(p.name)' (\(p.team)), picks: \(selectedPicks.count)")
        players.append(p)
        if p.team == .A { teamAOrder.append(p) } else { teamBOrder.append(p) }
        
        // Initialize player stats
        playerStats[p.id] = PlayerStats(playerId: p.id)

        // Add picks to shared deck (de-dupe); if we lose any to de-dupe, auto-draw replacements
        var added = 0
        var globalLower = Set(allCards.map { $0.title.lowercased() })
        let chosen = candidateTitles.filter { selectedPicks.contains($0.id) }
        print("🃏 Selected titles: \(chosen.map { $0.title }.joined(separator: ", "))")

        for card in chosen {
            let low = card.title.lowercased()
            if !globalLower.contains(low) {
                allCards.append(card)
                globalLower.insert(low)
                added += 1
            }
        }

        while added < settings.picksPerPlayer,
              let extra = drawOneCard(avoid: globalLower) {
            allCards.append(extra)
            globalLower.insert(extra.title.lowercased())
            added += 1
        }
        print("🃋 Total cards in game deck: \(allCards.count)")

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
        // approximate from per-round scores; not exact, but we just need stable rotation
        // Better: store counters
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
        skipLocked = false
        
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
        guard turnActive && !turnPaused else { return }
        turnPaused = true
        stage = .turnPaused
        Haptics.soft()
    }
    
    func unpauseTurn() {
        guard turnActive && turnPaused else { return }
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
        // Check if we've processed all initially available cards
        if (skipCount + thisTurnCorrect.count >= initialDeckSize) && (skipCount > 0) {
            // Player has cycled through all cards - end turn
            skipLocked = true
            turnActive = false
            stage = .turnSkipComplete
            Haptics.soft()
        } else if deck.isEmpty {
            // Player completed all remaining cards! End turn immediately
            // Note: This condition will never happen in skipCard() since it guards against empty deck
            savedBonusTime = timeRemaining
            bonusTimePlayer = clueGiver
            finishTurnToRecap(reason: .completedAllCards)
        }
    }

    func markCorrect() {
        guard turnActive, !deck.isEmpty else { return }
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
        
        // If turn is still active, show next card
        if turnActive {
            cardShownAt = Date()
            if !deck.isEmpty {
                print("📏 Next card: \(deck.first?.title ?? "none")")
            }
        }
    }

    func skipCard() {
        guard turnActive, !deck.isEmpty else { return }
        guard currentRound != .one else { return } // disabled in round 1
        guard !skipLocked else {
            print("⛔ Skip locked - turn ending soon")
            Haptics.warning()
            return
        }

        let card = deck.removeFirst()
        deck.append(card)
        skipCount += 1
        print("⏭️ GameStore.skipCard() - '\(card.title)' skipped (\(skipCount) total skips)")
        Haptics.tap()

        // Check for turn end conditions
        checkTurnEndConditions()

        // If turn is still active, reset show-time for duration tracking
        if turnActive {
            cardShownAt = Date()
            print("📏 Next card: \(deck.first?.title ?? "none")")
        }
    }

    func finishTurnToRecap(reason: TurnEndReason = .manual) {
        print("🏁 GameStore.finishTurnToRecap() - reason: \(reason), correct: \(thisTurnCorrect.count)")
        // Turn stops; current top card (unfinished) stays and will resume next turn (bottom push on timeout per spec)
        // Spec: "Timer end: auto-opens Turn Recap; current card goes to bottom."
        // Only cycle the card if the timer ran out (player was stuck on it)
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
        guard let idx = thisTurnCorrect.firstIndex(where: { $0.id == id }) else { return }
        let ev = thisTurnCorrect.remove(at: idx)

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
        // Handle untoggled cards - put them at bottom of deck and remove from score
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
            print("🃏 Deck empty - ending round")
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
        // If deck empty, round complete
        if deck.isEmpty {
            // Skip round complete screen for Round 3, go directly to game end
            if currentRound == .three {
                stage = .gameEnd
            } else {
                stage = .roundEnd
            }
        } else {
            // Defensive; usually not hit
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

    func rematchSameSettings() {
        // Keep players and cards, reset scores and round
        cumulativeA = 0
        cumulativeB = 0
        roundScores = [:]
        
        // Reset player stats but keep player associations
        for playerId in playerStats.keys {
            playerStats[playerId] = PlayerStats(playerId: playerId)
        }
        
        // Reset bonus time
        savedBonusTime = 0
        bonusTimePlayer = nil
        
        currentRound = .one
        deck = []
        resetDeckForRound()
        currentTeam = settings.startingTeam
        teamATurns = 0
        teamBTurns = 0
        setNextClueGiverIfNeeded()
        stage = .roundIntro
        Haptics.soft()
    }

    func newGame() {
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
        // Split on non-letters/numbers
        let parts = lower.split { !$0.isLetter && !$0.isNumber }
        var out: [Token] = []

        for (i, p) in parts.enumerated() {
            let word = String(p)
            let isLeadingArticle = (i == 0) && settings.acceptance.ignoreLeadingArticle &&
                settings.acceptance.leadingArticles.contains(word)
            out.append(Token(text: word, required: !isLeadingArticle))
        }
        return out
    }
}
