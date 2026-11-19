import SwiftData
import SwiftUI

struct RecipeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var isEditing = false
    @State private var isAddingToCollection = false
    @State private var showsDeleteConfirmation = false
    @State private var showsDeleteError = false

    let recipe: Recipe

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
            ToolbarItem(placement: .secondaryAction) {
                Button(role: .destructive) {
                    showsDeleteConfirmation = true
                } label: {
                    Label("Delete Recipe", systemImage: "trash")
                }
            }
        }
        .alert("Delete Recipe?", isPresented: $showsDeleteConfirmation) {
            Button("Delete Recipe", role: .destructive, action: deleteRecipe)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes the recipe from your library and every collection. This action can’t be undone.")
        }
        .alert("Couldn’t Delete Recipe", isPresented: $showsDeleteError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The recipe was not deleted. Try again.")
        }
        .sheet(isPresented: $isEditing) {
            RecipeEditorView(recipe: recipe)
        }
        .sheet(isPresented: $isAddingToCollection) {
            RecipeCollectionPickerView(recipe: recipe)
        }
    }

    private func deleteRecipe() {
        modelContext.delete(recipe)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            showsDeleteError = true
        }
    }
}
