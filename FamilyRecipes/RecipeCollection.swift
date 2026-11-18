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

    func contains(recipe: Recipe) -> Bool {
        entries.contains { $0.recipe?.id == recipe.id }
    }

    func add(recipe: Recipe) -> CollectionEntry? {
        guard !contains(recipe: recipe) else {
            return nil
        }

        let position = (entries.map(\.position).max() ?? -1) + 1
        return CollectionEntry(recipe: recipe, collection: self, position: position)
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
