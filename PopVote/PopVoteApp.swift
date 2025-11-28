//
//  PopVoteApp.swift
//  PopVote
//
//  Created by Mattia Rizza on 31/10/25.
//
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
