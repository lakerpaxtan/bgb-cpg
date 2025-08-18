import Foundation
import SwiftUI

@MainActor
class WikipediaService: ObservableObject {
    
    @Published var status: ContentSourceStatus = .unknown
    @Published var availableCategories: [WikipediaCategory] = []
    
    private let baseURL = "https://en.wikipedia.org/w/api.php"
    
    private var session: URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 8.0 // 8 second timeout
        config.timeoutIntervalForResource = 15.0 // 15 second total timeout
        return URLSession(configuration: config)
    }
    
    // MARK: - Status Checking
    
    func checkAvailability() async {
        // Don't re-check if we already have categories loaded
        if status == .available && !availableCategories.isEmpty {
            return
        }
        
        status = .checking
        
        do {
            // Test with a simple API call to verify Wikipedia is reachable
            let testURL = URL(string: "\(baseURL)?action=query&meta=siteinfo&format=json")!
            let (data, response) = try await session.data(from: testURL)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                // Verify we actually got JSON back
                _ = try JSONSerialization.jsonObject(with: data)
                await loadAvailableCategories()
                // Only set as available if we actually loaded categories
                if !availableCategories.isEmpty {
                    status = .available
                } else {
                    status = .unavailable(WikipediaError.noResults)
                }
            } else {
                status = .unavailable(WikipediaError.networkError)
            }
        } catch let error as URLError {
            switch error.code {
            case .timedOut:
                status = .unavailable(WikipediaError.timeout)
            case .notConnectedToInternet:
                status = .unavailable(WikipediaError.noInternet)
            default:
                status = .unavailable(WikipediaError.networkError)
            }
        } catch {
            status = .unavailable(error)
        }
    }
    
    // MARK: - Category Discovery
    
    private func loadAvailableCategories() async {
        do {
            let url = URL(string: "\(baseURL)?action=query&list=categorymembers&cmtitle=Category:Main_topic_classifications&cmtype=subcat&cmlimit=50&format=json")!
            let (data, _) = try await session.data(from: url)
            let response = try JSONDecoder().decode(WikipediaResponse.self, from: data)
            
            // Convert category members to WikipediaCategory objects, filtering out meta categories
            availableCategories = response.query.categorymembers.compactMap { member in
                // Convert "Category:Culture" to "Culture" for display
                let displayTitle = member.title.replacingOccurrences(of: "Category:", with: "")
                
                // Filter out meta/administrative categories
                let lowercaseTitle = displayTitle.lowercased()
                if lowercaseTitle.contains("main topic") ||
                   lowercaseTitle.contains("article") ||
                   lowercaseTitle.contains("portal") ||
                   lowercaseTitle.contains("wikipedia") ||
                   lowercaseTitle.contains("template") {
                    return nil // Skip this category
                }
                
                // Convert spaces to underscores for API calls
                let categoryId = displayTitle.replacingOccurrences(of: " ", with: "_")
                return WikipediaCategory(id: categoryId, title: displayTitle)
            }
            
            print("Loaded \(availableCategories.count) Wikipedia categories")
        } catch {
            print("Failed to load Wikipedia categories: \(error)")
            // Fallback to empty list - will show error in UI
            availableCategories = []
        }
    }
    
    // MARK: - Title Fetching
    
    func fetchTitles(filters: WikipediaFilters, count: Int) async throws -> [Card] {
        // Handle empty categories selection
        guard !filters.categories.isEmpty else {
            throw WikipediaError.noResults
        }
        
        var allTitles: [Card] = []
        // Fetch more articles per category to ensure we have enough variety
        // Get at least the requested count from each category, with a reasonable minimum
        let titlesPerCategory = max(count, 100) // At least 100 articles per category
        
        for category in filters.categories {
            let categoryTitles = try await fetchTitlesFromCategory(
                category: category,
                count: titlesPerCategory,
                filters: filters
            )
            allTitles.append(contentsOf: categoryTitles)
        }
        
        // Shuffle and return requested count from the combined pool
        return Array(allTitles.shuffled().prefix(count))
    }
    
    private func fetchTitlesFromCategory(
        category: WikipediaCategory,
        count: Int,
        filters: WikipediaFilters
    ) async throws -> [Card] {
        
        // Get random articles from this category - fetch more to have a good pool
        let urlString = "\(baseURL)?action=query&list=categorymembers&cmtitle=Category:\(category.categoryName)&cmtype=page&cmlimit=500&format=json"
        
        guard let url = URL(string: urlString) else {
            throw WikipediaError.invalidURL
        }

        print("🌐 Fetching Wikipedia using URL: \(urlString)")
        
        let (data, _) = try await session.data(from: url)
        let response = try JSONDecoder().decode(WikipediaResponse.self, from: data)
        
        var cards: [Card] = []
        
        for member in response.query.categorymembers {
            let title = member.title
            
            // Filter out Wikipedia internal pages
            if title.contains(":") {
                // Skip Wikipedia:, Portal:, Template:, Category:, File:, etc.
                continue
            }
            
            // Filter by word count
            let wordCount = title.split(separator: " ").count
            guard filters.wordLimit.contains(wordCount) else { continue }
            
            // Filter out obvious list/meta pages
            let lowercaseTitle = title.lowercased()
            if lowercaseTitle.hasPrefix("list of") || 
               lowercaseTitle.hasPrefix("lists of") ||
               lowercaseTitle.contains("disambiguation") ||
               lowercaseTitle.contains("(disambiguation)") {
                continue
            }
            
            // TODO: Add popularity, creation date, and update date filtering
            // This would require additional API calls to get page metadata
            
            let subject = category.title // Use Wikipedia category name directly
            cards.append(Card(title: title, subject: subject))
            
            if cards.count >= count { break }
        }
        
        return cards
    }
    
}

// MARK: - API Models

struct WikipediaResponse: Codable {
    let query: WikipediaQuery
}

struct WikipediaQuery: Codable {
    let categorymembers: [WikipediaCategoryMember]
}

struct WikipediaCategoryMember: Codable {
    let title: String
    let pageid: Int
}

// MARK: - Errors

enum WikipediaError: LocalizedError {
    case networkError
    case timeout
    case noInternet
    case invalidURL
    case decodingError
    case noResults
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Unable to connect to Wikipedia"
        case .timeout:
            return "Wikipedia request timed out"
        case .noInternet:
            return "No internet connection"
        case .invalidURL:
            return "Invalid Wikipedia URL"
        case .decodingError:
            return "Unable to parse Wikipedia response"
        case .noResults:
            return "No articles found matching your filters"
        }
    }
}