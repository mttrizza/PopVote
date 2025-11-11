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
    
    // <<< MODIFICA: Da Int a Double >>>
    var rating: Double // Voto da 0.0 a 5.0
    
    var dateAdded: Date
    
    @Attribute(.externalStorage)
    var posterData: Data?
    
    var folder: Folder?
    
    // <<< MODIFICA: Aggiorna il tipo qui nell'init >>>
    init(title: String, comment: String, rating: Double, posterData: Data?) {
        self.title = title
        self.comment = comment
        self.rating = rating // Ora accetta un Double
        self.posterData = posterData
        self.dateAdded = Date()
    }
}
