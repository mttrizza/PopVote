//
//  StatisticsView.swift
//  PopVote
//
//  Created by Mattia Rizza on [Data Odierna].
//

import SwiftUI
import SwiftData

struct StatisticsView: View {
    
    @Query private var allFilms: [Film]
    
    // Calcolo Durata Totale
    var totalDurationString: String {
        let totalMinutes = allFilms.reduce(0) { $0 + $1.durationMinutes }
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if totalMinutes == 0 { return "0h 0m" }
        return "\(hours)h \(minutes)m"
    }
    
    // Calcolo Genere Preferito
    var favoriteGenreString: String {
        if allFilms.isEmpty { return "None" }
        
        // Crea un dizionario [Genere: Numero di film]
        let genreCounts = Dictionary(grouping: allFilms, by: { $0.genre })
            .mapValues { $0.count }
        
        // Trova il genere con il valore più alto
        if let maxGenre = genreCounts.max(by: { $0.value < $1.value }) {
            return "\(maxGenre.key) (\(maxGenre.value) films)"
        }
        return "None"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // --- CARD 1: Tempo Totale ---
                    VStack(spacing: 10) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        Text("Total Watch Time")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(totalDurationString)
                            .font(.custom("HoltwoodOneSC-Regular", size: 24))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 5)
                    
                    // --- CARD 2: Genere Preferito ---
                    VStack(spacing: 10) {
                        Image(systemName: "film.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.purple)
                        Text("Favorite Genre")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(favoriteGenreString)
                            .font(.custom("HoltwoodOneSC-Regular", size: 24))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 5)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(red: 0.95, green: 0.85, blue: 0.75))
        }
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: Film.self, inMemory: true)
}
