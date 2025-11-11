//
//  FilmDetailView.swift
//  PopVote
//
//  Created by Mattia Rizza on 31/10/25.
//

import SwiftUI
import SwiftData

struct FilmDetailView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let film: Film
    
    // Stato per mostrare lo sheet di modifica
    @State private var isShowingEditSheet = false
    
    // <<< NUOVO: Stato per l'alert di conferma eliminazione film >>>
    @State private var isShowingDeleteAlert = false
    
    var body: some View {
        
        ScrollView { // <<< IL CONTENITORE PRINCIPALE
            VStack(alignment: .leading, spacing: 20) {
                
                // --- POSTER ---
                HStack {
                    Spacer()
                    if let data = film.posterData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable().scaledToFit().frame(height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 5)
                    } else {
                        Image(systemName: "film")
                            .font(.system(size: 100)).foregroundColor(.gray)
                            .frame(width: 200, height: 300)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    Spacer()
                }
                .padding(.top, 20)
                
                // --- TITOLO E VOTO ---
                VStack(alignment: .leading, spacing: 5) {
                    Text(film.title)
                        .font(.custom("HoltwoodOneSC-Regular", size: 32))
                        .lineLimit(2)
                    
                    HStack {
                        // Uso .white come da tuo codice precedente
                        Image(systemName: "star.fill").foregroundColor(.white)
                        Text("\(film.rating, specifier: "%.1f") / 5.0")
                            .font(.title2).fontWeight(.semibold)
                    }
                }
                .padding(.horizontal)
                
                // --- COMMENTO ---
                if !film.comment.isEmpty {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Comment").font(.headline) // Testo UI in Inglese
                        Text(film.comment).font(.body)
                    }
                    .padding()
                    .background(Color.black.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                }
                
                // --- Data e Pulsante Delete (raggruppati) ---
                VStack(alignment: .leading, spacing: 8) {
                    Text("Added on: \(film.dateAdded.formatted(date: .long, time: .shortened))") // Testo UI in Inglese
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(role: .destructive) {
                        // <<< MODIFICA: Ora apre l'alert >>>
                        isShowingDeleteAlert = true
                    } label: {
                        Text("Delete") // Testo UI in Inglese
                            .font(.subheadline)
                            // Uso il tuo frame personalizzato
                            .frame(maxWidth: 55)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
                .padding(.horizontal)
                
            } // --- Fine VStack del contenuto
        } // --- Fine ScrollView
        
        // Questi modificatori devono essere applicati alla SCROLLVIEW
        .background(Color(red: 0.95, green: 0.85, blue: 0.75))
        .scrollContentBackground(.hidden) // Questa riga è FONDAMENTALE
        .navigationTitle(film.title)
        .navigationBarTitleDisplayMode(.inline)
        
        // Pulsante "Modifica" in alto a destra
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { // Testo UI in Inglese
                    isShowingEditSheet = true
                }
            }
        }
        // Sheet (pop-up) per la modifica
        .sheet(isPresented: $isShowingEditSheet) {
            EditFilmView(film: film)
        }
        
        // <<< NUOVO: Alert per conferma eliminazione >>>
        .alert("Delete \"\(film.title)\"?", isPresented: $isShowingDeleteAlert) {
            Button("Delete", role: .destructive) { // Testo UI in Inglese
                deleteFilm() // Esegue la cancellazione VERA
            }
            Button("Cancel", role: .cancel) { } // Testo UI in Inglese
        } message: {
            Text("This action is irreversible.") // Testo UI in Inglese
        }
    }
    
    // Funzione per eliminare il film
    private func deleteFilm() {
        modelContext.delete(film)
        dismiss()
    }
}

// --- PREVIEW ---
#Preview {
    NavigationStack {
        let filmDiProva = Film(
            title: "Very Long Movie Name for Test",
            comment: "This is a test comment",
            rating: 4.7,
            posterData: nil
        )
        FilmDetailView(film: filmDiProva)
            .modelContainer(for: [Folder.self, Film.self], inMemory: true)
    }
}
