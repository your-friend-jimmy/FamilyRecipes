import Foundation
import SwiftData

@Model
final class RecipeCollection {
    var id: UUID
    var name: String

    @Relationship(deleteRule: .cascade, inverse: \CollectionEntry.collection)
    var entries: [CollectionEntry] = []

    init(name: String) {
        id = UUID()
        self.name = name
    }
}

@Model
final class CollectionEntry {
    var id: UUID
    var position: Int
    @Attribute(.unique) var collectionRecipeKey: String

    var recipe: Recipe?
    var collection: RecipeCollection?

    init(recipe: Recipe, collection: RecipeCollection, position: Int) {
        id = UUID()
        self.recipe = recipe
        self.collection = collection
        self.position = position
        collectionRecipeKey = "\(collection.id.uuidString)-\(recipe.id.uuidString)"
    }
}
