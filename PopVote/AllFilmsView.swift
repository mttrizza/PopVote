import SwiftUI
import SwiftData


enum SortOption: String, CaseIterable, Identifiable {
    
    case ratingHighLow = "Ranking (high rating)"
    case ratingLowHigh = "Ranking (low rating)"
    case alphabeticalAZ = "Alphabetical (A–Z)"
    case alphabeticalZA = "Alphabetical (Z-A)"
    case dateNewest = "Date (newest)"
    case dateOldest = "Date (oldest)"
    
    var id: String { self.rawValue }
}


struct AllFilmsView: View {

    @State private var searchText = ""

    @State private var currentSort: SortOption = .dateNewest
    
    @Query private var allFilms: [Film]
    
    var filteredAndSortedFilms: [Film] {
        // Search
        let filteredFilms: [Film]
        if searchText.isEmpty {
            filteredFilms = allFilms
        } else {

            filteredFilms = allFilms.filter { film in
                film.title.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sort
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
                List(filteredAndSortedFilms) { film in
                    NavigationLink(value: film) {
                        
                        HStack(spacing: 15) {
                            if let data = film.posterData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable().scaledToFill()
                                    .frame(width: 70, height: 70)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                Image(systemName: "film")
                                    .font(.title).foregroundColor(.gray)
                                    .frame(width: 70, height: 70)
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
            .searchable(text: $searchText, prompt: "Search by title...")
            
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
 
                    Menu {
   
                        Picker("Sort by", selection: $currentSort) {
                            ForEach(SortOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {

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
