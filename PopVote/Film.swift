//
//  Film.swift
//  PopVote
//
//  Created by Mattia Rizza on 02/11/25.
//

import Foundation
import SwiftData

@Model
final class Film {
    var title: String
    var comment: String
    var rating: Double
    var dateAdded: Date
    var durationMinutes: Int
    
    // <<< NUOVO: Il genere del film >>>
    var genre: String
    
    @Attribute(.externalStorage)
    var posterData: Data?
    
    var folder: Folder?
    
    init(title: String, comment: String, rating: Double, durationMinutes: Int, genre: String, posterData: Data?) {
        self.title = title
        self.comment = comment
        self.rating = rating
        self.durationMinutes = durationMinutes
        self.genre = genre // <<< Salviamo il genere
        self.posterData = posterData
        self.dateAdded = Date()
    }
}
