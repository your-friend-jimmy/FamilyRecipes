import Foundation
import SwiftData
import Testing
@testable import FamilyRecipes

struct FamilyRecipesTests {
    @MainActor
    @Test func recipeDraftRequiresATitleAndPreservesLineOrder() {
        var draft = RecipeDraft()
        draft.title = "  "
        #expect(!draft.canSave)

        draft.title = "  Shoyu Chicken  "
        draft.ingredients = "3 lb chicken thighs\n\n a splash of shoyu "
        draft.steps = "Mix the sauce.\nSimmer the chicken."
        #expect(draft.canSave)

        let recipe = Recipe(title: "")
        draft.apply(to: recipe)

        #expect(recipe.title == "Shoyu Chicken")
        #expect(recipe.ingredients == ["3 lb chicken thighs", "a splash of shoyu"])
        #expect(recipe.steps == ["Mix the sauce.", "Simmer the chicken."])
        #expect(recipe.servings == nil)
        #expect(recipe.familyNote == nil)
    }

    @MainActor
    @Test func deletingACollectionDeletesItsEntriesAndKeepsItsRecipes() throws {
        let schema = Schema([
            Recipe.self,
            RecipeCollection.self,
            CollectionEntry.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext

        let recipe = Recipe(title: "Shoyu Chicken")
        let collection = RecipeCollection(name: "Weeknight Dinners")
        let entry = CollectionEntry(recipe: recipe, collection: collection, position: 0)

        context.insert(recipe)
        context.insert(collection)
        context.insert(entry)
        try context.save()

        context.delete(collection)
        try context.save()

        let savedRecipes = try context.fetch(FetchDescriptor<Recipe>())
        let savedEntries = try context.fetch(FetchDescriptor<CollectionEntry>())

        #expect(savedRecipes.map(\.title) == ["Shoyu Chicken"])
        #expect(savedEntries.isEmpty)
    }

    @MainActor
    @Test func milestoneOneStoreOpensWithTheCollectionSchema() throws {
        let directory = URL.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: directory)
        }

        let storeURL = directory.appending(path: "FamilyRecipes.store")
        let milestoneOneSchema = Schema([
            Item.self,
            Recipe.self,
        ])

        do {
            let configuration = ModelConfiguration(schema: milestoneOneSchema, url: storeURL)
            let container = try ModelContainer(for: milestoneOneSchema, configurations: [configuration])
            let context = container.mainContext

            context.insert(Recipe(title: "Existing Recipe"))
            try context.save()
        }

        let updatedSchema = Schema([
            Item.self,
            Recipe.self,
            RecipeCollection.self,
            CollectionEntry.self,
        ])
        let configuration = ModelConfiguration(schema: updatedSchema, url: storeURL)
        let container = try ModelContainer(for: updatedSchema, configurations: [configuration])
        let recipes = try container.mainContext.fetch(FetchDescriptor<Recipe>())

        #expect(recipes.map { $0.title } == ["Existing Recipe"])
    }
}
