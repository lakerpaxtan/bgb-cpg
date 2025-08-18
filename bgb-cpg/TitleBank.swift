import Foundation

// Simple local "Wikipedia-ish" bank so the app runs offline.
// I kept titles clean; filters still apply (digits, "List of", etc.)
enum TitleBank {
    static let people: [String] = [
        "Ada Lovelace","Alan Turing","Marie Curie","Nelson Mandela","Leonardo da Vinci","Maya Angelou","Serena Williams","Albert Einstein","Taylor Swift","Keanu Reeves","David Attenborough","Kobe Bryant","Frida Kahlo","Amelia Earhart","Nikola Tesla","Tony Hawk","Quentin Tarantino"
    ]

    static let places: [String] = [
        "Grand Canyon","Machu Picchu","Great Barrier Reef","Mount Everest","Yosemite National Park","Banff National Park","Niagara Falls","Taj Mahal","Swiss Alps","Iguazu Falls","Lake Como","Amalfi Coast"
    ]

    static let filmTV: [String] = [
        "The Matrix","The Godfather","The Dark Knight","Spirited Away","The Office","Breaking Bad","Game of Thrones","Stranger Things","The Lion King","Pulp Fiction","Forrest Gump","The Mandalorian","Black Panther","The Crown","Jurassic Park","Toy Story","The Avengers","The Simpsons"
    ]

    static let music: [String] = [
        "Bohemian Rhapsody","Stairway to Heaven","Hotel California","Rolling in the Deep","Hey Jude","Smells Like Teen Spirit","Like a Rolling Stone","Shake It Off","Purple Rain","Uptown Funk","Mr Brightside","Lose Yourself","All Star","Viva La Vida","Old Town Road","Blinding Lights","Born to Run","Back in Black"
    ]

    static let sports: [String] = [
        "Super Bowl","World Cup","Tour de France","NBA Finals","Stanley Cup","Olympic Games","Formula One","The Masters","US Open","Rugby World Cup","Cricket World Cup","Boston Marathon","Champions League","Premier League","World Series"
    ]

    static let scienceTech: [String] = [
        "Artificial Intelligence","Machine Learning","Quantum Computing","Theory of Relativity","Internet of Things","Electric Vehicle","Solar Power","Wind Energy","DNA Sequencing","Mars Rover","James Webb Space Telescope","Black Hole","General Relativity","Open Source Software","Cloud Computing","Neural Network","Large Hadron Collider","Operating System","Web Browser","Search Engine","Virtual Reality","Augmented Reality"
    ]

    static let history: [String] = [
        "French Revolution","Industrial Revolution","World War I","World War II","Cold War","Silk Road","Roman Empire","Magna Carta","American Revolution","Civil Rights Movement","Great Depression","Printing Press","Berlin Wall","Cuban Missile Crisis","Apollo 11","Age of Exploration","Boston Tea Party","Suffrage Movement"
    ]

    static let foodDrink: [String] = [
        "Neapolitan Pizza","Pad Thai","Dim Sum","Apple Pie","Chocolate Cake","Fish and Chips","Boba Tea"
    ]

    static func pool(for subject: String) -> [String] {
        switch subject.lowercased() {
        case "people": return people
        case "places": return places
        case "film/tv", "filmtv": return filmTV
        case "music": return music
        case "sports": return sports
        case "science/tech", "sciencetech": return scienceTech
        case "history": return history
        case "food/drink", "fooddrink": return foodDrink
        case "everything":
            return people + places + filmTV + music + sports + scienceTech + history + foodDrink
        default:
            return people + places + filmTV + music + sports + scienceTech + history + foodDrink
        }
    }
}

