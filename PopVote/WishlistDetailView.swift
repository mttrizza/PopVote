import SwiftUI
import SwiftData

struct WishlistDetailView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let item: WishlistItem
    
    @State private var isShowingEditSheet = false
    @State private var isShowingAddSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let data = item.posterData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 400)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 8)
                        .padding()
                } else {
                    Image(systemName: "popcorn")
                        .font(.system(size: 100))
                        .foregroundColor(.gray)
                        .frame(height: 300)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding()
                }
                
                Text(item.title)
                    .font(.custom("HoltwoodOneSC-Regular", size: 32))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
        }
        .background(Color(red: 0.95, green: 0.85, blue: 0.75))
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        
        .toolbar {
            
            //edit
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    isShowingEditSheet = true
                }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(.white))
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
            }
            
            // Tik
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    isShowingAddSheet = true
                }) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold)) // Icona più piccola
                        .foregroundColor(.green)
                        .frame(width: 32, height: 32) // <<< CERCHIO RIDOTTO a 32 >>>
                        .background(Circle().fill(.white))
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
            }
        }
        
        // Sheet per Modifica
        .sheet(isPresented: $isShowingEditSheet) {
            EditWishlistView(item: item)
        }
        
        // Sheet per Aggiungere il film (Spostamento)
        .sheet(isPresented: $isShowingAddSheet) {
            AddFilmView(
                prefilledTitle: item.title,
                prefilledPosterData: item.posterData,
                onSaveSuccess: {
                    modelContext.delete(item)
                    dismiss()
                }
            )
        }
    }
}
