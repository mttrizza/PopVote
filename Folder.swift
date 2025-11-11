//
//  Folder.swift
//  PopVote
//
//  Created by Mattia Rizza on 31/10/25.
//

import Foundation
import SwiftData

@Model
final class Folder {
    
    var name: String
    
    @Attribute(.externalStorage)
    var iconData: Data?
    
    var dateAdded: Date
    
    // --- MODIFICA QUESTA RIGA ---
    // Cambiamo la regola da .cascade a .nullify
    @Relationship(deleteRule: .nullify)
    var films: [Film]? // Lista di film (opzionale)
    
    init(name: String, iconData: Data?) {
        self.name = name
        self.iconData = iconData
        self.dateAdded = Date()
        self.films = [] // Inizia con un elenco vuoto
    }
}

