import Foundation

// Simple local "Wikipedia-ish" bank so the app runs offline.
// I kept titles clean; filters still apply (digits, "List of", etc.)
enum TitleBank {
    static let people: [String] = [
        "Ada Lovelace","Alan Turing","Marie Curie","Nelson Mandela","Leonardo da Vinci","Maya Angelou","Serena Williams","Usain Bolt","Greta Thunberg","Malala Yousafzai","Albert Einstein","Beyoncé","Taylor Swift","Keanu Reeves","David Attenborough","Hayao Miyazaki","Rihanna","Kobe Bryant","Frida Kahlo","Socrates","Satoshi Nakamoto","Amelia Earhart","Nikola Tesla","Chadwick Boseman","Tony Hawk","Zaha Hadid","Spike Lee","Quentin Tarantino"
    ]

    static let places: [String] = [
        "Grand Canyon","Machu Picchu","Great Barrier Reef","Mount Everest","Yosemite National Park","Banff National Park","Iceland","Kyoto","Petra","Angkor Wat","Serengeti","Sahara Desert","Niagara Falls","Santorini","Taj Mahal","Uluru","Yellowstone","Bora Bora","Venice","Cappadocia","Cinque Terre","Zermatt","Swiss Alps","Iguazu Falls","Lake Como","Amalfi Coast","Patagonia","Istanbul"
    ]

    static let filmTV: [String] = [
        "The Matrix","Inception","The Godfather","The Dark Knight","Parasite","Spirited Away","Interstellar","The Office","Breaking Bad","Game of Thrones","Stranger Things","Coco","The Lion King","Pulp Fiction","Forrest Gump","The Mandalorian","Black Panther","The Crown","Jurassic Park","Toy Story","The Avengers","Shrek","The Simpsons","Seinfeld","Mad Max","Arrival","Whiplash","Amélie"
    ]

    static let music: [String] = [
        "Bohemian Rhapsody","Stairway to Heaven","Thriller","Hotel California","Rolling in the Deep","Hey Jude","Smells Like Teen Spirit","Like a Rolling Stone","Shake It Off","Hallelujah","Purple Rain","Imagine","Bad Guy","Uptown Funk","Despacito","Mr Brightside","Lose Yourself","All Star","Viva La Vida","Old Town Road","Blinding Lights","Born to Run","Yesterday","Wonderwall","Numb","Chandelier","Back in Black","Levitating"
    ]

    static let sports: [String] = [
        "Super Bowl","World Cup","Wimbledon","Tour de France","NBA Finals","Stanley Cup","Olympic Games","Formula One","The Masters","US Open","Rugby World Cup","Cricket World Cup","Boston Marathon","Ironman Triathlon","X Games","Champions League","La Liga","Premier League","FIFA Ballon d'Or","The Ashes","Ryder Cup","Indy 500","Daytona 500","UEFA Euro","Copa América","World Series","NHL Draft","Draft Combine"
    ]

    static let scienceTech: [String] = [
        "Artificial Intelligence","Machine Learning","Quantum Computing","Theory of Relativity","Higgs Boson","CRISPR","Blockchain","Internet of Things","Electric Vehicle","Solar Power","Wind Energy","Vaccination","DNA Sequencing","Mars Rover","James Webb Space Telescope","Black Hole","General Relativity","Microprocessor","Open Source Software","Cloud Computing","Neural Network","Large Hadron Collider","Operating System","Web Browser","Search Engine","Virtual Reality","Augmented Reality","3D Printing"
    ]

    static let history: [String] = [
        "French Revolution","Renaissance","Industrial Revolution","World War I","World War II","Cold War","Silk Road","Roman Empire","Ming Dynasty","Magna Carta","American Revolution","Civil Rights Movement","Great Depression","Printing Press","Stonehenge","Berlin Wall","Cuban Missile Crisis","Apollo 11","Age of Exploration","Spice Trade","Hammurabi Code","Gutenberg Bible","Meiji Restoration","Fall of Constantinople","Battle of Waterloo","Boston Tea Party","Trail of Tears","Suffrage Movement"
    ]

    static let foodDrink: [String] = [
        "Neapolitan Pizza","Sushi","Ramen","Pho","Tacos","Pad Thai","Croissant","Kouign Amann","Gelato","Paella","Dim Sum","Bibimbap","Kebab","Hummus","Falafel","Ceviche","Burrito","Poutine","Apple Pie","Chocolate Cake","Cheeseburger","Fish and Chips","Espresso","Cappuccino","Matcha","Boba Tea","Kimchi","Curry"
    ]

    static func pool(for subject: Subject) -> [String] {
        switch subject {
        case .people: return people
        case .places: return places
        case .filmTV: return filmTV
        case .music: return music
        case .sports: return sports
        case .scienceTech: return scienceTech
        case .history: return history
        case .foodDrink: return foodDrink
        case .everything:
            return people + places + filmTV + music + sports + scienceTech + history + foodDrink
        }
    }
}

// Basic filters from settings spec
enum TitleFilter {
    static func isValid(_ title: String, filters: Filters) -> Bool {
        if filters.blockNSFW {
            // Bank is already clean.
        }
        if filters.excludeYearsDates, title.rangeOfCharacter(from: .decimalDigits) != nil {
            return false
        }
        if filters.excludeDisambiguation {
            if title.lowercased().contains("(disambiguation)") { return false }
        }
        if filters.excludeListsCategories {
            let low = title.lowercased()
            if low.hasPrefix("list of") || low.hasPrefix("category:") { return false }
        }
        return true
    }
}
