import Foundation
import SwiftData
import SwiftUI

@Model
final class WishlistItem {
    var title: String
    
    @Attribute(.externalStorage)
    var posterData: Data?
    
    var dateAdded: Date
    
    init(title: String, posterData: Data? = nil) {
        self.title = title
        self.posterData = posterData
        self.dateAdded = Date()
    }
}
