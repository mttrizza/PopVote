import SwiftUI
import SwiftData

struct WishlistView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WishlistItem.dateAdded, order: .reverse) private var wishlistItems: [WishlistItem]
    
    @State private var searchText = ""
    @State private var showingAddSheet = false
    
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
            VStack(spacing: 0) {
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search by title...", text: $searchText)
                        .foregroundColor(.black)
                }
                .padding(10)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .padding(.horizontal)
                .padding(.bottom, 10)
                .padding(.top, 10)
                
              
                List {
                    ForEach(filteredItems) { item in
                        NavigationLink(value: item) {
                            HStack(spacing: 15) {
                              
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
                                
                                Text(item.title)
                                    .font(.headline)
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                
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
            .background(Color(red: 0.95, green: 0.85, blue: 0.75))
            
            .navigationTitle("WishList")
            .navigationBarTitleDisplayMode(.inline)
            
            .navigationDestination(for: WishlistItem.self) { item in
                WishlistDetailView(item: item)
            }
            
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.black)
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
