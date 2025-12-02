import SwiftUI
import SwiftData

@main
struct PopVoteApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        // Assicurati che ci siano TUTTI E TRE i modelli qui dentro:
        .modelContainer(for: [Folder.self, Film.self, WishlistItem.self])
    }
}
