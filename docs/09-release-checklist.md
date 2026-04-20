# 09. Release Checklist

## 1. Startup safety gate

1. Apply mod khong crash.
2. Khong co `MOD ERROR` cho Ingredient-Insight.
3. Khong co `Error loading main.lua` do mod.
4. Khong co strict error undeclared global.

## 2. Runtime safety gate

1. Hover item co recipe -> board hien.
2. Hover item khong recipe -> board an.
3. Move cursor item -> board khong flicker.
4. Release Alt/lose focus -> board hide dung.

## 3. Input safety gate

1. Click nav prev/next khong click-through.
2. 1 click = 1 page turn.
3. Click ngoai nav giu behavior mac dinh.
4. Khong trigger world action khi click board nav.

## 4. Data/asset gate

1. Cache build thanh cong.
2. Khong nil access trong luong cache.
3. Atlas/image fallback hoat dong.
4. Invalid entry duoc skip an toan.

## 5. Quality gate

1. Cap nhat docs neu thay doi flow/input/rules.
2. Cap nhat failure catalog neu co bug moi.
3. Co ghi chu test matrix da chay.

## 6. Suggested pre-release procedure

1. Test voi chi mod nay.
2. Test voi mot bo mod pho bien.
3. Test world moi + world cu.
4. Luu client_log sau test pass lam artifact.
