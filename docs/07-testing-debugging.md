# 07. Testing and Debugging Playbook

## 1. Test levels

1. Smoke test
- Apply mod.
- Khong crash khi reload.

2. Functional test
- Hover item co recipe.
- Board hien dung.
- Prev/next chay dung.

3. Regression test
- Khong click-through pick/drop.
- Khong double page turn.
- Khong flicker khi move item -> board.

## 2. Manual test matrix

1. State matrix
- Alt hold/release.
- Hover tile/board/outside.
- Item co recipe/khong recipe.

2. Input matrix
- Left click down/up cham.
- Left click nhanh lien tuc.
- Click vao hitbox vo hinh vs visual button.

3. Lifecycle matrix
- Open board lan dau.
- Doi item lien tuc.
- Dong/mo board lap lai nhieu lan.

## 3. Log protocol

1. Prefix filter: `[IngredientInsight]`.
2. Neu crash:
- Lay 40 dong truoc va sau first `LUA ERROR`.
- Xac dinh frame dau tien tro vao file mod.
3. Neu input bug:
- Log source `itemtile_control`, `itemtile_mouse`, `board_control`, `board_mouse`.

## 4. Root-cause tracing method

1. Buoc 1: Tim first-fault, khong nhay vao loi day chuyen.
2. Buoc 2: Khoanh vung theo file/ham.
3. Buoc 3: Reproduce toi thieu voi chi 1 mod.
4. Buoc 4: Sua patch nho nhat co the.
5. Buoc 5: Chay lai regression matrix.

## 5. Test script de xac nhan click-through fix

1. Hover item co nhieu recipe.
2. Di chuot vao nut next.
3. Click left 1 lan:
- Mong doi: next page.
- Khong mong doi: nhac item dang hover.
4. Lap lai voi nut prev.
5. Click ra ngoai board:
- Mong doi: inventory behavior binh thuong.

## 6. Exit criteria

1. Khong co `MOD ERROR` trong log.
2. Khong co `Error loading main.lua` do mod.
3. Khong co crash trong smoke + functional + regression matrix.
