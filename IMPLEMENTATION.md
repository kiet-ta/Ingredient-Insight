# Ingredient Insight - Implementation Guide

## Overview
This mod displays a grid of recipe icons when you hover over an ingredient in your Don't Starve Together inventory. It implements a clean, performant architecture using component-based design and lazy-loaded caching.

## Architecture

### 1. **RecipeBoard Widget** (`scripts/widgets/recipeboard.lua`)
Custom UI component that displays recipe icons in a grid layout.

**Key Features:**
- Inherits from DST's `Widget` base class
- Background panel (dark semi-transparent) auto-sizes based on content
- Grid layout: 4 columns max, 40x40 icons, 10px spacing
- Memory-safe: kills old widgets before replacing them
- Lazy initialization: only builds grid when `SetRecipes()` is called

**Key Methods:**
```lua
RecipeBoard:SetRecipes(recipe_list)  -- Load recipes and render icons
RecipeBoard:Clear()                   -- Safely kill all child widgets
RecipeBoard:SetTarget(item_widget)   -- Track current hovered item
```

### 2. **Cache Layer** (`modmain.lua`)
Efficient reverse-index mapping: `ingredient_type -> [recipes]`

**Architecture:**
- Lazy loading: Cache only builds once on first hover
- O(1) lookup: Handle 100+ items without performance penalty
- Deduplication: Checks existing entries before inserting
- Defensive validation: Type checks on all data sources

**Data Structure:**
```lua
RecipeCache = {
    ["flint"] = {
        { prefab = "axe", atlas = "images/inventoryimages.xml", image = "axe.tex" },
        { prefab = "pickaxe", atlas = "...", image = "..." },
        ...
    },
    ["gold_nugget"] = { ... },
    ...
}
```

### 3. **UI Hooking** (modmain.lua - AddClassPostConstruct)
Integrates with DST's hoverer widget (tracks mouse movement over inventory).

**Flow:**
1. Create RecipeBoard as child of hoverer widget
2. Override hoverer's `OnUpdate(dt)` method
3. Each frame: Check if mouse is over an ItemTile
4. If yes → Extract item prefab → Lookup cache → Show board
5. If no → Hide board and cleanup

**Position:** RecipeBoard is offset (60, -50) to avoid overlap with mouse cursor

## Technical Implementation Details

### Defensive Programming
The code implements strict nil checks before accessing properties:
```lua
if hud_entity then
    if hud_entity.widget and hud_entity.widget.item then
        local item_inst = hud_entity.widget.item
        if item_inst and item_inst.prefab then
            -- Safe to use item_inst.prefab here
        end
    end
end
```

### Memory Management
- **Widget Cleanup:** `RecipeBoard:Clear()` kills all icon widgets before recreating
- **Lifecycle:** RecipeBoard destructor calls cleanup
- **Deferred:** Only update when item changes (not every frame)

### Cache Building Algorithm
```lua
for each recipe in AllRecipes:
    for each ingredient in recipe.ingredients:
        if ingredient_type not in RecipeCache:
            create new array
        if product not already in array:
            add it
```

## Customization

### Adjust Grid Size
Edit constants in `scripts/widgets/recipeboard.lua`:
```lua
local ICON_SIZE = 40      -- Icon dimensions (pixels)
local GRID_COLS = 4       -- Max columns before wrapping
local PADDING = 10        -- Space between icons
local BG_PADDING = 15     -- Space inside background panel
```

### Change Background Appearance
```lua
local BG_ATLAS = "images/ui.xml"    -- Asset file
local BG_TEX = "panel_light.tex"    -- Texture name

-- In constructor, modify tint:
self.bg_image:SetTint(0, 0, 0, 0.7)  -- (R, G, B, Alpha)
```

### Adjust Position
In `modmain.lua`, modify the offset:
```lua
self.recipe_board:SetPosition(60, -50, 0)  -- X, Y, Z offset
```

### Filter Recipes
Add a filter function in the cache layer. Example - only show if recipe has ≤ 3 ingredients:
```lua
local function IsValidRecipe(recipe_data)
    if not recipe_data.ingredients then return false end
    return #recipe_data.ingredients <= 3
end

-- Then in BuildRecipeCache(), before adding to cache:
if not IsValidRecipe(recipe_data) then goto skip_recipe end
```

## Debugging

### Enable Cache Logging
In `modmain.lua`, uncomment at the bottom:
```lua
print("[Ingredient Insight] Cache built successfully")
```

### Check if Item is Cached
Add this to console while hovering an item:
```lua
local recipes = GetRecipesForIngredient("flint")  -- Replace with actual prefab
if recipes then print("Found " .. #recipes .. " recipes") end
```

### Verify Widget Hierarchy
In DST console:
```lua
GLOBAL.ThePlayer.HUD.hoverer.recipe_board  -- Should be RecipeBoard instance
```

### Common Issues

**Icons not showing:**
- Atlas/image paths may be incorrect
- Use `"images/inventoryimages.xml"` as fallback
- Check if recipe has `atlas`/`image` fields

**Board appearing in wrong location:**
- Adjust X/Y offset in `SetPosition()`
- May overlap with HUD elements on different resolutions

**Memory leak (board not clearing):**
- Ensure `RecipeBoard:Clear()` is called when hiding
- Check that old icons are being `Kill()`ed not just hidden

## Performance Characteristics

| Operation | Complexity | Notes |
|-----------|-----------|-------|
| Cache build | O(R × I) | Happens once; R=recipes, I=avg ingredients |
| Cache lookup | O(1) | Direct table access |
| Grid layout | O(N) | N=number of recipes in lookup result (usually 5-10) |
| Widget creation | O(N) | Creating Image widgets for each recipe |
| Frame update | O(K) | K=only when hovered item changes |

**Optimization:** Cache is built once and reused. Widget grid updates only when hovered item changes, not every frame.

## Error Handling

The mod includes defensive programming throughout:
- All table access guarded with `type()` checks
- Nil checks before accessing object properties
- Graceful degrade: Returns early if Any precondition fails
- No silent failures: Missing data simply results in no recipes shown

## Mod Compatibility

- **Client-only:** No server-side code required
- **Other clients:** Don't need mod to connect
- **Standalone:** Doesn't modify game balance or server state
- **Recipe source:** Uses vanilla `AllRecipes` - compatible with recipe mods

## File Structure
```
Ingredient-Insight/
├── modinfo.lua                      (mod metadata - api_version_dst = 10)
├── modmain.lua                      (cache layer + hoverer hooking)
├── README.md                        (user-facing guide)
└── scripts/
    └── widgets/
        └── recipeboard.lua          (UI widget for grid display)
```

## Future Enhancements (Optional)

1. **Clickable icons:** Hook into icon clicks to open recipe book
2. **Filtering:** Only show recipes unlocked by player
3. **Localization:** Multi-language support for recipe names
4. **Animation:** Fade in/out transitions
5. **Customizable grid:** Player-adjustable columns/icon size
6. **Hover tooltips:** Show recipe name on icon hover

## References

- Workshop mod reference: `d:\SteamLibrary\steamapps\common\Don't Starve Together\mods\workshop-1120124958\`
- Engineering standards: `f:\AI_Docs\docs\copilot_skill\ENGINEERING_STANDARD.md`
- DST API: Klei's widget system documentation
