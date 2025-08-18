import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: GameStore

    var body: some View {
        ZStack {
            // Simple colorful background that shifts by stage/round for fun
            LinearGradient(colors: store.backgroundColors,
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.35), value: store.stage)
                .animation(.easeInOut(duration: 0.35), value: store.currentRound)

            switch store.stage {
            case .home:
                HomeView()
                    .onAppear { print("📱 ContentView: Displaying HomeView") }
            case .howTo:
                HowToView()
                    .onAppear { print("📱 ContentView: Displaying HowToView") }
            case .settings:
                SettingsView()
                    .onAppear { print("📱 ContentView: Displaying SettingsView") }
            case .intakeHandoff:
                IntakeHandoffView()
                    .onAppear { print("📱 ContentView: Displaying IntakeHandoffView") }
            case .intakeName:
                IntakeNameView()
                    .onAppear { print("📱 ContentView: Displaying IntakeNameView") }
            case .intakePicks:
                IntakePicksView()
                    .onAppear { print("📱 ContentView: Displaying IntakePicksView") }
            case .roundIntro:
                RoundIntroView()
                    .onAppear { print("📱 ContentView: Displaying RoundIntroView (Round \(store.currentRound.rawValue))") }
            case .turnHandoff:
                TurnHandoffView()
                    .onAppear { print("📱 ContentView: Displaying TurnHandoffView (\(store.currentTeam) - \(store.clueGiver?.name ?? "unknown"))") }
            case .turn:
                TurnView()
                    .onAppear { print("📱 ContentView: Displaying TurnView (\(store.clueGiver?.name ?? "unknown")'s turn)") }
            case .turnPaused:
                TurnPausedView()
                    .onAppear { print("📱 ContentView: Displaying TurnPausedView") }
            case .turnSkipComplete:
                TurnSkipCompleteView()
                    .onAppear { print("📱 ContentView: Displaying TurnSkipCompleteView") }
            case .turnComplete:
                TurnCompleteView()
                    .onAppear { print("📱 ContentView: Displaying TurnCompleteView") }
            case .recap:
                RecapView()
                    .onAppear { print("📱 ContentView: Displaying RecapView (\(store.thisTurnCorrect.count) correct)") }
            case .roundEnd:
                RoundEndView()
                    .onAppear { print("📱 ContentView: Displaying RoundEndView (Round \(store.currentRound.rawValue) complete)") }
            case .gameEnd:
                GameEndView()
                    .onAppear { print("📱 ContentView: Displaying GameEndView (Final scores - A: \(store.cumulativeA), B: \(store.cumulativeB))") }
            case .gameStats:
                GameStatsView()
                    .onAppear { print("📱 ContentView: Displaying GameStatsView") }
            }
        }
        .preferredColorScheme(.light) // keeps the Letterpress vibe
    }
}
