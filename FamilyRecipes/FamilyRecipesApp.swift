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
        let arguments = ProcessInfo.processInfo.arguments
        let modelConfiguration: ModelConfiguration

        if let storeArgumentIndex = arguments.firstIndex(of: "--ui-testing-store"),
           arguments.indices.contains(storeArgumentIndex + 1) {
            let storeName = arguments[storeArgumentIndex + 1]
            let storeURL = URL.temporaryDirectory.appending(path: "FamilyRecipes-\(storeName).store")
            modelConfiguration = ModelConfiguration(schema: schema, url: storeURL)
        } else {
            let isUITesting = arguments.contains("--ui-testing")
            modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isUITesting)
        }

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
