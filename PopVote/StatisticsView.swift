import SwiftUI
import SwiftData

struct StatisticsView: View {
    
    @Query(sort: \Film.rating, order: .reverse) private var allFilms: [Film]
    
    var totalDurationString: String {
        let totalMinutes = allFilms.reduce(0) { $0 + $1.durationMinutes }
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if totalMinutes == 0 { return "0h 0m" }
        return "\(hours)h \(minutes)m"
    }
    
    var favoriteGenreString: String {
        if allFilms.isEmpty { return "None" }
        let genreCounts = Dictionary(grouping: allFilms, by: { $0.genre })
            .mapValues { $0.count }
        if let maxGenre = genreCounts.max(by: { $0.value < $1.value }) {
            return "\(maxGenre.key) (\(maxGenre.value) films)"
        }
        return "None"
    }
    
    func calculateRankings() -> [(rank: Int, film: Film)] {
        var result: [(Int, Film)] = []
        var currentRank = 1
        
        for (index, film) in allFilms.enumerated() {
            if index == 0 {
                result.append((1, film))
            } else {
                let previousFilm = allFilms[index - 1]
                
                if film.rating == previousFilm.rating {
                    result.append((currentRank, film))
                } else {
                    currentRank += 1
                    result.append((currentRank, film))
                }
            }
        }
        return result
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    HStack(spacing: 15) {
                        // Card Time
                        VStack(spacing: 10) {
                            Image(systemName: "clock.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                            Text("Watch Time")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(totalDurationString)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                        
                        // Card Genre
                        VStack(spacing: 10) {
                            Image(systemName: "film.fill")
                                .font(.title)
                                .foregroundColor(.purple)
                            Text("Fav Genre")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(favoriteGenreString.components(separatedBy: " (").first ?? "None")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    Divider().padding(.vertical, 5)
                    
                    // Ranking
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Ranking")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal, 5)
                        
                        ForEach(calculateRankings(), id: \.film.id) { (rank, film) in
                            HStack(spacing: 15) {
                            
                                ZStack {
                                    Circle()
                                        .fill(rankColor(rank: rank))
                                        .frame(width: 30, height: 30)
                                    Text("\(rank)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                
                                Text(film.title)
                                    .font(.headline)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                // Vote
                                HStack(spacing: 4) {
                                    Text(String(format: "%.1f", film.rating))
                                        .fontWeight(.semibold)
                                    Image(systemName: "star.fill")
                                        .font(.caption)
                                        .foregroundColor(.yellow)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.black.opacity(0.05))
                                .clipShape(Capsule())
                            }
                            .padding()
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(alignment: .topTrailing) {
                                if rank == 1 {
                                    Image(systemName: "trophy.fill")
                                        .foregroundColor(.yellow)
                                        .padding(8)
                                        .shadow(radius: 1)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(red: 0.95, green: 0.85, blue: 0.75))
        }
    }
    
    private func rankColor(rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue.opacity(0.7) 
        }
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: Film.self, inMemory: true)
}
