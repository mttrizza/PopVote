import SwiftUI
import SwiftData

struct FilmDetailView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let film: Film
    
    // Alert
    @State private var isShowingEditSheet = false
    @State private var isShowingDeleteAlert = false
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                HStack {
                    Spacer()
                    if let data = film.posterData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable().scaledToFit().frame(height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 5)
                    } else {
                        Image(systemName: "film")
                            .font(.system(size: 100)).foregroundColor(.gray)
                            .frame(width: 200, height: 300)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    Spacer()
                }
                .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(film.title)
                        .font(.custom("HoltwoodOneSC-Regular", size: 32))
                        .lineLimit(2)
                    
                    HStack {
                        Image(systemName: "star.fill").foregroundColor(.white)
                        Text("\(film.rating, specifier: "%.1f") / 5.0")
                            .font(.title2).fontWeight(.semibold)
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                        
                        let hours = film.durationMinutes / 60
                        let minutes = film.durationMinutes % 60
                        
                        if film.durationMinutes > 0 {
                            Text("\(hours)h \(minutes)m")
                        } else {
                            Text("-- h -- m")
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                if !film.comment.isEmpty {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Comment").font(.headline)
                        Text(film.comment).font(.body)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.black.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Added on: \(film.dateAdded.formatted(date: .long, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(role: .destructive) {
                        isShowingDeleteAlert = true
                    } label: {
                        Text("Delete")
                            .font(.subheadline)
                            .frame(maxWidth: 55)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                
            }
        }

        .background(Color(red: 0.95, green: 0.85, blue: 0.75))
        .scrollContentBackground(.hidden)
        .navigationTitle(film.title)
        .navigationBarTitleDisplayMode(.inline)
        
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    isShowingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $isShowingEditSheet) {
            EditFilmView(film: film)
        }
        
        .alert("Delete \"\(film.title)\"?", isPresented: $isShowingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteFilm()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action is irreversible.")
        }
    }
    
    private func deleteFilm() {
        modelContext.delete(film)
        dismiss()
    }
}
