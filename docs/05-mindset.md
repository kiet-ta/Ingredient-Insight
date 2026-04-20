# 05. Engineering Mindset for DST UI Mods

## 1. Mindset cot loi

1. Stability-first, feature-second.
2. Deterministic input over clever tricks.
3. Defensive by default: moi du lieu engine deu co the nil.
4. Fix by evidence: stacktrace first-fault, khong fix theo cam giac.

## 2. Cach nghi khi doc bug report

1. Phan loai loi:
- Load-time crash.
- Runtime nil crash.
- Input leak/regression.
- Asset fallback issue.

2. Dat cau hoi dung:
- Loi dau tien trong log la gi?
- Stack frame dau tien tro vao file nao?
- Repro voi 1 mod hay nhieu mod?

3. Tranh ngu bien:
- Dung sua theo "loi cu hay gap" khi chua co first-fault moi.
- Dung nham loi day chuyen la root-cause.

## 3. Mindset thiet ke code

1. Tach concern ro rang:
- Cache data.
- UI render.
- Input routing.
- Lifecycle.

2. Luon co fallback:
- Atlas fallback.
- Nil guard.
- Early return thay vi crash.

3. Khong hy sinh debugability:
- Prefix log thong nhat.
- State transition ro rang.

## 4. Mindset khi optimize

1. Profile first, optimize second.
2. Khong optimize khi chua co bottleneck xac thuc.
3. Neu toi uu lam code kho doc hon nhieu ma khong tang hieu nang dang ke, khong nen merge.

## 5. Mindset release

1. Release gate la bat buoc, khong optional.
2. Moi thay doi input/lifecycle phai test click-through va double-fire.
3. Moi thay doi startup phai test Apply mod tu main menu de bat load-time crash.
