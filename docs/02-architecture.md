# 02. Architecture

## 1. Module map

1. `modinfo.lua`
- Metadata mod, compatibility flags.

2. `modmain.lua`
- Entry point.
- Build/lookup cache.
- Hook lifecycle vao `widgets/itemtile`.
- Quan ly show/hide board.

3. `scripts/widgets/recipeboard.lua`
- Widget class `RecipeBoard`.
- Render grid icons + nav buttons.
- Handle page action + dedup click.
- Input consume tai layer board.

4. `MOD_STABILITY_RULE.md`
- Rule gate truoc release.

## 2. Responsibility boundaries

1. Data layer (`modmain.lua`)
- Build `RecipeCache`.
- Defensive normalize recipe data.
- Cung cap API noi bo: `GetRecipesForIngredient`.

2. UI layer (`recipeboard.lua`)
- Chi render va xu ly tuong tac board.
- Khong duoc gioi thieu side-effect den gameplay world.

3. Hook layer (`modmain.lua` itemtile post-construct)
- Noi du lieu vao UI theo lifecycle cua itemtile.
- Input ownership: itemtile phai consume khi click nav board.

## 3. Data contracts

1. Recipe cache item shape

```lua
{
  prefab = "axe",
  display_name = "Axe",
  atlas = "images/inventoryimages.xml",
  image = "axe.tex"
}
```

2. Cache map

```lua
RecipeCache[ingredient_type] = { recipe_item_1, recipe_item_2, ... }
```

3. Validity constraints

1. `ingredient_type` phai la string.
2. `atlas` va `image` phai ton tai; neu khong thi bo qua item hoac fallback an toan.
3. Khong insert duplicate `prefab` cho cung ingredient.

## 4. Lifecycle ownership

1. Tao board theo nhu cau (`EnsureRecipeBoard`).
2. Board update khi prefab hover thay doi.
3. Board hide theo grace timer khi roi khoi tile/board.
4. Board clear icon widgets truoc khi rebuild page.

## 5. Side-effect policy

1. Ham render khong duoc mutate cache.
2. Ham cache khong duoc truy cap state input.
3. Ham input khong duoc bypass old handlers khi khong consume action.
