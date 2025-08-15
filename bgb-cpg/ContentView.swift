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
            case .howTo:
                HowToView()
            case .settings:
                SettingsView()
            case .intakeHandoff:
                IntakeHandoffView()
            case .intakeName:
                IntakeNameView()
            case .intakePicks:
                IntakePicksView()
            case .roundIntro:
                RoundIntroView()
            case .turnHandoff:
                TurnHandoffView()
            case .primer:
                PrimerView()
            case .turnReady:
                TurnReadyView()
            case .turn:
                TurnView()
            case .turnPaused:
                TurnPausedView()
            case .recap:
                RecapView()
            case .roundEnd:
                RoundEndView()
            case .gameEnd:
                GameEndView()
            case .gameStats:
                GameStatsView()
            }
        }
        .preferredColorScheme(.light) // keeps the Letterpress vibe
    }
}
