# 06. Coding Standards

## 1. Lua/DST strict safety

1. Khong dung bien global ngau nhien.
2. Khong assign vao bien chua khai bao.
3. O file widget, tranh phu thuoc vao context global khong dam bao.

## 2. Defensive data handling

1. Truoc khi truy cap field, check type/table.
2. Du lieu recipe can guard:
- `recipe_data`
- `ingredients`
- `ingredient_data.type`
- `product_prefab`
3. Neu data khong hop le, skip entry thay vi error.

## 3. Asset safety

1. Tao image/button qua wrapper `pcall` neu co rui ro.
2. Dung candidate fallback chain cho background.
3. Neu icon item khong tao duoc, bo qua icon do.

## 4. Input standards

1. Event handled => return `true` ngay.
2. Event unhandled => delegate old handler.
3. Co dedupe de tranh double-action.

## 5. Lifecycle standards

1. Create-on-demand cho board.
2. `Clear()` truoc khi rebuild page.
3. Destroy path phai cleanup child widgets.
4. Hover transfer dung grace timer, khong hide lap tuc.

## 6. Logging standards

1. Prefix duy nhat: `[IngredientInsight]`.
2. Log cac transition quan trong:
- show/hide
- page prev/next
- consume click
- mismatch/release edge case
3. Ban release giam log verbose neu can.

## 7. Documentation standards

1. Moi thay doi luong input phai update [04-input-routing.md](04-input-routing.md).
2. Moi crash moi phai update [08-failure-catalog.md](08-failure-catalog.md).
3. Moi thay doi release gate phai update [09-release-checklist.md](09-release-checklist.md).
