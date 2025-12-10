import SwiftUI
import PhotosUI
import SwiftData

struct AddWishlistView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var selectedPosterItem: PhotosPickerItem?
    @State private var selectedPosterData: Data?
    
    var body: some View {
        NavigationStack {
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
                            Image(systemName: "popcorn.fill")
                                .font(.system(size: 80)).foregroundColor(.gray)
                                .frame(width: 150, height: 200)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        Text("Add Poster").font(.caption).foregroundColor(.blue)
                    }
                }
                .onChange(of: selectedPosterItem) {
                    Task {
                        if let data = try? await selectedPosterItem?.loadTransferable(type: Data.self) {
                            selectedPosterData = data
                        }
                    }
                }
                
                
                TextField("Movie Title needed", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                Spacer()
                
                Button("Save to WishList") {
                    let newItem = WishlistItem(title: title, posterData: selectedPosterData)
                    modelContext.insert(newItem)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(title.isEmpty)
                .padding(.bottom)
            }
            .padding(.top)
            .navigationTitle("Add to Wishlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .background(Color(red: 0.95, green: 0.85, blue: 0.75))
        }
    }
}

#Preview {
    AddWishlistView()
}
