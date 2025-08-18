import SwiftUI

@main
struct bgb_cpgApp: App {
    @StateObject private var store = GameStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .onAppear {
                    print("🚀 bgb-cpg App launched successfully")
                    print("🎮 GameStore initialized and ready")
                }
        }
    }
}
