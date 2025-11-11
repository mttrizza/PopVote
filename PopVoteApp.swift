//
//  PopVoteApp.swift
//  PopVote
//
//  Created by Mattia Rizza on 31/10/25.
//
import SwiftUI
import SwiftData // 1. Importa SwiftData

@main
struct PopVoteApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        // 2. Aggiungi questo modificatore per "attivare"
        // il database per il nostro modello 'Folder'
       // .modelContainer(for: Folder.self)
        .modelContainer(for: [Folder.self, Film.self])
    }
}
