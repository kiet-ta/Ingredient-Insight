# 10. Contributor Onboarding Guide

## 1. Learning path (3 phases)

1. Phase A: Understand system
- Doc [01-overview.md](01-overview.md)
- Doc [02-architecture.md](02-architecture.md)
- Doc [03-runtime-flow.md](03-runtime-flow.md)

2. Phase B: Understand engineering discipline
- Doc [05-mindset.md](05-mindset.md)
- Doc [06-coding-standards.md](06-coding-standards.md)
- Doc [04-input-routing.md](04-input-routing.md)

3. Phase C: Operate independently
- Doc [07-testing-debugging.md](07-testing-debugging.md)
- Doc [08-failure-catalog.md](08-failure-catalog.md)
- Doc [09-release-checklist.md](09-release-checklist.md)

## 2. First tasks for new contributor

1. Task 1
- Them mot log debug moi cho transition show/hide board.
- Muc tieu: hieu lifecycle va huong log prefix.

2. Task 2
- Viet them 1 test script manual cho input edge case.
- Muc tieu: hieu input ownership va click consume.

3. Task 3
- Refactor nho khong doi behavior (doi ten bien, tach helper).
- Muc tieu: luyen safe-edit va regression testing.

## 3. Review criteria

1. Co giu behavior cu khong?
2. Co mo them crash surface khong?
3. Co consume dung event input khong?
4. Co cap nhat docs/checklist neu flow thay doi khong?

## 4. Contribution anti-patterns

1. Patch to lon, nhieu concern trong 1 commit.
2. Sua theo phan doan, khong dua stacktrace.
3. Bo qua test click-through sau khi doi input code.
4. Them abstraction kho doc cho hot path.

## 5. Definition of done

1. Test pass theo [09-release-checklist.md](09-release-checklist.md).
2. Khong co loi moi trong client_log.
3. Docs lien quan duoc cap nhat day du.
