//
//  WishlistItem.swift
//  PopVote
//
//  Created by Mattia Rizza on [Data Odierna].
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class WishlistItem {
    var title: String
    
    // Usiamo externalStorage per le immagini per non appesantire il database
    @Attribute(.externalStorage)
    var posterData: Data?
    
    var dateAdded: Date
    
    init(title: String, posterData: Data? = nil) {
        self.title = title
        self.posterData = posterData
        self.dateAdded = Date()
    }
}
