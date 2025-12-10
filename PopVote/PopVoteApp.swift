import SwiftUI
import SwiftData

@main
struct PopVoteApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: [Folder.self, Film.self, WishlistItem.self])
    }
}
