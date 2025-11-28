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
    
    @Bindable var film: Film
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Folder.name) private var folders: [Folder]
    
    @State private var filmTitle: String
    @State private var filmComment: String
    @State private var filmRating: Double
    @State private var selectedHours: Int
    @State private var selectedMinutes: Int
    
    // <<< NUOVO: Genere >>>
    let genres = ["Action", "Adventure", "Animation", "Comedy", "Crime", "Documentary", "Drama", "Family", "Fantasy", "Horror", "Musical", "Mystery", "Romance", "Sci-Fi", "Thriller", "War", "Western"]
    @State private var selectedGenre: String
    
    @State private var selectedPosterItem: PhotosPickerItem?
    @State private var selectedPosterData: Data?
    @State private var selectedFolderID: PersistentIdentifier?

    init(film: Film) {
        self.film = film
        _filmTitle = State(initialValue: film.title)
        _filmComment = State(initialValue: film.comment)
        _filmRating = State(initialValue: film.rating)
        _selectedPosterData = State(initialValue: film.posterData)
        _selectedFolderID = State(initialValue: film.folder?.id)
        _selectedHours = State(initialValue: film.durationMinutes / 60)
        _selectedMinutes = State(initialValue: film.durationMinutes % 60)
        
        // <<< Inizializziamo il genere >>>
        _selectedGenre = State(initialValue: film.genre)
    }

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        
                        PhotosPicker(selection: $selectedPosterItem, matching: .images, photoLibrary: .shared()) {
                            VStack {
                                if let data = selectedPosterData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage).resizable().scaledToFill().frame(width: 150, height: 200).clipShape(RoundedRectangle(cornerRadius: 10))
                                } else {
                                    Image(systemName: "film.stack.fill").font(.system(size: 80)).foregroundColor(.gray).frame(width: 150, height: 200).background(Color.gray.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                Text("Change Film Poster").font(.caption).foregroundColor(.blue)
                            }
                        }
                        .onChange(of: selectedPosterItem) {
                            Task {
                                if let data = try? await selectedPosterItem?.loadTransferable(type: Data.self) {
                                    selectedPosterData = data
                                }
                            }
                        }
                        
                        TextField("Film Title", text: $filmTitle).textFieldStyle(.roundedBorder).padding(.horizontal)
                        
                        // <<< NUOVO: Menu Modifica Genere >>>
                        HStack {
                            Text("Genre").font(.headline)
                            Spacer()
                            Picker("Select Genre", selection: $selectedGenre) {
                                ForEach(genres, id: \.self) { genre in
                                    Text(genre).tag(genre)
                                }
                            }
                            .pickerStyle(.menu)
                            .accentColor(.blue)
                        }
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                        
                        // Durata
                        HStack {
                            Text("Duration:").font(.headline)
                            Picker("Hours", selection: $selectedHours) { ForEach(0...10, id: \.self) { h in Text("\(h) h").tag(h) } }.pickerStyle(.wheel).frame(height: 100)
                            Picker("Minutes", selection: $selectedMinutes) { ForEach(0...59, id: \.self) { m in Text("\(m) min").tag(m) } }.pickerStyle(.wheel).frame(height: 100)
                        }
                        .padding(.horizontal).background(Color.gray.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal)
                        
                        TextEditor(text: $filmComment).frame(height: 100).overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1)).padding(.horizontal)
                        
                        VStack {
                            Text("Rating: \(filmRating, specifier: "%.1f")").font(.headline)
                            Slider(value: $filmRating, in: 0...5, step: 0.1) { Text("Film Rating") }
                        }
                        .padding().background(Color.gray.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal)
                        
                        if !folders.isEmpty {
                            NavigationLink(destination: CustomFolderSelectionView(folders: folders, selectedID: $selectedFolderID)) {
                                HStack {
                                    Text("Select Folder")
                                    Spacer()
                                    if let selectedID = selectedFolderID, let selectedFolder = folders.first(where: { $0.id == selectedID }) {
                                        Text(selectedFolder.name).foregroundColor(.gray)
                                    } else {
                                        Text("No Folder").foregroundColor(.gray)
                                    }
                                }
                                .padding().background(Color.gray.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .foregroundColor(.primary).padding(.horizontal)
                        } else {
                            Text("No folders available.").foregroundColor(.red)
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit Film").navigationBarTitleDisplayMode(.inline).background(Color(red: 0.95, green: 0.85, blue: 0.75)).scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel", role: .cancel) { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveChanges(); dismiss() }.disabled(filmTitle.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        film.title = filmTitle
        film.comment = filmComment
        film.rating = filmRating
        film.durationMinutes = (selectedHours * 60) + selectedMinutes
        film.genre = selectedGenre // <<< Aggiorna genere
        film.posterData = selectedPosterData
        
        if let selectedID = selectedFolderID, let targetFolder = folders.first(where: { $0.id == selectedID }) {
            film.folder = targetFolder
        } else {
            film.folder = nil
        }
    }
}
