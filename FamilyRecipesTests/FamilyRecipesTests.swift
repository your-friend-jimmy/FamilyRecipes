import Foundation
import SwiftData
import Testing
@testable import FamilyRecipes

struct FamilyRecipesTests {
    @MainActor
    @Test func sharedRecipePreservesWordingAndSectionOrder() {
        let recipe = Recipe(title: "Shoyu Chicken")
        recipe.servings = "4–6"
        recipe.ingredients = ["3 lb chicken thighs", "a splash of shoyu"]
        recipe.steps = ["Mix the sauce.", "Simmer until tender.\nServe with rice."]
        recipe.familyNote = "Auntie’s version."

        #expect(recipe.shareText == """
        Shoyu Chicken

        Serves 4–6

        Ingredients
        3 lb chicken thighs
        a splash of shoyu

        Steps
        1. Mix the sauce.
        2. Simmer until tender.
        Serve with rice.

        Family Note
        Auntie’s version.
        """)
    }

    @MainActor
    @Test func sharedRecipeOmitsEmptySectionsAndReflectsEdits() {
        let recipe = Recipe(title: "Rice")
        #expect(recipe.shareText == "Rice")
        let originalSnapshot = recipe.shareText

        recipe.title = "Steamed Rice"
        recipe.servings = "  "
        recipe.familyNote = "\n"
        recipe.ingredients = ["1 cup rice"]
        #expect(recipe.shareText == "Steamed Rice\n\nIngredients\n1 cup rice")
        #expect(originalSnapshot == "Rice")
    }

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
    @Test func deletingARecipeDeletesItsEntriesAndKeepsItsCollections() throws {
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

        context.delete(recipe)
        try context.save()

        let savedRecipes = try context.fetch(FetchDescriptor<Recipe>())
        let savedCollections = try context.fetch(FetchDescriptor<RecipeCollection>())
        let savedEntries = try context.fetch(FetchDescriptor<CollectionEntry>())

        #expect(savedRecipes.isEmpty)
        #expect(savedCollections.map(\.name) == ["Weeknight Dinners"])
        #expect(savedEntries.isEmpty)
    }

    @MainActor
    @Test func collectionsKeepRecipesIndependentAndPreventDuplicateEntries() throws {
        let schema = Schema([
            Recipe.self,
            RecipeCollection.self,
            CollectionEntry.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext

        let recipe = Recipe(title: "Shoyu Chicken")
        let dinners = RecipeCollection(name: "Weeknight Dinners")
        let favorites = RecipeCollection(name: "Family Favorites")
        context.insert(recipe)
        context.insert(dinners)
        context.insert(favorites)

        let dinnerEntry = try #require(dinners.add(recipe: recipe))
        context.insert(dinnerEntry)
        let favoriteEntry = try #require(favorites.add(recipe: recipe))
        context.insert(favoriteEntry)
        try context.save()

        #expect(dinners.add(recipe: recipe) == nil)

        context.delete(dinnerEntry)
        try context.save()

        let savedRecipes = try context.fetch(FetchDescriptor<Recipe>())
        let savedEntries = try context.fetch(FetchDescriptor<CollectionEntry>())

        #expect(savedRecipes.map(\.title) == ["Shoyu Chicken"])
        #expect(savedEntries.map(\.collection?.name) == ["Family Favorites"])
    }

    @MainActor
    @Test func collectionEntryOrderPersistsAfterSaving() throws {
        let schema = Schema([
            Recipe.self,
            RecipeCollection.self,
            CollectionEntry.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext

        let firstRecipe = Recipe(title: "First")
        let secondRecipe = Recipe(title: "Second")
        let collection = RecipeCollection(name: "Dinner")
        context.insert(firstRecipe)
        context.insert(secondRecipe)
        context.insert(collection)

        let firstEntry = try #require(collection.add(recipe: firstRecipe))
        let secondEntry = try #require(collection.add(recipe: secondRecipe))
        context.insert(firstEntry)
        context.insert(secondEntry)
        try context.save()

        firstEntry.position = 1
        secondEntry.position = 0
        try context.save()

        let descriptor = FetchDescriptor<CollectionEntry>(
            sortBy: [SortDescriptor(\.position)]
        )
        let savedEntries = try context.fetch(descriptor)

        #expect(savedEntries.map { $0.recipe?.title } == ["Second", "First"])
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

    @MainActor
    @Test func recipeTitleSearchMatchesPartialTextIgnoringCase() {
        let recipe = Recipe(title: "Shoyu Chicken")

        #expect(recipe.matchesTitleSearch("HOYU"))
        #expect(recipe.matchesTitleSearch("chicken"))
    }

    @MainActor
    @Test func recipeTitleSearchTrimsTheQueryAndTreatsBlankAsUnfiltered() {
        let recipe = Recipe(title: "Shoyu Chicken")

        #expect(recipe.matchesTitleSearch("  shoyu\n"))
        #expect(recipe.matchesTitleSearch("  \n"))
    }

    @MainActor
    @Test func recipeTitleSearchRejectsUnrelatedText() {
        let recipe = Recipe(title: "Shoyu Chicken")

        #expect(!recipe.matchesTitleSearch("lasagna"))
    }
}
