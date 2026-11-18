import SwiftData
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Recipes", systemImage: "book") {
                RecipeLibraryView()
            }

            Tab("Collections", systemImage: "books.vertical") {
                CollectionLibraryView()
            }
        }
    }
}

struct RecipeLibraryView: View {
    @Query(sort: \Recipe.title) private var recipes: [Recipe]
    @State private var isAddingRecipe = false

    var body: some View {
        NavigationStack {
            List(recipes) { recipe in
                NavigationLink {
                    RecipeDetailView(recipe: recipe)
                } label: {
                    RecipeRow(title: recipe.title)
                }
            }
            .overlay {
                if recipes.isEmpty {
                    ContentUnavailableView {
                        Label("No Recipes Yet", systemImage: "book")
                    } actions: {
                        Button("Add Recipe") {
                            isAddingRecipe = true
                        }
                    }
                }
            }
            .navigationTitle("Recipes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isAddingRecipe = true
                    } label: {
                        Label("Add Recipe", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingRecipe) {
                RecipeEditorView()
            }
        }
    }
}

struct RecipeRow: View {
    let title: String

    var body: some View {
        Text(title)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            Recipe.self,
            RecipeCollection.self,
            CollectionEntry.self,
        ], inMemory: true)
}
