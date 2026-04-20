# 04. Input Routing and Click-Through Prevention

## 1. Van de can giai

Trong mod UI cua DST, cung mot click co the duoc nhieu layer nhan cung luc:

1. Layer board button/hitbox.
2. Layer itemtile.
3. Layer world/gameplay action.

Neu khong consume dung cho, click co the bi "roi" xuong layer duoi, gay ra:

1. Pick/drop item ngoai y muon.
2. Character action bi trigger sai.
3. Double page turn.

## 2. Nguyen tac input ownership

1. Neu click nam trong nav area cua board, board phai la chu so huu click.
2. Handler xu ly thanh cong phai return `true` ngay.
3. Chi goi old handler khi mod khong consume su kien.

## 3. Kien truc xu ly de xuat

1. Board layer:
- Xac dinh action qua `GetHoveredPageAction`.
- Xu ly down/up qua `HandlePageAction`.
- Dedupe click trong cua so thoi gian ngan.

2. Itemtile layer:
- Hook `OnControl` va `OnMouseButton`.
- Thu consume page action truoc.
- Neu khong consume moi fallback old handler.

## 4. Control path vs mouse path

DST co the route click qua:

1. `OnControl(CONTROL_ACCEPT, down)`
2. `OnMouseButton(MOUSEBUTTON_LEFT, down, x, y)`

Vi vay can chan ca 2 path de tranh build/platform-specific leak.

## 5. Dedupe strategy

1. `down`: ghi nho action duoc nhan.
2. `up`: xu ly action hop le dau tien.
3. Neu release mismatch hoac duplicate trong cua so `DUPLICATE_CLICK_WINDOW`, consume ma khong doi page lan nua.

## 6. Rule implementation checklist

1. Co helper `TryHandleBoardPageAction` tai itemtile.
2. Ham nay kiem tra board shown + hover action + handle result.
3. `OnControl` va `OnMouseButton` deu goi helper nay truoc old handler.
4. Khong co branch nao vua xu ly xong van tiep tuc bubble event.

## 7. Regression checklist

1. Hover nav button phai co animation.
2. Click nav button phai doi trang.
3. Click nav button khong duoc pick/drop item.
4. Click icon recipe khong duoc trigger world action ngoai y muon.
5. Click ngoai board van giu hanh vi inventory binh thuong.
