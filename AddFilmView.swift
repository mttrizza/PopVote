//
//  AddFilmView.swift
//  PopVote
//
//  Created by Mattia Rizza on 31/10/25.
//

import SwiftUI
import PhotosUI
import SwiftData

struct AddFilmView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Folder.name) private var folders: [Folder]
    
    @State private var filmTitle: String = ""
    @State private var filmComment: String = ""
    @State private var filmRating: Double = 2.5
    @State private var selectedPosterItem: PhotosPickerItem?
    @State private var selectedPosterData: Data?
    @State private var selectedFolderID: PersistentIdentifier?
    
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // --- Image Picker (Poster del Film) ---
                        PhotosPicker(
                            selection: $selectedPosterItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            VStack {
                                if let data = selectedPosterData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable().scaledToFill()
                                        .frame(width: 150, height: 200)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                } else {
                                    Image(systemName: "film.stack.fill")
                                        .font(.system(size: 80)).foregroundColor(.gray)
                                        .frame(width: 150, height: 200)
                                        .background(Color.gray.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                Text("Add Film Poster")
                                    .font(.caption).foregroundColor(.blue)
                            }
                        }
                        .onChange(of: selectedPosterItem) {
                            Task {
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
                            
                            // <<< MODIFICA: Ho rimosso il blocco .onAppear da qui >>>
                            
                        } else {
                            Text("Nessuna cartella creata. Il film sarà salvato senza cartella.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        }
                        
                        // --- Pulsante Salva ---
                        Button("Save Film") {
                            saveFilm()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(filmTitle.isEmpty)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Film")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(red: 0.95, green: 0.85, blue: 0.75))
            .scrollContentBackground(.hidden)
        }
    }
    
    private func saveFilm() {
        let newFilm = Film(
            title: filmTitle,
            comment: filmComment,
            rating: filmRating,
            posterData: selectedPosterData
        )
        
        modelContext.insert(newFilm)
        
        if let selectedID = selectedFolderID,
           let targetFolder = folders.first(where: { $0.id == selectedID }) {
            targetFolder.films?.append(newFilm)
        }
        
        // Resetta i campi
        filmTitle = ""
        filmComment = ""
        filmRating = 2.5
        selectedPosterItem = nil
        selectedPosterData = nil
        selectedFolderID = nil // Resetta l'ID, così il prossimo film riparte da "No Folder"
    }
}

#Preview {
    AddFilmView()
        .modelContainer(for: [Folder.self, Film.self], inMemory: true)
}
