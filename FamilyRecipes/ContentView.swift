import SwiftData
import SwiftUI

struct ContentView: View {
    @Query(sort: \Recipe.title) private var recipes: [Recipe]
    @State private var isAddingRecipe = false

    var body: some View {
        NavigationStack {
            List(recipes) { recipe in
                NavigationLink {
                    RecipeDetailView(recipe: recipe)
                } label: {
                    Text(recipe.title)
                }
            }
            .overlay {
                if recipes.isEmpty {
                    ContentUnavailableView {
                        Label("No Recipes Yet", systemImage: "book")
                    } actions: {
                        Button("Add Recipe") { isAddingRecipe = true }
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

#Preview {
    ContentView()
        .modelContainer(for: Recipe.self, inMemory: true)
}
