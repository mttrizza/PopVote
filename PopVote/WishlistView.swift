import SwiftUI
import SwiftData

struct WishlistView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WishlistItem.dateAdded, order: .reverse) private var wishlistItems: [WishlistItem]
    
    @State private var searchText = ""
    @State private var showingAddSheet = false
    
    // Lista filtrata
    var filteredItems: [WishlistItem] {
        if searchText.isEmpty {
            return wishlistItems
        } else {
            return wishlistItems.filter { item in
                item.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) { // VStack principale per impilare Ricerca e Lista
                
                // --- BARRA DI RICERCA PERSONALIZZATA (Stile "All Films") ---
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search by title...", text: $searchText)
                        .foregroundColor(.black)
                }
                .padding(10) // Spazio interno
                .background(Color.white) // Sfondo BIANCO come nella foto
                .clipShape(RoundedRectangle(cornerRadius: 25)) // Bordi arrotondati
                .padding(.horizontal) // Margine laterale
                .padding(.bottom, 10) // Un po' di spazio sotto la barra
                .padding(.top, 10)    // Un po' di spazio sopra la barra
                
                // --- LISTA ---
                List {
                    ForEach(filteredItems) { item in
                        NavigationLink(value: item) {
                            HStack(spacing: 15) {
                                // Immagine piccola
                                if let data = item.posterData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable().scaledToFill()
                                        .frame(width: 70, height: 70)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                } else {
                                    Image(systemName: "popcorn")
                                        .font(.title2).foregroundColor(.gray)
                                        .frame(width: 70, height: 70)
                                        .background(Color.gray.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                }
                                
                                // Titolo
                                Text(item.title)
                                    .font(.headline)
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden) // Rimuove lo sfondo grigio di default della lista
                
                // Overlay per lista vuota o ricerca senza risultati
                .overlay {
                    if wishlistItems.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "list.star")
                                .font(.system(size: 50))
                            Text("Your wishlist is empty.")
                            Text("Add movies you want to see!")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    } else if filteredItems.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    }
                }
            }
            .background(Color(red: 0.95, green: 0.85, blue: 0.75)) // Colore sfondo "Sabbia"
            
            // --- TITOLO STILE "ALL FILMS" ---
            .navigationTitle("WishList")
            .navigationBarTitleDisplayMode(.inline) // <<< QUESTO rende il titolo piccolo e centrato
            
            .navigationDestination(for: WishlistItem.self) { item in
                WishlistDetailView(item: item)
            }
            
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.black) // Colore icona più scuro
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddWishlistView()
                    .presentationDetents([.medium])
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let itemToDelete = filteredItems[index]
                modelContext.delete(itemToDelete)
            }
        }
    }
}

#Preview {
    WishlistView()
        .modelContainer(for: WishlistItem.self, inMemory: true)
}
