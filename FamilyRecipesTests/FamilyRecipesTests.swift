import Testing
@testable import FamilyRecipes

struct FamilyRecipesTests {
    @MainActor
    @Test func recipeDraftRequiresATitleAndPreservesLineOrder() {
        var draft = RecipeDraft()
        draft.title = "  "
        #expect(!draft.canSave)

        draft.title = "  Shoyu Chicken  "
        draft.ingredients = "3 lb chicken thighs\n\n a splash of shoyu "
        draft.steps = "Mix the sauce.\nSimmer the chicken."
        #expect(draft.canSave)

        let recipe = Recipe(title: "")
        draft.apply(to: recipe)

        #expect(recipe.title == "Shoyu Chicken")
        #expect(recipe.ingredients == ["3 lb chicken thighs", "a splash of shoyu"])
        #expect(recipe.steps == ["Mix the sauce.", "Simmer the chicken."])
        #expect(recipe.servings == nil)
        #expect(recipe.familyNote == nil)
    }
}
