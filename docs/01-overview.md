# 01. Project Overview

## 1. Problem statement

Trong DST, nguoi choi thuong mat thoi gian de mo crafting tree de tim xem mot nguyen lieu dang co craft duoc gi.
`Ingredient-Insight` giai quyet bang cach hien recipe board khi hover item trong inventory.

## 2. Product vision

1. Nhanh: hover la thay thong tin craft lien quan.
2. Nhe: khong tao tai nguyen du thua moi frame.
3. On dinh: khong crash khi load mod, khong nil runtime, khong click-through.
4. De mo rong: co the them filter/tooltip/interaction trong tuong lai.

## 3. Scope hien tai

1. Build recipe cache tu `AllRecipes`.
2. Hook vao `widgets/itemtile` de bat lifecycle focus/hover.
3. Render board co pagination.
4. Hien ten recipe duoc hover.
5. Consume input de tranh xung dot voi inventory controls.

## 4. Out of scope

1. Khong thay doi game balance.
2. Khong can server sync (client-only mod).
3. Khong xu ly logic progression/unlock recipe cua tung player.

## 5. High-level execution model

1. Game load mod.
2. `modmain.lua` hook `itemtile`.
3. Cache duoc build lazy + post-init.
4. User hover item.
5. Board render recipe icons.
6. User click prev/next, board consume click.

## 6. Non-functional requirements

1. Strict-mode safe.
2. Defensive nil/asset checks.
3. Khong duplicate click action.
4. Khong click-through sang world/item action.
5. De debug qua prefix log duy nhat: `[IngredientInsight]`.
