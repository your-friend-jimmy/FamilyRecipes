//
//  FamilyRecipesApp.swift
//  FamilyRecipes
//
//  Created by James Phillips on 11/17/26.
//

import Foundation
import SwiftData
import SwiftUI

@main
struct FamilyRecipesApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            Recipe.self,
            RecipeCollection.self,
            CollectionEntry.self,
        ])
        let isUITesting = ProcessInfo.processInfo.arguments.contains("--ui-testing")
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isUITesting)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
