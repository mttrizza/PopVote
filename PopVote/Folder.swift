import Foundation
import SwiftData

@Model
final class Folder {
    
    var name: String
    
    @Attribute(.externalStorage)
    var iconData: Data?
    
    var dateAdded: Date
    

    @Relationship(deleteRule: .nullify)
    var films: [Film]?
    
    init(name: String, iconData: Data?) {
        self.name = name
        self.iconData = iconData
        self.dateAdded = Date()
        self.films = [] 
    }
}

