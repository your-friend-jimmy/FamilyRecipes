# Family Recipe App Product Brief

**Working draft · November 17, 2026**

Help families save the recipes they actually cook, pass them around in Messages, and turn a collection into a cookbook they can print. Start with an iPhone app for the person who already keeps the family's recipes in texts, notes, or on paper.

## First release

| Feature | What a family can do | Release check |
|---|---|---|
| Recipe library | Add, edit, and find recipes by title. Save ingredients, steps, servings, and an optional family note. | A handwritten-style recipe with entries like “a splash of shoyu” survives an edit and app restart. |
| Collections | Group recipes into named collections such as Weeknight Dinners and Family Favorites. Put a recipe in multiple collections. | Removing a recipe from a collection preserves it in the library and in other collections. |
| Recipe sharing | Send a formatted recipe through the iOS share sheet. | A recipient can read the full recipe in Messages without installing the app. |
| Printable cookbooks | Preview a collection as a US Letter PDF with a cover and recipes in the chosen order. Share or print from the preview. | A long recipe flows onto additional pages without clipping ingredients or steps. |

Treat sharing as sending a snapshot. Edits stay with the saved recipe, and a fresh share or export reflects the updated version. Preserve recipe attribution with the optional family note, such as “Auntie's version.”

## Grocery savings experiment

Start by learning whether families would use an estimated cost per serving to choose between dinners. Test a manual price-entry prototype with meals they already cook. If it proves useful, calculate using the fraction of each package consumed and show estimated recipe total and cost per serving. Keep checkout cost distinct from ingredient cost. For example, using a quarter of an $8 package adds $2 to the recipe even if buying the package costs $8. Show a partial estimate when prices or unit conversions are missing.

## Decisions to revisit

- **Shared editing.** Use text sharing for the first release. Revisit a private shared family library if testers regularly ask to contribute or keep the same recipe updated.
- **Recipe capture.** Begin with manual entry. Compare photo capture and web import after observing where testers keep their recipes.
- **Cookbook design.** Start with one printer-friendly layout. Test whether families want recipe photos, chapter dividers, or a photo cover.

## What to learn from the first beta

Ask three families to add a real recipe, send it to a relative, and make a small cookbook. See where they need help, whether the recipient can use the recipe directly from the message, and whether the exported PDF is something they would print or give away. Ask them to bring one recent grocery receipt to the follow-up so you can test costing with their actual prices.
