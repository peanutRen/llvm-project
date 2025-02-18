; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --check-attributes --check-globals
; RUN: opt -aa-pipeline=basic-aa -passes=attributor -attributor-manifest-internal  -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=2 -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_CGSCC_OPM,NOT_CGSCC_NPM,NOT_TUNIT_OPM,IS__TUNIT____,IS________NPM,IS__TUNIT_NPM
; RUN: opt -aa-pipeline=basic-aa -passes=attributor-cgscc -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_TUNIT_NPM,NOT_TUNIT_OPM,NOT_CGSCC_OPM,IS__CGSCC____,IS________NPM,IS__CGSCC_NPM
; PR 32917

@b = common local_unnamed_addr global i32 0, align 4
@a = common local_unnamed_addr global i32 0, align 4

;.
; CHECK: @[[B:[a-zA-Z0-9_$"\\.-]+]] = common local_unnamed_addr global i32 0, align 4
; CHECK: @[[A:[a-zA-Z0-9_$"\\.-]+]] = common local_unnamed_addr global i32 0, align 4
;.
define i32 @fn2() local_unnamed_addr {
; IS__TUNIT____: Function Attrs: nofree norecurse nosync nounwind willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@fn2
; IS__TUNIT____-SAME: () local_unnamed_addr #[[ATTR0:[0-9]+]] {
; IS__TUNIT____-NEXT:    [[TMP1:%.*]] = load i32, i32* @b, align 4
; IS__TUNIT____-NEXT:    [[TMP2:%.*]] = sext i32 [[TMP1]] to i64
; IS__TUNIT____-NEXT:    [[TMP3:%.*]] = inttoptr i64 [[TMP2]] to i32*
; IS__TUNIT____-NEXT:    call fastcc void @fn1(i32* nocapture nofree readonly align 4 [[TMP3]]) #[[ATTR1:[0-9]+]]
; IS__TUNIT____-NEXT:    ret i32 undef
;
; IS__CGSCC____: Function Attrs: nofree nosync nounwind willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@fn2
; IS__CGSCC____-SAME: () local_unnamed_addr #[[ATTR0:[0-9]+]] {
; IS__CGSCC____-NEXT:    [[TMP1:%.*]] = load i32, i32* @b, align 4
; IS__CGSCC____-NEXT:    [[TMP2:%.*]] = sext i32 [[TMP1]] to i64
; IS__CGSCC____-NEXT:    [[TMP3:%.*]] = inttoptr i64 [[TMP2]] to i32*
; IS__CGSCC____-NEXT:    call fastcc void @fn1(i32* nocapture nofree nonnull readonly align 4 [[TMP3]]) #[[ATTR2:[0-9]+]]
; IS__CGSCC____-NEXT:    ret i32 undef
;
  %1 = load i32, i32* @b, align 4
  %2 = sext i32 %1 to i64
  %3 = inttoptr i64 %2 to i32*
  call fastcc void @fn1(i32* %3)
  ret i32 undef
}

define internal fastcc void @fn1(i32* nocapture readonly) unnamed_addr {
; IS__TUNIT____: Function Attrs: nofree norecurse nosync nounwind willreturn
; IS__TUNIT____-LABEL: define {{[^@]+}}@fn1
; IS__TUNIT____-SAME: (i32* nocapture nofree nonnull readonly align 4 [[TMP0:%.*]]) unnamed_addr #[[ATTR0]] {
; IS__TUNIT____-NEXT:    [[TMP2:%.*]] = getelementptr inbounds i32, i32* [[TMP0]], i64 -1
; IS__TUNIT____-NEXT:    [[TMP3:%.*]] = load i32, i32* [[TMP2]], align 4
; IS__TUNIT____-NEXT:    store i32 [[TMP3]], i32* @a, align 4
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____: Function Attrs: nofree norecurse nosync nounwind willreturn
; IS__CGSCC____-LABEL: define {{[^@]+}}@fn1
; IS__CGSCC____-SAME: (i32* nocapture nofree nonnull readonly align 4 [[TMP0:%.*]]) unnamed_addr #[[ATTR1:[0-9]+]] {
; IS__CGSCC____-NEXT:    [[TMP2:%.*]] = getelementptr inbounds i32, i32* [[TMP0]], i64 -1
; IS__CGSCC____-NEXT:    [[TMP3:%.*]] = load i32, i32* [[TMP2]], align 4
; IS__CGSCC____-NEXT:    store i32 [[TMP3]], i32* @a, align 4
; IS__CGSCC____-NEXT:    ret void
;
  %2 = getelementptr inbounds i32, i32* %0, i64 -1
  %3 = load i32, i32* %2, align 4
  store i32 %3, i32* @a, align 4
  ret void
}
;.
; IS__TUNIT____: attributes #[[ATTR0]] = { nofree norecurse nosync nounwind willreturn }
; IS__TUNIT____: attributes #[[ATTR1]] = { nofree nosync nounwind willreturn }
;.
; IS__CGSCC____: attributes #[[ATTR0]] = { nofree nosync nounwind willreturn }
; IS__CGSCC____: attributes #[[ATTR1]] = { nofree norecurse nosync nounwind willreturn }
; IS__CGSCC____: attributes #[[ATTR2]] = { nounwind willreturn }
;.
