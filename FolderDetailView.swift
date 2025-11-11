//
//  FolderDetailView.swift
//  PopVote
//
//  Created by Mattia Rizza on 31/10/25.
//

import SwiftUI
import SwiftData

struct FolderDetailsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingDeleteAlert = false
    
    let folder: Folder
    
    var body: some View {
        VStack {
            
            if let films = folder.films, !films.isEmpty {
                // Elenco dei film
                List(films) { film in
                    NavigationLink(value: film) {
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
                                Text("Vote: \(film.rating, specifier: "%.1f")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
                
            } else {
                // Messaggio cartella vuota
                Spacer()
                Text("This folder is empty.")
                Text("Add a movie from the 'Add' screen.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .navigationTitle(folder.name)
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.95, green: 0.85, blue: 0.75))
        
        .navigationDestination(for: Film.self) { film in
            FilmDetailView(film: film)
        }
        
        // --- MODIFICA QUESTA RIGA ---
        .toolbar {
            // Spostato da .topBarLeading a .topBarTrailing
            ToolbarItem(placement: .topBarTrailing) {
                Button("Delete", role: .destructive) {
                    isShowingDeleteAlert = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
        }
        
        .alert("Delete \"\(folder.name)\"?", isPresented: $isShowingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteFolder()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            // Aggiorniamo il messaggio per riflettere la nuova regola
            Text("This action will remove the folder, but the movies inside it will remain visible in the 'All Film' screen.")
        }
        
        .toolbarBackground(
            Color(red: 0.95, green: 0.85, blue: 0.75),
            for: .navigationBar
        )
        .toolbarBackground(.visible, for: .navigationBar)
    }
    
    private func deleteFolder() {
        modelContext.delete(folder)
        dismiss()
    }
}

// --- PREVIEW ---
#Preview {
    NavigationStack {
        FolderDetailsView(folder: Folder(name: "Test Folder", iconData: nil))
            .modelContainer(for: [Folder.self, Film.self], inMemory: true)
    }
}
