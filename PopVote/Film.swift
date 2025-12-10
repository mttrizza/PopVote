import Foundation
import SwiftData

@Model
final class Film {
    var title: String
    var comment: String
    var rating: Double
    var dateAdded: Date
    var durationMinutes: Int
    
    var genre: String
    
    @Attribute(.externalStorage)
    var posterData: Data?
    
    var folder: Folder?
    
    init(title: String, comment: String, rating: Double, durationMinutes: Int, genre: String, posterData: Data?) {
        self.title = title
        self.comment = comment
        self.rating = rating
        self.durationMinutes = durationMinutes
        self.genre = genre 
        self.posterData = posterData
        self.dateAdded = Date()
    }
}
