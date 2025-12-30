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
    case packSelection, customPackBuilder
    case intakeHandoff, intakeName, intakePicks, intakeManualWords
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

// MARK: - Pack-Based Content System

enum Pack: String, Codable, CaseIterable, Hashable {
    case premadeStandard = "premade_standard"
    case premadeObscure = "premade_obscure"
    case premadeCustom = "premade_custom"
    
    var displayName: String {
        switch self {
        case .premadeStandard: return "Standard"
        case .premadeObscure: return "Obscure"
        case .premadeCustom: return "Custom"
        }
    }
    
    var description: String {
        switch self {
        case .premadeStandard: return "Familiar idioms, movies, food, and everyday phrases"
        case .premadeObscure: return "Science facts, internet culture, and mind-bending concepts"
        case .premadeCustom: return "Build your own pack with custom filters"
        }
    }
    
    var isCustom: Bool {
        return self == .premadeCustom
    }
}

enum Category: String, Codable, CaseIterable, Hashable {
    // Fun Discovery Categories
    case movies = "Movies & TV"
    case musicVibes = "Songs & Music Vibes"
    case internetCulture = "Internet & Meme Culture"
    case everydayThings = "Everyday Things"
    case scienceFun = "Science & Nature"
    case nerdy = "Nerdy Stuff"
    case nostalgia = "Throwback Vibes"
    case brands = "Brands & Products"
    case foodDrink = "Food & Flavors"
    case randomFun = "Random & Weird"
    case feelings = "Feelings & Experiences"
    case technology = "Tech & Gadgets"
    
    var displayName: String { rawValue }
}

struct CustomPackFilters: Codable {
    var categories: Set<Category>
    var obscurityRange: ClosedRange<Int> // 1-5
    var wordCountRange: ClosedRange<Int> // 1-10 words
    
    static let `default` = CustomPackFilters(
        categories: [.movies, .musicVibes, .brands],
        obscurityRange: 1...3,
        wordCountRange: 1...4
    )
}

// Pack filtering system - defines what content each pack includes
struct PackFilters {
    let categories: Set<Category>
    let obscurityRange: ClosedRange<Int>
    let wordCountRange: ClosedRange<Int>
    
    init(categories: Set<Category>, obscurity: ClosedRange<Int>, wordCount: ClosedRange<Int>) {
        self.categories = categories
        self.obscurityRange = obscurity
        self.wordCountRange = wordCount
    }
}

extension Pack {
    var filters: PackFilters {
        switch self {
        case .premadeStandard:
            return PackFilters(
                categories: [.movies, .musicVibes, .brands, .foodDrink, .everydayThings],
                obscurity: 1...3,
                wordCount: 1...4
            )
            
        case .premadeObscure:
            return PackFilters(
                categories: [.nerdy, .scienceFun, .randomFun, .internetCulture],
                obscurity: 3...5,
                wordCount: 2...6
            )

        case .premadeCustom:
            // This will use customPackFilters from Settings
            return PackFilters(categories: [], obscurity: 1...5, wordCount: 1...10)
        }
    }
}

// ClosedRange already conforms to Codable in Swift 5.5+

struct Settings: Codable {
    var players: Int
    var startingTeam: Team
    var timerSeconds: Int
    var wordPoolSizePerPlayer: Int
    var wordsPerPlayer: Int
    var manualWordsPerPlayer: Int
    var selectedPack: Pack
    var customPackFilters: CustomPackFilters // Used when selectedPack is .premadeCustom
    var acceptance: Acceptance
    var stats: StatsPref
}

extension Settings {
    var nonManualWordsPerPlayer: Int {
        max(0, wordsPerPlayer - manualWordsPerPlayer)
    }
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
    let categories: Set<Category>
    let packs: Set<Pack>
    let obscurity: Int // 1-5, where 5 is most obscure
    let wordCount: Int
    
    // Legacy field for backward compatibility - will be removed eventually
    let subject: String

    init(id: UUID = UUID(), title: String, categories: Set<Category>, packs: Set<Pack>, obscurity: Int, wordCount: Int? = nil, subject: String = "") {
        self.id = id
        self.title = title
        self.categories = categories
        self.packs = packs
        self.obscurity = obscurity
        self.wordCount = wordCount ?? title.split(separator: " ").count
        self.subject = subject.isEmpty ? categories.first?.displayName ?? "Unknown" : subject
    }
    
    // Legacy initializer for backward compatibility
    init(id: UUID = UUID(), title: String, subject: String) {
        self.id = id
        self.title = title
        self.subject = subject
        self.categories = []
        self.packs = []
        self.obscurity = 3
        self.wordCount = title.split(separator: " ").count
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
        wordPoolSizePerPlayer: 10,
        wordsPerPlayer: 3,
        manualWordsPerPlayer: 0,
        selectedPack: .premadeStandard,
        customPackFilters: .default,
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
