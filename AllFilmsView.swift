//
//  RankingView.swift
//  PopVote
//
//  Created by Mattia Rizza on 02/11/25.
//

import SwiftUI
import SwiftData

// <<< NUOVO: Un Enum per definire le opzioni di filtro >>>
enum SortOption: String, CaseIterable, Identifiable {
    // CaseIterable ci permette di elencarli tutti in un Picker
    // Identifiable serve al Picker per sapere qual è quale
    
    case ratingHighLow = "Ranking (high rating)"
    case ratingLowHigh = "Ranking (low rating)"
    case alphabeticalAZ = "Alphabetical (A–Z)"
    case alphabeticalZA = "Alphabetical (Z-A)"
    case dateNewest = "Date (newest)"
    case dateOldest = "Date (oldest)"
    
    var id: String { self.rawValue }
}


struct AllFilmsView: View {
    
    // <<< NUOVO: Stato per la barra di ricerca >>>
    @State private var searchText = ""
    
    // <<< NUOVO: Stato per il filtro selezionato >>>
    @State private var currentSort: SortOption = .dateNewest // Filtro di default
    
    // <<< MODIFICA: La @Query ora carica TUTTI i film, senza ordinarli >>>
    // L'ordinamento e il filtro li faremo noi.
    @Query private var allFilms: [Film]
    
    
    // <<< NUOVO: "Computed Property" per la lista filtrata e ordinata >>>
    // Questa variabile si ricalcola automaticamente quando
    // 'searchText' o 'currentSort' cambiano.
    var filteredAndSortedFilms: [Film] {
        // 1. Filtra per la ricerca (Search)
        let filteredFilms: [Film]
        if searchText.isEmpty {
            filteredFilms = allFilms // Se la ricerca è vuota, prendili tutti
        } else {
            // Altrimenti, filtra quelli che contengono il testo di ricerca
            filteredFilms = allFilms.filter { film in
                film.title.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // 2. Ordina (Sort) i film che sono stati filtrati
        switch currentSort {
        case .ratingHighLow:
            return filteredFilms.sorted { $0.rating > $1.rating }
        case .ratingLowHigh:
            return filteredFilms.sorted { $0.rating < $1.rating }
        case .alphabeticalAZ:
            return filteredFilms.sorted { $0.title < $1.title }
        case .alphabeticalZA:
            return filteredFilms.sorted { $0.title > $1.title }
        case .dateNewest:
            return filteredFilms.sorted { $0.dateAdded > $1.dateAdded }
        case .dateOldest:
            return filteredFilms.sorted { $0.dateAdded < $1.dateAdded }
        }
    }

    
    var body: some View {
        NavigationStack {
            VStack {
                // <<< MODIFICA: Usiamo la nostra nuova variabile >>>
                List(filteredAndSortedFilms) { film in
                    NavigationLink(value: film) {
                        
                        // (Questa riga è la stessa di prima)
                        HStack(spacing: 15) {
                            if let data = film.posterData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable().scaledToFill()
                                    .frame(width: 60, height: 90)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                Image(systemName: "film")
                                    .font(.title).foregroundColor(.gray)
                                    .frame(width: 60, height: 90)
                                    .background(Color.gray.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            VStack(alignment: .leading) {
                                Text(film.title)
                                    .font(.headline)
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.white)
                                    Text("\(film.rating, specifier: "%.1f")")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
                
                // <<< NUOVO: Messaggio se la lista filtrata è vuota >>>
                .overlay {
                    if filteredAndSortedFilms.isEmpty {
                        VStack {
                            Image(systemName: "film.stack")
                                .font(.largeTitle)
                            Text(allFilms.isEmpty ? "No movies added" :
                                    "No movies found")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
            }
            // <<< NUOVO: Barra di ricerca >>>
            // Si aggancia alla NavigationStack e appare sotto al titolo
            .searchable(text: $searchText, prompt: "Search by title...")
            
            // <<< NUOVO: Pulsante Filtro >>>
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    // Menu fa apparire il pop-up con le opzioni
                    Menu {
                        // Picker per selezionare l'opzione di filtro
                        Picker("Sort by", selection: $currentSort) {
                            ForEach(SortOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        // Questa è l'icona del pulsante
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            
            .navigationDestination(for: Film.self) { film in
                FilmDetailView(film: film)
            }
            .background(Color(red: 0.95, green: 0.85, blue: 0.75))
            .navigationTitle("All Films")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AllFilmsView()
        .modelContainer(for: [Folder.self, Film.self], inMemory: true)
}
