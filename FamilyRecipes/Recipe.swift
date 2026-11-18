import Foundation
import SwiftData

@Model
final class Recipe {
    var id: UUID
    var title: String
    var servings: String?
    var ingredients: [String]
    var steps: [String]
    var familyNote: String?
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \CollectionEntry.recipe)
    var collectionEntries: [CollectionEntry] = []

    init(title: String) {
        id = UUID()
        self.title = title
        ingredients = []
        steps = []
        updatedAt = .now
    }
}
