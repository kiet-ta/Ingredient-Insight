# Rule 01: Deterministic UI Input and Lifecycle Safety (DST Mods)

This rule defines the minimum engineering standard to prevent mod-load failures, runtime crashes, and unstable UI behavior in Don't Starve Together mods.

Use this as a hard gate before release.

## Goal

Build UI-driven mods that:

- Do not crash on load (strict-mode safe)
- Do not crash during gameplay (nil-safe and asset-safe)
- Do not leak input to world actions (no accidental click-through)
- Do not process one click multiple times
- Keep widget lifecycle stable during hover/focus transitions

## Root-Cause Incidents Fixed In This Session

1. Hover detection failed when cursor was over child widgets
- Symptom: Panel disappeared or never appeared even when setup looked correct.
- Root cause: Logic compared exact widget identity instead of checking the parent chain.
- Fix: Use recursive ancestry check `IsWidgetOrDescendant(widget, root)` everywhere hover intent is evaluated.

2. Panel closed while moving cursor from item to panel
- Symptom: UI flicker and unusable transition from inventory tile to panel.
- Root cause: `OnLoseFocus` hid the panel immediately with no transfer window.
- Fix: Add a short linger/grace timer (`0.18s`) before hiding, then re-check hover target.

3. Pagination click fell through to game world action
- Symptom: Player speech/action triggered (for example gift action) instead of page turn.
- Root cause: Click was not consumed at the correct input layer.
- Fix: Intercept primary click at UI layers, route to paging handler, and return `true` to consume handled events.

4. Strict-mode load crash from undeclared global assignment
- Symptom: Mod crashed at load with "assign to undeclared variable".
- Root cause: Runtime assignment to a non-declared global variable.
- Fix: Use module-local state (`local ActiveRecipeBoard = nil`) instead of global writes.

5. Single click turned two pages
- Symptom: One click advanced two pages.
- Root cause: Same click handled by both itemtile and hoverer hooks.
- Fix: Centralize click handling in one helper and deduplicate with per-click state (`_ii_click_processed`) using down/up gating.

## Mandatory Engineering Rule

All interactive HUD mods must implement one deterministic input path with explicit event consumption and lifecycle-safe widget state.

If more than one hook can receive the same input, deduplication is mandatory.

## Clean Code and Game Engineering Standard (Required)

This section extends the stability rule with code quality conventions that must be applied to all new gameplay/UI modules.

### A. DRY with Correct Abstraction Timing

- Keep each piece of changing knowledge in one authoritative place (single source of truth).
- Centralize shared logic such as input classification, hover ancestry checks, and paging transitions.
- Do not over-abstract too early. Duplicate once if needed, then extract only after behavior stabilizes.
- Prefer helper functions over copy-paste branches when a bug fix must be applied in multiple call sites.

### B. KISS for Runtime-Critical Paths

- Keep hot-path logic small and predictable.
- Prefer explicit condition chains over clever but opaque control flow.
- Minimize hidden side effects in callbacks.
- Any function handling per-frame update or input should be readable in under one screen without jumping files.

### C. SOLID Adapted for Mod Architecture

- Single Responsibility: each module handles one concern (input routing, rendering, caching, lifecycle).
- Open/Closed: add new behaviors via extension points instead of rewriting stable core flow.
- Liskov: replacement widgets/hooks must preserve expected behavior contracts.
- Interface Segregation: expose narrow helper APIs; avoid broad utility bags.
- Dependency Inversion: depend on local abstractions/helpers, not direct scattered engine calls in every branch.

### D. Data-Oriented and Deterministic Game Rules

- Design for deterministic outcomes under repeated input (same click -> same effect).
- Keep state transitions explicit: visible/hidden, focused/unfocused, processed/unprocessed.
- Prefer data tables and constants over magic numbers in logic branches.
- Make frame-critical code path allocation-light and branch-light.

### E. Performance and Memory Discipline

- Profile first, then optimize bottlenecks (do not optimize blindly).
- Prevent avoidable allocations in frequent update paths.
- Reuse widgets/objects where possible; clear and recycle safely.
- Cache expensive lookups that are stable across frames.
- Retest after each optimization; reject changes that reduce readability without measurable gain.

### F. Defensive Reliability Contracts

- Validate all external/engine data before access.
- Fail safely: if data is invalid, skip rendering/action instead of throwing runtime errors.
- Keep fallback assets for UI resources.
- Keep debug logging togglable with a single flag and disable verbose logs for release.

### G. Mod Evolution and Compatibility

- New features must not regress existing interaction contracts.
- Preserve backward-compatible defaults for config and controls.
- Add feature flags for experimental behavior where practical.
- Document assumptions and invariants inside the rule and code comments when non-obvious.

## Required Implementation Pattern

### 1. Input Ownership and Consumption

- Define what controls are "primary click" in one place.
- Route all page/button actions through a single helper function.
- If action is handled, return `true` immediately.
- Do not allow handled clicks to bubble to world/gameplay controls.

### 2. Multi-Hook Deduplication

