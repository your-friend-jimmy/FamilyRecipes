import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @State private var isEditing = false
    @State private var isAddingToCollection = false

    var body: some View {
        List {
            if let servings = recipe.servings {
                Text("Serves \(servings)")
                    .foregroundStyle(.secondary)
            }
            if !recipe.ingredients.isEmpty {
                Section("Ingredients") {
                    ForEach(recipe.ingredients.indices, id: \.self) { index in
                        Text(recipe.ingredients[index])
                    }
                }
            }
            if !recipe.steps.isEmpty {
                Section("Steps") {
                    ForEach(recipe.steps.indices, id: \.self) { index in
                        Text("\(index + 1). \(recipe.steps[index])")
                    }
                }
            }
            if let familyNote = recipe.familyNote {
                Section("Family Note") {
                    Text(familyNote)
                }
            }
        }
        .navigationTitle(recipe.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ShareLink(item: recipe.shareText, subject: Text(recipe.title)) {
                    Label("Share Recipe", systemImage: "square.and.arrow.up")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    isEditing = true
                }
            }
            ToolbarItem(placement: .secondaryAction) {
                Button {
                    isAddingToCollection = true
                } label: {
                    Label("Add to Collection", systemImage: "books.vertical.badge.plus")
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            RecipeEditorView(recipe: recipe)
        }
        .sheet(isPresented: $isAddingToCollection) {
            RecipeCollectionPickerView(recipe: recipe)
        }
    }
}
