import Foundation

struct RecipeDraft {
    var title: String
    var servings: String
    var ingredients: String
    var steps: String
    var familyNote: String

    init(recipe: Recipe? = nil) {
        title = recipe?.title ?? ""
        servings = recipe?.servings ?? ""
        ingredients = recipe?.ingredients.joined(separator: "\n") ?? ""
        steps = recipe?.steps.joined(separator: "\n") ?? ""
        familyNote = recipe?.familyNote ?? ""
    }

    var canSave: Bool {
        nonblank(title) != nil
    }

    func apply(to recipe: Recipe) {
        recipe.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        recipe.servings = nonblank(servings)
        recipe.ingredients = ingredients.split(whereSeparator: \.isNewline).compactMap {
            nonblank(String($0))
        }
        recipe.steps = steps.split(whereSeparator: \.isNewline).compactMap {
            nonblank(String($0))
        }
        recipe.familyNote = nonblank(familyNote)
        recipe.updatedAt = .now
    }

    private func nonblank(_ text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
