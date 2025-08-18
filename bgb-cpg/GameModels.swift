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
    case roundIntro, turnHandoff, turn, turnPaused, turnSkipComplete, turnComplete, recap, roundEnd, gameEnd, gameStats
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
        case .two, .three: return "Skips: Allowed until you cycle through all cards."
        }
    }
}

struct Filters: Codable {
    var subjects: Set<Subject>
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


struct StatsPref: Codable {
    var showBetweenRounds: Bool
    var highlightsPerRound: Int
}

// MARK: - Content Sources

enum ContentSource: String, Codable, CaseIterable {
    case offline = "Offline"
    case wikipedia = "Wikipedia"
    
    var displayName: String { rawValue }
}

enum ContentSourceStatus: Equatable {
    case unknown
    case checking
    case available
    case unavailable(Error)
    
    static func == (lhs: ContentSourceStatus, rhs: ContentSourceStatus) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown), (.checking, .checking), (.available, .available):
            return true
        case (.unavailable(let lhsError), .unavailable(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

// Dynamic Wikipedia category fetched from API
struct WikipediaCategory: Codable, Hashable, Identifiable {
    let id: String // The category name with underscores
    let title: String // Display name
    
    var displayName: String { title }
    var categoryName: String { id }
    
    init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}

struct WikipediaFilters: Codable {
    var categories: Set<WikipediaCategory>
    var wordLimit: ClosedRange<Int>
    var popularityPercentile: ClosedRange<Int> // 0=obscure, 100=viral
    var createdYears: ClosedRange<Int>
    var updatedYears: ClosedRange<Int>
    
    static let `default` = WikipediaFilters(
        categories: Set(), // Will be populated when categories are loaded
        wordLimit: 1...5,
        popularityPercentile: 20...80,
        createdYears: 2001...2025,
        updatedYears: 2020...2025
    )
}

// ClosedRange already conforms to Codable in Swift 5.5+


struct Settings: Codable {
    var players: Int
    var startingTeam: Team
    var timerSeconds: Int
    var titlesPerPlayer: Int
    var picksPerPlayer: Int
    var contentSource: ContentSource
    var filters: Filters // For offline mode
    var wikipediaFilters: WikipediaFilters // For Wikipedia mode
    var acceptance: Acceptance
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
    let subject: String // Now using String instead of Subject enum

    init(id: UUID = UUID(), title: String, subject: String) {
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
        contentSource: .offline,
        filters: Filters(
            subjects: [.everything]
//            excludeYearsDates: true,
//            excludeDisambiguation: true,
//            excludeListsCategories: true,
//            blockNSFW: true
        ),
        wikipediaFilters: .default,
        acceptance: Acceptance(
            ignoreLeadingArticle: true,
            leadingArticles: ["the","a","an"],
            requireAllOtherTokens: true,
            pluralizationStrict: true,
            caseInsensitive: true,
            ignorePunctuation: true
        ),
        stats: StatsPref(showBetweenRounds: true, highlightsPerRound: 3)
    )
}
