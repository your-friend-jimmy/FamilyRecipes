import SwiftData
import SwiftUI

struct CollectionLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RecipeCollection.name) private var collections: [RecipeCollection]
    @State private var isCreatingCollection = false
    @State private var showsSaveError = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(collections) { collection in
                    NavigationLink {
                        CollectionDetailView(collection: collection)
                    } label: {
                        CollectionRow(name: collection.name, recipeCount: collection.entries.count)
                    }
                }
                .onDelete(perform: deleteCollections)
            }
            .overlay {
                if collections.isEmpty {
                    ContentUnavailableView {
                        Label("No Collections Yet", systemImage: "books.vertical")
                    } actions: {
                        Button("Create Collection") {
                            isCreatingCollection = true
                        }
                    }
                }
            }
            .navigationTitle("Collections")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isCreatingCollection = true
                    } label: {
                        Label("Create Collection", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isCreatingCollection) {
                CollectionEditorView()
            }
            .alert("Couldn’t Save Collection", isPresented: $showsSaveError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Try again.")
            }
        }
    }

    private func deleteCollections(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(collections[index])
        }

        saveChanges()
    }

    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            showsSaveError = true
        }
    }
}

struct CollectionRow: View {
    let name: String
    let recipeCount: Int

    var body: some View {
        HStack {
            Text(name)
            Spacer()
            Text("\(recipeCount)")
                .foregroundStyle(.secondary)
        }
    }
}

struct CollectionEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var name = ""
    @State private var showsSaveError = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("Collection Name", text: $name)
            }
            .navigationTitle("New Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("Couldn’t Save Collection", isPresented: $showsSaveError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your collection is still open. Try saving again.")
            }
        }
    }

    private func save() {
        let collection = RecipeCollection(name: name.trimmingCharacters(in: .whitespacesAndNewlines))
        modelContext.insert(collection)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            showsSaveError = true
        }
    }
}

struct CollectionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var entries: [CollectionEntry]
    @State private var showsSaveError = false

    let collection: RecipeCollection

    init(collection: RecipeCollection) {
        self.collection = collection
        let collectionID = collection.id
        _entries = Query(
            filter: #Predicate<CollectionEntry> { entry in
                entry.collection?.id == collectionID
            },
            sort: \CollectionEntry.position
        )
    }

    var body: some View {
        List {
            ForEach(entries) { entry in
                CollectionEntryRow(title: entry.recipe?.title ?? "Missing Recipe")
            }
            .onDelete(perform: removeEntries)
            .onMove(perform: moveEntries)
        }
        .overlay {
            if entries.isEmpty {
                ContentUnavailableView {
                    Label("No Recipes Yet", systemImage: "book")
                } description: {
                    Text("Add recipes from the recipe detail screen.")
                }
            }
        }
        .navigationTitle(collection.name)
        .toolbar {
            EditButton()
        }
        .alert("Couldn’t Save Collection", isPresented: $showsSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your changes were not saved. Try again.")
        }
    }

    private func removeEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(entries[index])
        }

        saveChanges()
    }

    private func moveEntries(from source: IndexSet, to destination: Int) {
        var reorderedEntries = entries
        reorderedEntries.move(fromOffsets: source, toOffset: destination)

        for (position, entry) in reorderedEntries.enumerated() {
            entry.position = position
        }

        saveChanges()
    }

    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            showsSaveError = true
        }
    }
}

struct CollectionEntryRow: View {
    let title: String

    var body: some View {
        Text(title)
    }
}

struct RecipeCollectionPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RecipeCollection.name) private var collections: [RecipeCollection]
    @State private var showsSaveError = false

    let recipe: Recipe

    var body: some View {
        NavigationStack {
            List(collections) { collection in
                Button {
                    add(recipe, to: collection)
                } label: {
                    CollectionPickerRow(
                        name: collection.name,
                        containsRecipe: collection.contains(recipe: recipe)
                    )
                }
                .disabled(collection.contains(recipe: recipe))
            }
            .overlay {
                if collections.isEmpty {
                    ContentUnavailableView {
                        Label("No Collections Yet", systemImage: "books.vertical")
                    } description: {
                        Text("Create a collection first, then add this recipe to it.")
                    }
                }
            }
            .navigationTitle("Add to Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Couldn’t Save Collection", isPresented: $showsSaveError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("The recipe was not added. Try again.")
            }
        }
    }

    private func add(_ recipe: Recipe, to collection: RecipeCollection) {
        guard let entry = collection.add(recipe: recipe) else {
            return
        }

        modelContext.insert(entry)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            showsSaveError = true
        }
    }
}

struct CollectionPickerRow: View {
    let name: String
    let containsRecipe: Bool

    var body: some View {
        HStack {
            Text(name)
            Spacer()
            if containsRecipe {
                Image(systemName: "checkmark")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
