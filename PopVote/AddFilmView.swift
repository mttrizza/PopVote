import SwiftUI
import PhotosUI
import SwiftData

struct AddFilmView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Folder.name) private var folders: [Folder]
    @Environment(\.dismiss) private var dismiss
    
    // Stati del form
    @State private var filmTitle: String
    @State private var filmComment: String = ""
    @State private var filmRating: Double = 2.5
    @State private var selectedHours: Int = 0
    @State private var selectedMinutes: Int = 0
    
    let genres = ["Action", "Adventure", "Animation", "Comedy", "Crime", "Documentary", "Drama", "Family", "Fantasy", "Horror", "Musical", "Mystery", "Romance", "Sci-Fi", "Thriller", "War", "Western"]
    @State private var selectedGenre: String = "Action"
    
    @State private var selectedPosterItem: PhotosPickerItem?
    @State private var selectedPosterData: Data?
    @State private var selectedFolderID: PersistentIdentifier?
    
    // <<< NUOVO: Callback per avvisare che il salvataggio è riuscito >>>
    var onSaveSuccess: (() -> Void)? = nil

    // <<< NUOVO: Init personalizzato per accettare dati pre-compilati >>>
    init(prefilledTitle: String? = nil, prefilledPosterData: Data? = nil, onSaveSuccess: (() -> Void)? = nil) {
        // Se abbiamo un titolo precompilato, lo usiamo, altrimenti vuoto
        if let title = prefilledTitle {
            _filmTitle = State(initialValue: title)
        } else {
            _filmTitle = State(initialValue: "")
        }
        
        // Se abbiamo un poster precompilato, lo usiamo
        if let data = prefilledPosterData {
            _selectedPosterData = State(initialValue: data)
        }
        
        self.onSaveSuccess = onSaveSuccess
    }

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Image Picker
                        PhotosPicker(selection: $selectedPosterItem, matching: .images, photoLibrary: .shared()) {
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
                                Text("Add Film Poster").font(.caption).foregroundColor(.blue)
                            }
                        }
                        .onChange(of: selectedPosterItem) {
                            Task {
                                if let data = try? await selectedPosterItem?.loadTransferable(type: Data.self) {
                                    selectedPosterData = data
                                }
                            }
                        }
                        
                        // Titolo
                        TextField("Film Title", text: $filmTitle)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                        
                        // Genere
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
                        .padding().background(Color.white).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal)
                        
                        // Durata
                        HStack {
                            Text("Duration:").font(.headline)
                            Picker("Hours", selection: $selectedHours) { ForEach(0...10, id: \.self) { h in Text("\(h) h").tag(h) } }.pickerStyle(.wheel).frame(height: 100)
                            Picker("Minutes", selection: $selectedMinutes) { ForEach(0...59, id: \.self) { m in Text("\(m) min").tag(m) } }.pickerStyle(.wheel).frame(height: 100)
                        }
                        .padding(.horizontal).background(Color.gray.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal)
                        
                        // Commento
                        TextEditor(text: $filmComment)
                            .frame(height: 100)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                            .padding(.horizontal)
                        
                        // Rating
                        VStack {
                            Text("Rating: \(filmRating, specifier: "%.1f")").font(.headline)
                            Slider(value: $filmRating, in: 0...5, step: 0.1) { Text("Film Rating") }
                        }
                        .padding().background(Color.gray.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.horizontal)
                        
                        // Cartella
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
                            Text("Nessuna cartella creata.").font(.caption).foregroundColor(.secondary).padding(.horizontal)
                        }
                        
                        Button("Save Film") { saveFilm() }
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
        let totalMinutes = (selectedHours * 60) + selectedMinutes
        
        let newFilm = Film(
            title: filmTitle,
            comment: filmComment,
            rating: filmRating,
            durationMinutes: totalMinutes,
            genre: selectedGenre,
            posterData: selectedPosterData
        )
        
        modelContext.insert(newFilm)
        
        if let selectedID = selectedFolderID,
           let targetFolder = folders.first(where: { $0.id == selectedID }) {
            targetFolder.films?.append(newFilm)
        }
        
        // <<< Chiama la funzione di successo (se esiste) >>>
        onSaveSuccess?()
        
        // Chiude la vista (che sia un tab o uno sheet)
        dismiss()
        
        // Reset (utile se è un Tab che non viene distrutto)
        filmTitle = ""
        filmComment = ""
        filmRating = 2.5
        selectedHours = 0
        selectedMinutes = 0
        selectedGenre = "Action"
        selectedPosterItem = nil
        selectedPosterData = nil
        selectedFolderID = nil
    }
}
