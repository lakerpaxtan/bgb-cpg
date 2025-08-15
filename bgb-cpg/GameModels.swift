import Foundation
import SwiftUI

// MARK: - Core Enums / Models

enum Team: String, Codable, CaseIterable {
    case A, B

    var name: String { "Team \(rawValue)" }
    var color: Color {
        switch self {
        case .A: return Color.blue
        case .B: return Color.pink
        }
    }
}

enum Stage {
    case home, howTo, settings
    case intakeHandoff, intakeName, intakePicks
    case roundIntro, turnHandoff, primer, turnReady, turn, turnPaused, recap, roundEnd, gameEnd, gameStats
}

enum RoundPhase: Int, Codable {
    case one = 1, two = 2, three = 3

    var title: String {
        switch self {
        case .one: return "Round 1 — Describe"
        case .two: return "Round 2 — One Word"
        case .three: return "Round 3 — Charades"
        }
    }

    var rules: String {
        switch self {
        case .one:
            return "Say anything except any part of the title. No spelling, initials, translations, or rhymes. Gestures ok."
        case .two:
            return "Say one word only. Gestures ok."
        case .three:
            return "No words. Gestures & non-verbal sounds ok."
        }
    }

    var skipPolicy: String {
        switch self {
        case .one: return "Skips: Not allowed."
        case .two, .three: return "Skips: Allowed until you return to your starting card, then off."
        }
    }
}

struct Filters: Codable {
    var subjects: Set<Subject>
    var excludeYearsDates: Bool
    var excludeDisambiguation: Bool
    var excludeListsCategories: Bool
    var blockNSFW: Bool
}

enum Subject: String, Codable, CaseIterable, Hashable {
    case people = "People"
    case places = "Places"
    case filmTV = "Film/TV"
    case music = "Music"
    case sports = "Sports"
    case scienceTech = "Science/Tech"
    case history = "History"
    case foodDrink = "Food/Drink"
    case everything = "Everything"
}

struct Acceptance: Codable {
    var ignoreLeadingArticle: Bool
    var leadingArticles: [String]
    var requireAllOtherTokens: Bool
    var pluralizationStrict: Bool
    var caseInsensitive: Bool
    var ignorePunctuation: Bool
}

struct SkipsRule: Codable {
    var round1: SkipMode
    var round2: SkipMode
    var round3: SkipMode

    enum SkipMode: String, Codable {
        case disabled
        case unlimited_until_return_to_start_card
    }
}

struct StatsPref: Codable {
    var showBetweenRounds: Bool
    var highlightsPerRound: Int
}

struct Settings: Codable {
    var players: Int
    var startingTeam: Team
    var timerSeconds: Int
    var titlesPerPlayer: Int
    var picksPerPlayer: Int
    var filters: Filters
    var acceptance: Acceptance
    var skips: SkipsRule
    var stats: StatsPref
}

// Player
struct Player: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var team: Team

    init(id: UUID = UUID(), name: String, team: Team) {
        self.id = id
        self.name = name
        self.team = team
    }
}

// Player Statistics
struct PlayerStats: Identifiable, Codable {
    let id: UUID // matches Player.id
    var totalCorrectAnswers: Int = 0
    var totalTurnTime: TimeInterval = 0
    var turnsAsClueGiver: Int = 0
    var fastestAnswer: TimeInterval? = nil
    var slowestAnswer: TimeInterval? = nil
    var averageAnswerTime: TimeInterval { 
        totalCorrectAnswers > 0 ? totalTurnTime / TimeInterval(totalCorrectAnswers) : 0
    }
    
    init(playerId: UUID) {
        self.id = playerId
    }
    
    mutating func addCorrectAnswer(duration: TimeInterval) {
        totalCorrectAnswers += 1
        totalTurnTime += duration
        
        if let current = fastestAnswer {
            fastestAnswer = min(current, duration)
        } else {
            fastestAnswer = duration
        }
        
        if let current = slowestAnswer {
            slowestAnswer = max(current, duration)
        } else {
            slowestAnswer = duration
        }
    }
    
    mutating func addTurn() {
        turnsAsClueGiver += 1
    }
}

// Card
struct Card: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let subject: Subject

    init(id: UUID = UUID(), title: String, subject: Subject) {
        self.id = id
        self.title = title
        self.subject = subject
    }
}

struct Token: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let required: Bool
}

// A correct answer during a turn
struct CorrectEvent: Identifiable {
    let id = UUID()
    let card: Card
    let originalIndex: Int // where it sat in deck when answered
    let duration: TimeInterval // seconds from showing to marking correct
    var highlighted: Bool = true // for read-aloud highlight toggle
}

// Score snapshot
struct RoundScore {
    var teamA: Int = 0
    var teamB: Int = 0
    var total: Int { teamA + teamB }
}

// MARK: - Defaults

extension Settings {
    static let `default` = Settings(
        players: 8,
        startingTeam: .A,
        timerSeconds: 60,
        titlesPerPlayer: 10,
        picksPerPlayer: 3,
        filters: Filters(
            subjects: [.everything],
            excludeYearsDates: true,
            excludeDisambiguation: true,
            excludeListsCategories: true,
            blockNSFW: true
        ),
        acceptance: Acceptance(
            ignoreLeadingArticle: true,
            leadingArticles: ["the","a","an"],
            requireAllOtherTokens: true,
            pluralizationStrict: true,
            caseInsensitive: true,
            ignorePunctuation: true
        ),
        skips: SkipsRule(
            round1: .disabled,
            round2: .unlimited_until_return_to_start_card,
            round3: .unlimited_until_return_to_start_card
        ),
        stats: StatsPref(showBetweenRounds: true, highlightsPerRound: 3)
    )
}
