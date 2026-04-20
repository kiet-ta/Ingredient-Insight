# 08. Failure Catalog

## 1. Strict crash: GLOBAL not declared

1. Symptom
- Crash ngay khi Apply mod.

2. Signature
- `variable 'GLOBAL' is not declared`
- Stacktrace tro vao `scripts/widgets/recipeboard.lua` o line dau.

3. Root cause
- Dung GLOBAL trong context strict khong khai bao.

4. Fix
- Loai bo phu thuoc GLOBAL o widget file.
- Dung alias an toan tu global ton tai.

5. Prevention
- Review strict-safe cho tat ca file moi.

## 2. Click-through on nav buttons

1. Symptom
- Hover button co animation.
- Click left lai pick/drop item.

2. Signature
- Page doi khong on dinh hoac world/item action bi trigger cung luc.

3. Root cause
- Event khong duoc consume o layer itemtile.

4. Fix
- Hook `OnControl` + `OnMouseButton` tai itemtile.
- Consume neu board dang hover nav action.

5. Prevention
- Rule: handled event phai return true ngay.

## 3. Double page turn

1. Symptom
- 1 click doi 2 trang.

2. Root cause
- Down/up duoc xu ly boi nhieu hook ma khong dedupe.

3. Fix
- Dedupe bang state `_ii_nav_pressed_action` + timestamp window.

## 4. UI asset fallback fail

1. Symptom
- Crash hoac board khong render background/icon.

2. Root cause
- Atlas/tex khong ton tai o build hien tai.

3. Fix
- Dung fallback chain + `pcall` wrapper khi tao image/button.

## 5. Flicker khi di chuyen chuot

1. Symptom
- Board tat ngay khi move tu item sang board.

2. Root cause
- Hide lap tuc o OnLoseFocus.

3. Fix
- Grace timer 0.18s + re-check hover ancestry.

## 6. Empty board du item hop le

1. Symptom
- Hover item nhung khong hien recipe.

2. Root cause
- Cache chua build.
- Data recipe khong hop le bi skip.

3. Fix
- Build cache o post-init + lazy guard.
- Them log cache count de xac nhan.
