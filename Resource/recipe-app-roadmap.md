# Family Recipes Roadmap

**Living roadmap · Updated November 19, 2026**

This document is the current guide for finishing the first release of Family Recipes. The [product brief](recipe-app-product-brief.md) defines the user outcomes, while the [original build plan](recipe-app-build-plan.md) records the initial implementation sequence.

## First-release goal

Ship an iPhone app that lets a family member:

1. Save and edit the recipes they actually cook without losing familiar wording.
2. Organize a recipe into one or more ordered collections.
3. Send a readable recipe snapshot through the iOS share sheet.
4. Preview, share, and print a collection as a US Letter cookbook PDF.

The first release is ready for beta when all four flows work with real family recipes after closing and reopening the app.

## Status at a glance

| Area | Status | What remains |
|---|---|---|
| Recipe library | **Partial** | Finish release-flow UI tests. |
| Collections | **Partial** | Verify membership, removal, ordering, and persistence edge cases through the UI. |
| Recipe sharing | **Partial** | Formatted text and the share sheet exist; validate the received message on a real device. |
| Printable cookbooks | **Next** | Build PDF generation, preview, sharing, and printing. |
| Release quality | **Next** | Complete accessibility, error-state, persistence, and end-to-end checks. |
| Family beta | **Later** | Run the product-brief tasks with three families after release blockers are cleared. |

The app currently builds successfully for testing. Existing automated coverage checks recipe validation and wording, share formatting, collection deletion and independence, duplicate prevention, saved ordering, and migration from the earlier recipe-only store.

## Milestone 1 — Finish the recipe library and collections

**Outcome:** Saving, finding, deleting, and organizing recipes is dependable enough to support cookbook export.

- [x] Add case-insensitive recipe search by title with an appropriate no-results state.
- [x] Add recipe deletion from the recipe detail screen with confirmation.
- [x] Ensure deleting a recipe removes its collection entries without deleting its collections.
- [x] Verify collection names cannot be saved when blank after trimming whitespace.
- [x] Verify a recipe can belong to multiple collections and cannot appear twice in one collection.
- [x] Verify removing a recipe from one collection preserves the recipe and its other memberships.
- [x] Verify collection recipe order survives app relaunch.
- [ ] Add UI coverage for create, edit, cancel, search, collection membership, reordering, and destructive confirmation flows.

**Complete when:** A tester can add a handwritten-style recipe, edit and find it, place it in two collections, reorder it, remove it from one collection, and relaunch without losing wording, membership, or order.

## Milestone 2 — Export a printable cookbook

**Outcome:** An ordered collection can become a readable PDF that the user previews and then shares or prints.

- [ ] Define a printable cookbook representation that consumes a collection snapshot in its saved recipe order.
- [ ] Generate a US Letter PDF with a collection-name cover, recipe titles, servings, ingredients, numbered steps, family notes, and page numbers.
- [ ] Flow long recipes onto additional pages without clipping or overlapping content.
- [ ] Present a preview of the generated PDF from collection detail.
- [ ] Share or print the same previewed file through the system share sheet.
- [ ] Give an empty collection a clear explanation instead of generating an empty cookbook.
- [ ] Remove temporary export files when they are no longer needed.
- [ ] Add tests for content order, optional sections, empty collections, pagination, and export failure handling.

**Complete when:** An empty collection is handled clearly, a short cookbook previews and shares, and a multi-page recipe prints on US Letter paper without clipped ingredients or steps.

## Milestone 3 — Release-quality pass

**Outcome:** The four primary flows are understandable, accessible, and resilient on a supported iPhone.

- [ ] Audit VoiceOver labels, traits, focus order, and meaningful announcements on every primary flow.
- [ ] Verify Dynamic Type through accessibility sizes without hiding actions or recipe content.
- [ ] Check sufficient color contrast in light and dark appearances.
- [ ] Replace generic failure messages where a recovery action can be offered.
- [ ] Verify saved data survives termination, relaunch, and the current schema migration path.
- [ ] Test empty, minimal, typical, and very long recipes and collections.
- [ ] Run the full unit and UI test suites and resolve warnings or flaky tests.
- [ ] Perform device checks for sharing to Messages and printing or saving the cookbook PDF.

**Complete when:** All automated checks pass, the app builds without errors, no accessibility blocker remains in a primary flow, and the complete save–organize–share–print journey succeeds on a real device.

## Milestone 4 — Three-family beta

**Outcome:** Confirm that families can use the app with their own material and that the output is worth sharing or printing.

Ask three families to:

1. Add and edit one real recipe.
2. Send it to a relative who does not have the app.
3. Create a small ordered collection.
4. Preview and print or share its cookbook.

Record where testers pause, what they misunderstand, whether the recipient can cook from the message, and whether the PDF is something they would print or give away. Fix any blocker that prevents saving, sending, or printing before the first release.

**Complete when:** Every family completes the primary journey, all blocking findings are resolved or explicitly accepted, and the remaining feedback is categorized for a later release.

## Milestone 5 — First-release readiness

- [ ] Confirm the app name, icon, version, deployment target, signing, and release build configuration.
- [ ] Prepare concise onboarding or empty-state guidance where beta testing showed a need.
- [ ] Review user-facing copy and accessibility metadata.
- [ ] Run a clean release build and final regression pass.
- [ ] Archive the build and complete the chosen distribution workflow.

**Complete when:** A release build passes the regression checklist and is ready for the selected beta or App Store distribution channel.

## Deferred experiments

These ideas are intentionally outside the first-release completion path:

- **Grocery savings:** Prototype manual price entry and estimated cost per serving only after the core beta. Keep checkout cost distinct from the fraction of ingredient cost used, and permit partial estimates.
- **Shared editing:** Revisit a private shared family library if testers repeatedly ask to contribute to or synchronize the same recipes.
- **Recipe capture:** Compare photo capture and web import after observing where testers currently keep recipes.
- **Cookbook design options:** Consider recipe photos, chapter dividers, alternate layouts, and photo covers after validating the printer-friendly layout.

## Completing roadmap items

Use one branch per roadmap item. When the item is implemented, require the full test suite and a successful build before integration. For a small, self-contained change, merge the branch locally into `main`, run the tests again on the merged result, push `main`, and delete the finished branch. Pull from the remote only to synchronize before merging; pulling is not itself a completion step.

Push the feature branch and open a pull request instead when the change affects persistence or migrations, security, release configuration, or needs another person’s review. Do not check off the roadmap item until its completion check has been exercised.

## Keeping this roadmap current

Update the date and status table whenever a milestone changes. Check off work only after its completion check has been exercised, and add newly discovered release blockers to the milestone that owns the affected user flow. Product ideas that do not block the first-release goal belong in **Deferred experiments** rather than the active milestones.
