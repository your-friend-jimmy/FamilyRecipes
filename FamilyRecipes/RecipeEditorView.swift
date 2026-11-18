import SwiftData
import SwiftUI

struct RecipeEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var draft: RecipeDraft
    @State private var showsSaveError = false

    private let recipe: Recipe?

    init(recipe: Recipe? = nil) {
        self.recipe = recipe
        _draft = State(initialValue: RecipeDraft(recipe: recipe))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Recipe") {
                    TextField("Title", text: $draft.title)
                    TextField("Servings", text: $draft.servings)
                }
                Section {
                    TextEditor(text: $draft.ingredients)
                        .frame(minHeight: 80)
                        .accessibilityLabel("Ingredients")
                } header: {
                    Text("Ingredients")
                } footer: {
                    Text("Enter one ingredient per line.")
                }
                Section {
                    TextEditor(text: $draft.steps)
                        .frame(minHeight: 80)
                        .accessibilityLabel("Steps")
                } header: {
                    Text("Steps")
                } footer: {
                    Text("Enter one step per line.")
                }
                Section("Family Note") {
                    TextField("Optional note", text: $draft.familyNote, axis: .vertical)
                        .lineLimit(2...6)
                }
            }
            .navigationTitle(recipe == nil ? "New Recipe" : "Edit Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(!draft.canSave)
                }
            }
            .alert("Couldn’t Save Recipe", isPresented: $showsSaveError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your draft is still open. Try saving again.")
            }
        }
    }

    private func save() {
        guard draft.canSave else { return }

        let recipeToSave = recipe ?? Recipe(title: draft.title)
        draft.apply(to: recipeToSave)
        if recipe == nil {
            modelContext.insert(recipeToSave)
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            showsSaveError = true
        }
    }
}
