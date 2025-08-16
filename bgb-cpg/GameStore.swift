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
        case .roundIntro, .turnHandoff, .turnReady:
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
        if resetAll {
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
    }

    func showHowTo() { stage = .howTo }
    
    func showRestartConfirmation() { showingRestartConfirmation = true }
    
    func confirmRestart() {
        showingRestartConfirmation = false
        goHome(resetAll: true)
        startSettings()
    }
    
    func cancelRestart() { showingRestartConfirmation = false }

    func startSettings() {
        currentTeam = settings.startingTeam
        stage = .settings
    }

    // MARK: - Settings → Intake

    func startIntake() {
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

        stage = .intakeHandoff
    }

    // Next handoff prompt during intake
    func intakeProceed() {
        pendingName = ""
        pendingTeam = intakeTeamCollecting
        stage = .intakeName
    }

    func intakeSaveNameAndShowPicks() {
        // create per-player candidate list now
        generateCandidates()
        selectedPicks = []
        stage = .intakePicks
    }

    // MARK: - Candidate generation and selection

    private func subjectUniverse() -> [Subject] {
        let subs = settings.filters.subjects
        if subs.contains(.everything) || subs.isEmpty {
            return Subject.allCases.filter { $0 != .everything }
        }
        return Array(subs)
    }

    private func drawOneCard(avoid existing: Set<String>) -> Card? {
        // try up to some attempts to avoid duplicates and honor filters
        let subjects = subjectUniverse()
        guard let randomSubject = subjects.randomElement() else { return nil }
        let pool = TitleBank.pool(for: randomSubject).shuffled()

        for title in pool {
            let norm = title.lowercased()
            if existing.contains(norm) { continue }
            if TitleFilter.isValid(title, filters: settings.filters) {
                return Card(title: title, subject: randomSubject)
            }
        }
        return nil
    }

    private func generateCandidates() {
        var set = Set<String>()
        
        // Start with cards already picked by other players to avoid duplicates
        let globalExisting = Set(allCards.map { $0.title.lowercased() })
        set.formUnion(globalExisting)
        
        candidateTitles = []
        let need = settings.titlesPerPlayer
        var tries = 0
        while candidateTitles.count < need && tries < need * 50 {
            if let card = drawOneCard(avoid: set) {
                candidateTitles.append(card)
                set.insert(card.title.lowercased())
            }
            tries += 1
        }
        if candidateTitles.count < need {
            // It's fine if we come up a bit short; rerolls can fill.
        }
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
        if let new = drawOneCard(avoid: existing) {
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
        players.append(p)
        if p.team == .A { teamAOrder.append(p) } else { teamBOrder.append(p) }
        
        // Initialize player stats
        playerStats[p.id] = PlayerStats(playerId: p.id)

        // Add picks to shared deck (de-dupe); if we lose any to de-dupe, auto-draw replacements
        var added = 0
        var globalLower = Set(allCards.map { $0.title.lowercased() })
        let chosen = candidateTitles.filter { selectedPicks.contains($0.id) }

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
        if totalCollected < intakeExpectedCount {
            // still collecting team A until half rounded down?
            let half = intakeExpectedCount / 2
            if teamAOrder.count < half {
                intakeTeamCollecting = .A
            } else {
                intakeTeamCollecting = .B
            }
            stage = .intakeHandoff
        } else {
            // Intake done → Round 1 intro
            currentRound = .one
            currentTeam = settings.startingTeam
            stage = .roundIntro
        }
    }

    // MARK: - Round / Deck

    private func resetDeckForRound() {
        // Same cards, shuffle between rounds, stable during round
        deck = allCards.shuffled()
    }

    func startRound() {
        if deck.isEmpty { resetDeckForRound() }
        stage = .turnHandoff
        setNextClueGiverIfNeeded()
    }

    func setNextClueGiverIfNeeded() {
        // Check if we have a bonus time player who should go first
        if let bonusPlayer = bonusTimePlayer {
            clueGiver = bonusPlayer
            currentTeam = bonusPlayer.team
            return
        }
        
        // Pick next in team rotation; alternate teams each turn
        let order = (currentTeam == .A) ? teamAOrder : teamBOrder
        guard !order.isEmpty else {
            clueGiver = nil
            return
        }
        // Rotate using modulo of how many turns this team has taken so far
        let turnsForTeam = turnsTaken(for: currentTeam)
        let idx = turnsForTeam % order.count
        clueGiver = order[idx]
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
        guard !deck.isEmpty else {
            endRoundIfNeeded()
            return
        }
        thisTurnCorrect = []
        skipCount = 0
        skipLocked = false
        
        // Use bonus time if this player completed the previous round
        if let bonusPlayer = bonusTimePlayer, bonusPlayer.id == clueGiver?.id, savedBonusTime > 0 {
            timeRemaining = min(savedBonusTime, settings.timerSeconds)
            // Clear the bonus after using it
            savedBonusTime = 0
            bonusTimePlayer = nil
        } else {
            timeRemaining = settings.timerSeconds
        }
        
        initialDeckSize = deck.count
        cardShownAt = Date()
        turnActive = true
        stage = .turn
        
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
        settings.timerSeconds = pendingTimerSeconds
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
        // Original index is always 0 here (top of deck)
        let ev = CorrectEvent(card: current, originalIndex: 0, duration: d, highlighted: true)
        thisTurnCorrect.append(ev)
        
        // Track correct answer for the clue giver
        if let clueGiver = clueGiver {
            playerStats[clueGiver.id]?.addCorrectAnswer(duration: d)
        }

        Haptics.success()

        // Check for turn end conditions
        checkTurnEndConditions()
        
        // If turn is still active, show next card
        if turnActive {
            cardShownAt = Date()
        }
    }

    func skipCard() {
        guard turnActive, !deck.isEmpty else { return }
        guard currentRound != .one else { return } // disabled in round 1
        guard !skipLocked else {
            Haptics.warning()
            return
        }

        let card = deck.removeFirst()
        deck.append(card)
        skipCount += 1
        Haptics.tap()

        // Check for turn end conditions
        checkTurnEndConditions()

        // If turn is still active, reset show-time for duration tracking
        if turnActive {
            cardShownAt = Date()
        }
    }

    func finishTurnToRecap(reason: TurnEndReason = .manual) {
        // Turn stops; current top card (unfinished) stays and will resume next turn (bottom push on timeout per spec)
        // Spec: "Timer end: auto-opens Turn Recap; current card goes to bottom."
        // Only cycle the card if the timer ran out (player was stuck on it)
        if reason == .timerExpired && !deck.isEmpty {
            let top = deck.removeFirst()
            deck.append(top)
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

        // Store the reason and show notification for all turn ends except skip cycle complete
        lastTurnEndReason = reason
        if reason == .skipCycleComplete {
            stage = .recap
        } else {
            stage = .turnComplete
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
        // Handle untoggled cards - put them at bottom of deck and remove from score
        let untoggled = thisTurnCorrect.filter { !$0.highlighted }
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
            savedBonusTime = 0
            bonusTimePlayer = nil
        }
        
        // Clear this turn's events
        thisTurnCorrect.removeAll()
        
        // All corrects are already counted. Move to next team handoff or end round.
        if deck.isEmpty {
            endRoundIfNeeded()
            return
        }
        // Alternate to the other team for next turn
        currentTeam = (currentTeam == .A) ? .B : .A
        setNextClueGiverIfNeeded()
        stage = .turnHandoff
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
        switch currentRound {
        case .one:
            currentRound = .two
        case .two:
            currentRound = .three
        case .three:
            // End of game
            stage = .gameEnd
            return
        }
        // Reset deck (same cards), shuffle again
        resetDeckForRound()
        // Starting team alternates by round? Spec only says "Starting team" in settings; keep it fixed.
        currentTeam = settings.startingTeam
        setNextClueGiverIfNeeded()
        stage = .roundIntro
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
