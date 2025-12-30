import Foundation

// Fun-focused title bank emphasizing collaborative discovery over trivia knowledge
struct TitleBank {
    
    struct TitleEntry {
        let title: String
        let categories: Set<Category>
        let packs: Set<Pack>
        let obscurity: Int // 1-5, where 5 is most obscure
        
        init(_ title: String, categories: Set<Category>, packs: Set<Pack>, obscurity: Int) {
            self.title = title
            self.categories = categories
            self.packs = packs
            self.obscurity = obscurity
        }
    }
    
    // MARK: - All Titles Database - Fun Discovery Focus
    // Rules respected:
    // - Real phrases/titles/terms only (no made-up “situations”)
    // - No new categories or packs; uses existing Category & Pack enums
    // - Bias toward multi-word entries; sprinkle a few short/one-word where useful
    // - Keep premadeStandard (1–4 words, obscurity 1–3) approachable
    // - Keep premadeObscure (2–6 words, obscurity 3–5) delightfully discoverable
    static let allTitles: [TitleEntry] = [
        // ===== IDIOMS & SAYINGS (STANDARD) =====
        TitleEntry("Beating around the bush", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Elephant in the room", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Spill the beans", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Break the ice", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Bite the bullet", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Low-hanging fruit", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Hold your horses", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Cut to the chase", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("On the same page", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Raining cats and dogs", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Under the weather", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Burn the midnight oil", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Back to square one", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Throw in the towel", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("The last straw", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Silver lining", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("In hot water", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("On thin ice", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Out of the blue", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Piece of cake", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Rule of thumb", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Blessing in disguise", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Break a leg", categories: [.everydayThings, .musicVibes], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Cold turkey", categories: [.everydayThings, .foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Red herring", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("White elephant", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Wild goose chase", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Loose cannon", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Smoking gun", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Swan song", categories: [.everydayThings, .musicVibes], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Pyrrhic victory", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Trojan horse", categories: [.everydayThings, .technology], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Achilles heel", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Gordian knot", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Rosetta Stone", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Pandora's box", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Double-edged sword", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Rabbit hole", categories: [.everydayThings, .internetCulture], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Tip of the iceberg", categories: [.everydayThings, .scienceFun], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Glass ceiling", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Butterflies in stomach", categories: [.everydayThings, .feelings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Tipping point", categories: [.everydayThings, .randomFun], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Learning curve", categories: [.everydayThings, .nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Rain check", categories: [.everydayThings], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Bucket list", categories: [.everydayThings], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Comfort zone", categories: [.everydayThings, .feelings], packs: [.premadeStandard], obscurity: 1),

        // ===== SCIENCE & FUN FACTS (OBSCURE) =====
        TitleEntry("Powerhouse of the cell", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Schrödinger's cat", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Quantum leap", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Black hole", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Event horizon", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Big Bang", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Occam's razor", categories: [.scienceFun, .randomFun], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Doppler effect", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Pavlov's dog", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Fermi paradox", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Uncanny valley", categories: [.scienceFun, .randomFun], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Chaos theory", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Golden ratio", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Fibonacci sequence", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Periodic table", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Newton's cradle", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Chain reaction", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Greenhouse effect", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Natural selection", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Survival of the fittest", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Plate tectonics", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Solar eclipse", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Northern Lights", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Speed of light", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Dark matter", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Dark energy", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Quantum entanglement", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 5),
        TitleEntry("Turing test", categories: [.scienceFun, .technology], packs: [.premadeObscure], obscurity: 4),

        // ===== INTERNET CULTURE (OBSCURE) =====
        TitleEntry("This Is Fine", categories: [.internetCulture], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Rickroll prank", categories: [.internetCulture, .musicVibes], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("All your base", categories: [.internetCulture, .nerdy], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Keyboard Cat", categories: [.internetCulture], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Nyan Cat", categories: [.internetCulture], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Distracted Boyfriend", categories: [.internetCulture], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Ice Bucket Challenge", categories: [.internetCulture], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Harlem Shake", categories: [.internetCulture], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Double Rainbow", categories: [.internetCulture], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Mannequin Challenge", categories: [.internetCulture], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Gangnam Style", categories: [.internetCulture, .musicVibes], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Cinnamon Challenge", categories: [.internetCulture, .foodDrink], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Planking challenge", categories: [.internetCulture], packs: [.premadeObscure], obscurity: 3),

        // ===== EVERYDAY THINGS (STANDARD) =====
        TitleEntry("Rubik's Cube", categories: [.everydayThings, .nerdy], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Swiss Army Knife", categories: [.everydayThings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Sticky note", categories: [.everydayThings], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Paper clip", categories: [.everydayThings], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Ziplock bag", categories: [.everydayThings, .brands], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Velcro strap", categories: [.everydayThings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Duct tape", categories: [.everydayThings], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Bubble wrap", categories: [.everydayThings], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Shopping cart", categories: [.everydayThings], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Kitchen timer", categories: [.everydayThings], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("French press", categories: [.everydayThings, .foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Ice tray", categories: [.everydayThings], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Tooth fairy", categories: [.everydayThings, .nostalgia], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Wishing well", categories: [.everydayThings, .nostalgia], packs: [.premadeStandard], obscurity: 2),

        // ===== FOOD & DRINK (STANDARD) =====
        TitleEntry("Chicken and waffles", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Cold brew coffee", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Spaghetti carbonara", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Garlic bread", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Avocado toast", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Buffalo wings", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Neapolitan pizza", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("California burrito", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Boba tea", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Sushi burrito", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Ramen burger", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Sourdough starter", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Charcuterie board", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Cheese fondue", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("French toast", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Eggs Benedict", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Chocolate lava cake", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Classic tiramisu", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Mango sticky rice", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Chicken tikka masala", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Green curry", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Pad thai", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Peking duck", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Xiao long bao", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Soup dumplings", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Ube ice cream", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Mochi donuts", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Churro sundae", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 2),

        // ===== MUSIC VIBES (STANDARD) =====
        TitleEntry("Power ballad", categories: [.musicVibes], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Shower karaoke", categories: [.musicVibes], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Air guitar", categories: [.musicVibes], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Road trip playlist", categories: [.musicVibes], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Jazz hands", categories: [.musicVibes], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Bohemian Rhapsody", categories: [.musicVibes], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Stairway to Heaven", categories: [.musicVibes], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Free Bird", categories: [.musicVibes], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Sweet Caroline", categories: [.musicVibes], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Dancing Queen", categories: [.musicVibes], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Never Gonna Give You Up", categories: [.internetCulture, .musicVibes], packs: [.premadeObscure], obscurity: 3),

        // ===== MOVIES & TV (STANDARD) =====
        TitleEntry("The Matrix", categories: [.movies], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Jurassic Park", categories: [.movies], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Back to the Future", categories: [.movies], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("The Princess Bride", categories: [.movies], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Mean Girls", categories: [.movies], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Spirited Away", categories: [.movies], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("My Neighbor Totoro", categories: [.movies], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("The Lord of the Rings", categories: [.movies], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("The Mandalorian", categories: [.movies], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Breaking Bad", categories: [.movies], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Better Call Saul", categories: [.movies], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Game of Thrones", categories: [.movies], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Parks and Recreation", categories: [.movies], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("The Office", categories: [.movies], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Stranger Things", categories: [.movies], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Squid Game", categories: [.movies, .internetCulture], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Avatar: The Last Airbender", categories: [.movies, .nostalgia], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Studio Ghibli", categories: [.movies, .nostalgia], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Marvel Cinematic Universe", categories: [.movies], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Disney Channel", categories: [.movies, .brands], packs: [.premadeStandard], obscurity: 2),

        // ===== GAMES & NERDY (MIXED) =====
        TitleEntry("The Legend of Zelda", categories: [.nerdy, .nostalgia], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Mario Kart", categories: [.nerdy], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Super Smash Bros", categories: [.nerdy], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Tetris Effect", categories: [.nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Pac-Man", categories: [.nerdy], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Donkey Kong", categories: [.nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Final Fantasy VII", categories: [.nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Elden Ring", categories: [.nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Fortnite Battle Royale", categories: [.nerdy, .internetCulture], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Minecraft", categories: [.nerdy], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Among Us", categories: [.nerdy, .internetCulture], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Stardew Valley", categories: [.nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Konami Code", categories: [.nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Red shell", categories: [.nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Warp pipe", categories: [.nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Side quest", categories: [.nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Boss battle", categories: [.nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Save point", categories: [.nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Final boss", categories: [.nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Speed run", categories: [.nerdy], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Cheat code", categories: [.nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Game over", categories: [.nerdy], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Invisible wall", categories: [.nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Secret level", categories: [.nerdy], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Double jump", categories: [.nerdy], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("New game plus", categories: [.nerdy], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Inventory management", categories: [.nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Dialogue tree", categories: [.nerdy], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Skill tree", categories: [.nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Open world", categories: [.nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Sandbox mode", categories: [.nerdy], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Permadeath run", categories: [.nerdy], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("RNG loot", categories: [.nerdy], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Patch notes", categories: [.nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Day one patch", categories: [.nerdy], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Loot box", categories: [.nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Battle royale", categories: [.nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Crafting bench", categories: [.nerdy], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Friendly fire", categories: [.nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Sudden death", categories: [.nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Blue shell", categories: [.nerdy], packs: [.premadeStandard], obscurity: 2),

        // ===== TECH & GADGETS (STANDARD) =====
        TitleEntry("Blue Screen of Death", categories: [.technology, .everydayThings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("404 Not Found", categories: [.technology, .everydayThings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Two-factor authentication", categories: [.technology, .brands], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Airplane mode", categories: [.technology, .everydayThings], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Dark mode", categories: [.technology, .everydayThings], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Incognito mode", categories: [.technology, .everydayThings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("QR code", categories: [.technology, .everydayThings], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("CAPTCHA test", categories: [.technology, .everydayThings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Infinite scroll", categories: [.technology, .internetCulture], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Algorithmic feed", categories: [.technology, .internetCulture], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Push notification", categories: [.technology, .everydayThings], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Tap to pay", categories: [.technology, .brands], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Wireless charging", categories: [.technology, .everydayThings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Augmented reality", categories: [.technology, .nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Virtual reality", categories: [.technology, .nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Noise-cancelling headphones", categories: [.technology, .everydayThings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Smart home", categories: [.technology, .everydayThings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Cloud storage", categories: [.technology, .everydayThings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("USB-C cable", categories: [.technology, .everydayThings], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Bluetooth pairing", categories: [.technology, .everydayThings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Battery saver", categories: [.technology, .everydayThings], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Software update", categories: [.technology, .everydayThings], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Version control", categories: [.technology, .nerdy], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Merge conflict", categories: [.technology, .nerdy], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Rubber duck debugging", categories: [.technology, .nerdy], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Off-by-one error", categories: [.technology, .nerdy], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Hello World", categories: [.technology, .nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Segmentation fault", categories: [.technology, .nerdy], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Null pointer exception", categories: [.technology, .nerdy], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Stack overflow", categories: [.technology, .nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Memory leak", categories: [.technology, .nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Garbage collection", categories: [.technology, .nerdy], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Easter egg", categories: [.technology, .nerdy], packs: [.premadeStandard], obscurity: 2),

        // ===== NOSTALGIA (STANDARD) =====
        TitleEntry("Saturday morning cartoons", categories: [.nostalgia, .movies], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Dial-up internet", categories: [.nostalgia, .technology], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Floppy disk", categories: [.nostalgia, .technology], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Burn a CD", categories: [.nostalgia, .musicVibes], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Mixtape", categories: [.nostalgia, .musicVibes], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Myspace Top 8", categories: [.nostalgia, .internetCulture], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("AIM away message", categories: [.nostalgia, .internetCulture], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("T9 texting", categories: [.nostalgia, .technology], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("VCR tracking", categories: [.nostalgia, .technology], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Be kind rewind", categories: [.nostalgia, .movies], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Landline phone", categories: [.nostalgia, .everydayThings], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Polaroid camera", categories: [.nostalgia, .everydayThings], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Disposable camera", categories: [.nostalgia, .everydayThings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Walkman cassette", categories: [.nostalgia, .musicVibes], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Game Boy Color", categories: [.nostalgia, .nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Tamagotchi pet", categories: [.nostalgia, .nerdy], packs: [.premadeStandard], obscurity: 3),

        // ===== RANDOM FUN / THOUGHT STUFF (OBSCURE) =====
        TitleEntry("Trolley problem", categories: [.randomFun], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Ship of Theseus", categories: [.randomFun], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Infinite monkey theorem", categories: [.randomFun], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Murphy's law", categories: [.randomFun], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Birthday paradox", categories: [.randomFun], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Monty Hall problem", categories: [.randomFun], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Mandela effect", categories: [.randomFun], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Freudian slip", categories: [.randomFun], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Deja vu", categories: [.randomFun], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Placebo effect", categories: [.randomFun], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Sunk cost fallacy", categories: [.randomFun], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Hedonic treadmill", categories: [.randomFun], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Imposter syndrome", categories: [.randomFun, .feelings], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Wisdom of crowds", categories: [.randomFun], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Prisoner's dilemma", categories: [.randomFun], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Bystander effect", categories: [.randomFun], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Confirmation bias", categories: [.randomFun], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Dunning-Kruger effect", categories: [.randomFun], packs: [.premadeObscure], obscurity: 4),

        // ===== BRANDS & PRODUCTS (STANDARD) =====
        TitleEntry("IKEA instructions", categories: [.brands, .everydayThings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Google Maps", categories: [.brands, .technology], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Apple Pay", categories: [.brands, .technology], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Amazon Prime", categories: [.brands, .internetCulture], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Netflix Originals", categories: [.brands, .movies], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Target run", categories: [.brands, .everydayThings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Costco samples", categories: [.brands, .foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("YouTube ads", categories: [.brands, .internetCulture], packs: [.premadeStandard], obscurity: 1),

        // ===== SHORT, KNOWN CATCHES (MIXED) =====
        TitleEntry("Catch-22", categories: [.randomFun], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Butterfly effect", categories: [.randomFun, .scienceFun], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Occam's razor", categories: [.randomFun, .scienceFun], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Glass half full", categories: [.everydayThings, .feelings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Safety blanket", categories: [.everydayThings, .feelings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Third wheel", categories: [.everydayThings, .feelings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Golden hour", categories: [.everydayThings, .movies], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Plot armor", categories: [.movies, .randomFun], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Chekhov's gun", categories: [.movies, .randomFun], packs: [.premadeStandard], obscurity: 3),

        // ===== EXTRA MOVIES & TV (STANDARD, LIGHT TOUCH) =====
        TitleEntry("The Incredibles", categories: [.movies], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Finding Nemo", categories: [.movies], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Toy Story", categories: [.movies], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("The Dark Knight", categories: [.movies], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Interstellar", categories: [.movies], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Everything Everywhere", categories: [.movies], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("The Grand Budapest", categories: [.movies], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Parasite", categories: [.movies], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Oppenheimer", categories: [.movies], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Barbie", categories: [.movies], packs: [.premadeStandard], obscurity: 1),

        // ===== EXTRA INTERNET CULTURE (OBSCURE) =====
        TitleEntry("Distracted Boyfriend meme", categories: [.internetCulture], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Charlie bit my finger", categories: [.internetCulture], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Numa Numa", categories: [.internetCulture], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("OK Boomer", categories: [.internetCulture], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Absolute unit", categories: [.internetCulture], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Crying Jordan", categories: [.internetCulture], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Shooting stars meme", categories: [.internetCulture], packs: [.premadeObscure], obscurity: 4),

        // ===== EXTRA SCIENCE/TECH (OBSCURE) =====
        TitleEntry("Butterfly keyboard", categories: [.technology, .brands], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Quantum tunneling", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 5),
        TitleEntry("Higgs boson", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 5),
        TitleEntry("Event loop", categories: [.technology, .nerdy], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Race condition", categories: [.technology, .nerdy], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Feature creep", categories: [.technology, .nerdy], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Bus factor", categories: [.technology, .nerdy], packs: [.premadeObscure], obscurity: 4),

        // ===== EXTRA FOOD (STANDARD) =====
        TitleEntry("California roll", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Cuban sandwich", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Korean corn dog", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Birria tacos", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Shakshuka", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Chicken katsu", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Garlic naan", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Banh mi", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Beef bulgogi", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Kimchi fried rice", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("General Tso's chicken", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 2),

        // ===== SHORT EMOTION TERMS (STANDARD) =====
        TitleEntry("Sunday scaries", categories: [.feelings, .nostalgia], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Brain freeze", categories: [.feelings, .foodDrink], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Secondhand embarrassment", categories: [.feelings], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Happy cry", categories: [.feelings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Cozy vibes", categories: [.feelings], packs: [.premadeStandard], obscurity: 2),

        // ===== EXTRA SHORT TITLES (STANDARD) =====
        TitleEntry("Ghostbusters", categories: [.movies], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Inception", categories: [.movies], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Coco", categories: [.movies], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Moana", categories: [.movies], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Up", categories: [.movies], packs: [.premadeStandard], obscurity: 1),

        // ===== BOARD & PARTY GAMES (STANDARD) =====
        TitleEntry("Codenames", categories: [.nerdy, .everydayThings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Cards Against Humanity", categories: [.nerdy, .everydayThings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Settlers of Catan", categories: [.nerdy, .everydayThings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Ticket to Ride", categories: [.nerdy, .everydayThings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Exploding Kittens", categories: [.nerdy, .everydayThings], packs: [.premadeStandard], obscurity: 2),

        // ===== LITERATURE & QUOTABLES (MIXED) =====
        TitleEntry("Catcher in the Rye", categories: [.randomFun, .nostalgia], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("To Kill a Mockingbird", categories: [.randomFun, .nostalgia], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Brave New World", categories: [.randomFun, .nostalgia], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Animal Farm", categories: [.randomFun, .nostalgia], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("The Little Prince", categories: [.randomFun, .nostalgia], packs: [.premadeStandard], obscurity: 2),

        // ===== SPORTS PHRASES (STANDARD – NOT NAMES) =====
        TitleEntry("Home court advantage", categories: [.everydayThings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Full court press", categories: [.everydayThings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Hail Mary", categories: [.everydayThings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Slam dunk", categories: [.everydayThings], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Photo finish", categories: [.everydayThings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Sudden death overtime", categories: [.everydayThings], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Hat trick", categories: [.everydayThings], packs: [.premadeStandard], obscurity: 2),

        // ===== EXTRA IDIOMS (OBSCURE-SIDE BUT FAMILIAR) =====
        TitleEntry("Cross that bridge", categories: [.everydayThings, .randomFun], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Ballpark figure", categories: [.everydayThings, .randomFun], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Barking up wrong tree", categories: [.everydayThings, .randomFun], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Skeletons in closet", categories: [.everydayThings, .randomFun], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Throw shade", categories: [.internetCulture, .everydayThings], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Spice things up", categories: [.foodDrink, .everydayThings], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Go the extra mile", categories: [.everydayThings], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Rain on parade", categories: [.everydayThings], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Under the radar", categories: [.everydayThings], packs: [.premadeObscure], obscurity: 3),
        TitleEntry("Wolves in sheep's clothing", categories: [.everydayThings], packs: [.premadeObscure], obscurity: 4),

        // ===== EXTRA SHORT TECH CULTURE (STANDARD) =====
        TitleEntry("Dark pattern", categories: [.technology, .internetCulture], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Cookie banner", categories: [.technology, .internetCulture], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Link in bio", categories: [.internetCulture, .technology], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Add to cart", categories: [.internetCulture, .brands], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Swipe right", categories: [.internetCulture, .feelings], packs: [.premadeStandard], obscurity: 2),

        // ===== EXTRA SHORT NOSTALGIA TECH (STANDARD) =====
        TitleEntry("Clamshell phone", categories: [.nostalgia, .technology], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("CD burner", categories: [.nostalgia, .technology], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("LAN party", categories: [.nostalgia, .nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("CRT monitor", categories: [.nostalgia, .technology], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Dial tone", categories: [.nostalgia, .technology], packs: [.premadeStandard], obscurity: 2),

        // ===== EXTRA PHRASES W/ SCIENCE TWIST (OBSCURE) =====
        TitleEntry("Occam's broom", categories: [.scienceFun, .randomFun], packs: [.premadeObscure], obscurity: 5),
        TitleEntry("Couching tiger", categories: [.randomFun], packs: [.premadeObscure], obscurity: 4), // playful twist but still idiomatic-ish
        TitleEntry("Cosmic microwave background", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 5),
        TitleEntry("Event horizon telescope", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 5),
        TitleEntry("Photoelectric effect", categories: [.scienceFun], packs: [.premadeObscure], obscurity: 5),

        // ===== EXTRA MINI-TITLES TO BOOST POOL (MIXED) =====
        TitleEntry("Plot twist", categories: [.movies], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Cold open", categories: [.movies], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Jump cut", categories: [.movies], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Easter egg hunt", categories: [.movies, .everydayThings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Fourth wall", categories: [.movies], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Running gag", categories: [.movies], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Fish out of water", categories: [.movies, .everydayThings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("MacGuffin", categories: [.movies], packs: [.premadeStandard], obscurity: 3),
        TitleEntry("Chekhov's arsenal", categories: [.movies], packs: [.premadeObscure], obscurity: 4),

        // ===== EXTRA FESTIVE / SEASONAL (STANDARD) =====
        TitleEntry("Snow day", categories: [.everydayThings], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Beach day", categories: [.everydayThings], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Pumpkin spice", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Hot chocolate", categories: [.foodDrink], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Ice cream truck", categories: [.foodDrink, .nostalgia], packs: [.premadeStandard], obscurity: 1),

        // ===== EXTRA QUICK HITS (MIXED) =====
        TitleEntry("Golden buzzer", categories: [.movies], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Encore", categories: [.musicVibes], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Soundcheck", categories: [.musicVibes], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Stage fright", categories: [.musicVibes, .feelings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Backstage pass", categories: [.musicVibes], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Plot bunny", categories: [.movies], packs: [.premadeObscure], obscurity: 4),
        TitleEntry("Bottle episode", categories: [.movies], packs: [.premadeObscure], obscurity: 4),

        // ===== EXTRA SHORT GEEK TERMS (STANDARD) =====
        TitleEntry("Rubber duck", categories: [.technology, .nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Code review", categories: [.technology, .nerdy], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Tech debt", categories: [.technology, .nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Feature flag", categories: [.technology, .nerdy], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Dark launch", categories: [.technology, .nerdy], packs: [.premadeStandard], obscurity: 3),

        // ===== EXTRA COMFY/FEELING PHRASES (STANDARD) =====
        TitleEntry("Fresh start", categories: [.feelings, .everydayThings], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Small victory", categories: [.feelings, .everydayThings], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Happy accident", categories: [.feelings, .everydayThings], packs: [.premadeStandard], obscurity: 2),
        TitleEntry("Beginner's luck", categories: [.feelings, .everydayThings], packs: [.premadeStandard], obscurity: 1),
        TitleEntry("Sweet spot", categories: [.feelings, .everydayThings], packs: [.premadeStandard], obscurity: 1),
    ]
    
    // MARK: - Helper Functions
    
    static func titlesForPack(_ pack: Pack, customFilters: CustomPackFilters? = nil) -> [Card] {
        if pack == .premadeCustom, let filters = customFilters {
            // Use custom filters
            return allTitles
                .filter { entry in
                    !entry.categories.isDisjoint(with: filters.categories) &&
                    filters.obscurityRange.contains(entry.obscurity) &&
                    filters.wordCountRange.contains(entry.title.split(separator: " ").count)
                }
                .map { entry in
                    Card(
                        title: entry.title,
                        categories: entry.categories,
                        packs: entry.packs,
                        obscurity: entry.obscurity,
                        wordCount: entry.title.split(separator: " ").count
                    )
                }
        } else {
            // Use predefined pack filters
            return allTitles
                .filter { $0.packs.contains(pack) }
                .map { entry in
                    Card(
                        title: entry.title,
                        categories: entry.categories,
                        packs: entry.packs,
                        obscurity: entry.obscurity,
                        wordCount: entry.title.split(separator: " ").count
                    )
                }
        }
    }
    
    static func allCards() -> [Card] {
        return allTitles.map { entry in
            Card(
                title: entry.title,
                categories: entry.categories,
                packs: entry.packs,
                obscurity: entry.obscurity,
                wordCount: entry.title.split(separator: " ").count
            )
        }
    }
    
    // Legacy function for backward compatibility - will be removed
    static func pool(for subject: String) -> [String] {
        // This is kept for backward compatibility but will be replaced
        return allTitles.filter { entry in
            entry.categories.contains(where: { $0.displayName.lowercased().contains(subject.lowercased()) })
        }.map { $0.title }
    }
}
