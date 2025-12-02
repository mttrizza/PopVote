import SwiftUI
import SwiftData

struct FolderDetailsView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Stato per mostrare il foglio di modifica
    @State private var isShowingEditSheet = false
    
    let folder: Folder
    
    var body: some View {
        VStack {
            
            if let films = folder.films, !films.isEmpty {
                // Elenco dei film
                List(films) { film in
                    NavigationLink(value: film) {
                        HStack(spacing: 15) {
                            // Immagine Quadrata (come da tua richiesta precedente)
                            if let data = film.posterData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable().scaledToFill()
                                    .frame(width: 70, height: 70)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                Image(systemName: "film")
                                    .font(.title).foregroundColor(.gray)
                                    .frame(width: 70, height: 70)
                                    .background(Color.gray.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
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
        
        // --- MODIFICA QUI: Tasto Edit invece di Delete ---
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    isShowingEditSheet = true
                }
            }
        }
        // Sheet per la modifica
        .sheet(isPresented: $isShowingEditSheet) {
            EditFolderView(folder: folder)
                .presentationDetents([.medium])
        }
        
        .toolbarBackground(
            Color(red: 0.95, green: 0.85, blue: 0.75),
            for: .navigationBar
        )
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
