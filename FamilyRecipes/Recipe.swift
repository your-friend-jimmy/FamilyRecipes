import Foundation
import SwiftData

@Model
final class Recipe {
    var id: UUID
    var title: String
    var servings: String?
    var ingredients: [String]
    var steps: [String]
    var familyNote: String?
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \CollectionEntry.recipe)
    var collectionEntries: [CollectionEntry] = []

    func matchesTitleSearch(_ searchText: String) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return query.isEmpty || title.localizedCaseInsensitiveContains(query)
    }

    var shareText: String {
        var sections = [title]

        if let servings, !servings.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            sections.append("Serves \(servings)")
        }
        if !ingredients.isEmpty {
            sections.append("Ingredients\n" + ingredients.joined(separator: "\n"))
        }
        if !steps.isEmpty {
            let numberedSteps = steps.enumerated().map { index, step in
                "\(index + 1). \(step)"
            }
            sections.append("Steps\n" + numberedSteps.joined(separator: "\n"))
        }
        if let familyNote, !familyNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            sections.append("Family Note\n" + familyNote)
        }

        return sections.joined(separator: "\n\n")
    }

    init(title: String) {
        id = UUID()
        self.title = title
        ingredients = []
        steps = []
        updatedAt = .now
    }
}
