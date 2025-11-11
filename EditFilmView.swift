//
//  EditFilmView.swift
//  PopVote
//
//  Created by Mattia Rizza on 04/11/25.
//

import SwiftUI
import PhotosUI
import SwiftData

struct EditFilmView: View {
    
    // <<< MODIFICA: Riceviamo il film da modificare
    @Bindable var film: Film
    
    // Accesso al database
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Query per le cartelle
    @Query(sort: \Folder.name) private var folders: [Folder]
    
    // --- Variabili di Stato ---
    // Queste variabili "temporanee" servono per modificare
    // i dati senza salvarli finché non si preme "Save".
    @State private var filmTitle: String
    @State private var filmComment: String
    @State private var filmRating: Double
    
    // Variabili per il PhotosPicker
    @State private var selectedPosterItem: PhotosPickerItem?
    @State private var selectedPosterData: Data?
    
    // Variabile per la cartella
    @State private var selectedFolderID: PersistentIdentifier?

    // <<< NUOVO: Inizializzatore per pre-caricare i dati >>>
    // Quando la vista viene creata, copia i dati
    // del film nelle variabili di stato.
    init(film: Film) {
        self.film = film
        
        // Pre-carica i dati
        _filmTitle = State(initialValue: film.title)
        _filmComment = State(initialValue: film.comment)
        _filmRating = State(initialValue: film.rating)
        _selectedPosterData = State(initialValue: film.posterData)
        _selectedFolderID = State(initialValue: film.folder?.id)
    }

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // --- Image Picker (Poster) ---
                        PhotosPicker(
                            selection: $selectedPosterItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            VStack {
                                // Mostra l'immagine nuova (se scelta) o quella vecchia
                                if let data = selectedPosterData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable().scaledToFill()
                                        .frame(width: 150, height: 200)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                } else {
                                    // Placeholder
                                    Image(systemName: "film.stack.fill")
                                        .font(.system(size: 80)).foregroundColor(.gray)
                                        .frame(width: 150, height: 200)
                                        .background(Color.gray.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                Text("Change Film Poster")
                                    .font(.caption).foregroundColor(.blue)
                            }
                        }
                        .onChange(of: selectedPosterItem) {
                            Task {
                                // Carica i dati della *nuova* immagine
                                if let data = try? await selectedPosterItem?.loadTransferable(type: Data.self) {
                                    selectedPosterData = data
                                }
                            }
                        }
                        
                        // --- Campo Titolo ---
                        TextField("Film Title", text: $filmTitle)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                        
                        // --- Campo Commento ---
                        TextEditor(text: $filmComment)
                            .frame(height: 100)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                            .padding(.horizontal)
                        
                        // --- Slider Voto ---
                        VStack {
                            Text("Rating: \(filmRating, specifier: "%.1f")")
                                .font(.headline)
                            Slider(value: $filmRating, in: 0...5, step: 0.1) {
                                Text("Film Rating")
                            }
                        }
                        .padding().background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                        
                        // --- Picker Cartella (Custom) ---
                        if !folders.isEmpty {
                            NavigationLink(destination:
                                CustomFolderSelectionView(folders: folders, selectedID: $selectedFolderID)
                            ) {
                                HStack {
                                    Text("Select Folder")
                                    Spacer()
                                    if let selectedID = selectedFolderID,
                                       let selectedFolder = folders.first(where: { $0.id == selectedID }) {
                                        Text(selectedFolder.name).foregroundColor(.gray)
                                    } else {
                                        Text("No Folder").foregroundColor(.gray)
                                    }
                                }
                                .padding().background(Color.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        } else {
                            Text("No folders available.").foregroundColor(.red)
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            // <<< MODIFICA: Titolo e pulsanti della barra >>>
            .navigationTitle("Edit Film")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(red: 0.95, green: 0.85, blue: 0.75))
            .scrollContentBackground(.hidden)
            .toolbar {
                // Pulsante Annulla
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", role: .cancel) {
                        dismiss() // Chiude senza salvare
                    }
                }
                // Pulsante Salva
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveChanges()
                        dismiss() // Chiude dopo aver salvato
                    }
                    .disabled(filmTitle.isEmpty) // Disabilitato se il titolo è vuoto
                }
            }
        }
    }
    
    // <<< NUOVO: Funzione per salvare le modifiche >>>
    private func saveChanges() {
        // Aggiorna il film originale con i nuovi dati
        film.title = filmTitle
        film.comment = filmComment
        film.rating = filmRating
        film.posterData = selectedPosterData
        
        // Aggiorna la cartella
        if let selectedID = selectedFolderID,
           let targetFolder = folders.first(where: { $0.id == selectedID }) {
            film.folder = targetFolder // Assegna la nuova cartella
        } else {
            film.folder = nil // Rimuove da qualsiasi cartella
        }
        
        // Non serve modelContext.insert(), perché il film
        // esiste già. SwiftData salva automaticamente le modifiche.
    }
}