- Expect duplicate delivery when both focused widget hook and global hover hook are active.
- Use press/release state:
  - On `down`: reset processed flag
  - On `up`: first valid handler sets processed flag and executes action
  - Any later handler in same click cycle exits early

### 3. Hover/Focus Stability

- Never assume cursor remains on the same root widget.
- Use ancestry checks for both tile and panel.
- Apply a small transfer grace window before hide.
- Only hide after grace expires and both tile/panel are not under cursor.

### 4. Strict-Mode and Scope Discipline

- No undeclared globals.
- All shared runtime state must be declared `local` at module level.
- Avoid implicit global creation in callbacks.

### 5. Defensive Data/Asset Handling

- Guard all external tables with type checks (`AllRecipes`, ingredients, item fields).
- Resolve atlas dynamically when possible; keep fallback atlas.
- Skip invalid recipe entries safely instead of crashing.

### 6. Widget Lifecycle Safety

- Create-on-demand, reuse when possible, clear on hide when needed.
- Kill child widgets in `Clear()` before rebuilding page content.
- Keep active board pointer synchronized when board is shown/hidden.

## Crash-Prevention Checklist (Release Gate)

Do not release unless every item is checked.

- [ ] No strict-mode error in logs (no undeclared variable assignment)
- [ ] No nil access during hover, click, page turn, or hide/show transitions
- [ ] One click equals one action for all navigation controls
- [ ] No click-through to gameplay/world action when interacting with mod UI
- [ ] Hover transfer from item to panel is stable (no flicker/disappear)
- [ ] Panel visibility is fully tied to intended state (Alt held + valid hover)
- [ ] Paging wraps or bounds correctly across first/last page
- [ ] Board cleanup does not leak widgets across repeated open/close cycles
- [ ] Invalid atlas/image data does not crash UI rendering
- [ ] Mod loads cleanly with no LUA ERROR and no stack traceback
- [ ] DRY compliance: shared logic exists in one helper, not duplicated in multiple handlers
- [ ] KISS compliance: hot-path functions remain simple and side effects are explicit
- [ ] SOLID compliance: responsibilities are separated (input, UI render, cache, lifecycle)
- [ ] Profile-first verification completed for changed hot paths
- [ ] No avoidable per-frame allocations introduced by the change
- [ ] Release build uses reduced logging verbosity

## Validation Procedure (Minimal)

1. Load game with mod enabled and open inventory.
2. Hold Alt, hover multiple ingredient tiles with and without recipes.
3. Move cursor tile -> panel -> tile repeatedly to test transfer grace.
4. Click previous/next fast and slow; verify no double-turn.
5. Confirm no world action triggers while clicking panel controls.
6. Release Alt at different cursor positions; confirm board closes safely.
7. Monitor logs for:
   - `LUA ERROR`
   - `stack traceback`
   - unexpected world action messages during UI click

## Non-Negotiable Anti-Patterns

Never do these in production mods:

- Rely on exact widget equality for hover detection in nested UI trees
- Split identical click action logic across multiple hooks without dedup
- Write to undeclared globals in strict-mode environments
- Assume button `OnClick` alone is enough when focus/input routing is complex
- Hide panels immediately on focus loss without a transition window
- Add abstractions that hide behavior and make debugging harder than the duplicated version
- Optimize unmeasured code while real bottlenecks remain unknown
- Allocate temporary tables/objects every frame in avoidable code paths
- Mix rendering, state mutation, and input ownership in one large callback

## Session-to-Rule Mapping (What Was Solved)

- Solved: Hover ancestry mismatch -> fixed with descendant checks
- Solved: Item-to-panel transition drop -> fixed with grace timer
- Solved: Click-through to world -> fixed with explicit control interception/consumption
- Solved: Strict-mode load crash -> fixed with local module variable
- Solved: Double pagination per click -> fixed with centralized dedup handler

## Reference Implementation (This Repository)

- Main input/lifecycle logic: modmain.lua
- Board rendering and pagination UI: scripts/widgets/recipeboard.lua

This rule is now the baseline quality standard for future DST UI mods.

## External Principles and References

The added quality standards in this rule align with commonly accepted software and game engineering guidance:

- DRY principle and single source of truth conventions
- KISS principle for maintainable and repairable design
- SOLID principles for modular, maintainable architecture
- Game optimization guidance emphasizing profiling-first bottleneck work, deterministic behavior, and controlled memory allocation

Reference pages used while drafting this extension:

- https://en.wikipedia.org/wiki/Don%27t_repeat_yourself
- https://en.wikipedia.org/wiki/KISS_principle
- https://en.wikipedia.org/wiki/SOLID
- https://docs.unity3d.com/Manual/performance-garbage-collection-best-practices.html
- https://docs.unity3d.com/Manual/BestPracticeUnderstandingPerformanceInUnity.html
- https://docs.godotengine.org/en/stable/tutorials/performance/general_optimization.html
- https://docs.godotengine.org/en/stable/tutorials/performance/cpu_optimization.html