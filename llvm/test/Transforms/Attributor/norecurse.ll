; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --check-attributes --check-globals
; RUN: opt -aa-pipeline=basic-aa -passes=attributor -attributor-manifest-internal  -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=8 -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_CGSCC_OPM,NOT_CGSCC_NPM,NOT_TUNIT_OPM,IS__TUNIT____,IS________NPM,IS__TUNIT_NPM
; RUN: opt -aa-pipeline=basic-aa -passes=attributor-cgscc -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_TUNIT_NPM,NOT_TUNIT_OPM,NOT_CGSCC_OPM,IS__CGSCC____,IS________NPM,IS__CGSCC_NPM

define i32 @leaf() {
; CHECK: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; CHECK-LABEL: define {{[^@]+}}@leaf
; CHECK-SAME: () #[[ATTR0:[0-9]+]] {
; CHECK-NEXT:    ret i32 1
;
  ret i32 1
}

define i32 @self_rec() {
; CHECK: Function Attrs: nofree nosync nounwind readnone willreturn
; CHECK-LABEL: define {{[^@]+}}@self_rec
; CHECK-SAME: () #[[ATTR1:[0-9]+]] {
; CHECK-NEXT:    ret i32 4
;
  %a = call i32 @self_rec()
  ret i32 4
}

define i32 @indirect_rec() {
; NOT_CGSCC_NPM: Function Attrs: nofree nosync nounwind readnone willreturn
; NOT_CGSCC_NPM-LABEL: define {{[^@]+}}@indirect_rec
; NOT_CGSCC_NPM-SAME: () #[[ATTR1]] {
; NOT_CGSCC_NPM-NEXT:    ret i32 undef
;
; IS__CGSCC_NPM: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC_NPM-LABEL: define {{[^@]+}}@indirect_rec
; IS__CGSCC_NPM-SAME: () #[[ATTR0]] {
; IS__CGSCC_NPM-NEXT:    ret i32 undef
;
  %a = call i32 @indirect_rec2()
  ret i32 %a
}
define i32 @indirect_rec2() {
; NOT_CGSCC_NPM: Function Attrs: nofree nosync nounwind readnone willreturn
; NOT_CGSCC_NPM-LABEL: define {{[^@]+}}@indirect_rec2
; NOT_CGSCC_NPM-SAME: () #[[ATTR1]] {
; NOT_CGSCC_NPM-NEXT:    ret i32 undef
;
; IS__CGSCC_NPM: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC_NPM-LABEL: define {{[^@]+}}@indirect_rec2
; IS__CGSCC_NPM-SAME: () #[[ATTR0]] {
; IS__CGSCC_NPM-NEXT:    ret i32 undef
;
  %a = call i32 @indirect_rec()
  ret i32 %a
}

define i32 @extern() {
; CHECK: Function Attrs: nosync readnone
; CHECK-LABEL: define {{[^@]+}}@extern
; CHECK-SAME: () #[[ATTR2:[0-9]+]] {
; CHECK-NEXT:    [[A:%.*]] = call i32 @k()
; CHECK-NEXT:    ret i32 [[A]]
;
  %a = call i32 @k()
  ret i32 %a
}

; CHECK: Function Attrs
; CHECK-NEXT: declare i32 @k()
declare i32 @k() readnone

define void @intrinsic(i8* %dest, i8* %src, i32 %len) {
; CHECK: Function Attrs: argmemonly nofree norecurse nosync nounwind willreturn
; CHECK-LABEL: define {{[^@]+}}@intrinsic
; CHECK-SAME: (i8* nocapture nofree writeonly [[DEST:%.*]], i8* nocapture nofree readonly [[SRC:%.*]], i32 [[LEN:%.*]]) #[[ATTR4:[0-9]+]] {
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i32(i8* noalias nocapture nofree writeonly [[DEST]], i8* noalias nocapture nofree readonly [[SRC]], i32 [[LEN]], i1 noundef false) #[[ATTR9:[0-9]+]]
; CHECK-NEXT:    ret void
;
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %dest, i8* %src, i32 %len, i1 false)
  ret void
}

; CHECK: Function Attrs
; CHECK-NEXT: declare void @llvm.memcpy.p0i8.p0i8.i32
declare void @llvm.memcpy.p0i8.p0i8.i32(i8*, i8*, i32, i1)

define internal i32 @called_by_norecurse() {
; CHECK: Function Attrs: norecurse nosync readnone
; CHECK-LABEL: define {{[^@]+}}@called_by_norecurse
; CHECK-SAME: () #[[ATTR6:[0-9]+]] {
; CHECK-NEXT:    [[A:%.*]] = call i32 @k()
; CHECK-NEXT:    ret i32 undef
;
  %a = call i32 @k()
  ret i32 %a
}
define void @m() norecurse {
; IS__TUNIT____: Function Attrs: norecurse nosync readnone
; IS__TUNIT____-LABEL: define {{[^@]+}}@m
; IS__TUNIT____-SAME: () #[[ATTR6]] {
; IS__TUNIT____-NEXT:    [[A:%.*]] = call i32 @called_by_norecurse() #[[ATTR2]]
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____: Function Attrs: norecurse nosync readnone
; IS__CGSCC____-LABEL: define {{[^@]+}}@m
; IS__CGSCC____-SAME: () #[[ATTR6]] {
; IS__CGSCC____-NEXT:    [[A:%.*]] = call i32 @called_by_norecurse()
; IS__CGSCC____-NEXT:    ret void
;
  %a = call i32 @called_by_norecurse()
  ret void
}

define internal i32 @called_by_norecurse_indirectly() {
; IS__TUNIT____: Function Attrs: norecurse nosync readnone
; IS__TUNIT____-LABEL: define {{[^@]+}}@called_by_norecurse_indirectly
; IS__TUNIT____-SAME: () #[[ATTR6]] {
; IS__TUNIT____-NEXT:    [[A:%.*]] = call i32 @k()
; IS__TUNIT____-NEXT:    ret i32 [[A]]
;
; IS__CGSCC____: Function Attrs: nosync readnone
; IS__CGSCC____-LABEL: define {{[^@]+}}@called_by_norecurse_indirectly
; IS__CGSCC____-SAME: () #[[ATTR2]] {
; IS__CGSCC____-NEXT:    [[A:%.*]] = call i32 @k()
; IS__CGSCC____-NEXT:    ret i32 [[A]]
;
  %a = call i32 @k()
  ret i32 %a
}
define internal i32 @o() {
; IS__TUNIT____: Function Attrs: norecurse nosync readnone
; IS__TUNIT____-LABEL: define {{[^@]+}}@o
; IS__TUNIT____-SAME: () #[[ATTR6]] {
; IS__TUNIT____-NEXT:    [[A:%.*]] = call i32 @called_by_norecurse_indirectly() #[[ATTR2]]
; IS__TUNIT____-NEXT:    ret i32 [[A]]
;
; IS__CGSCC____: Function Attrs: norecurse nosync readnone
; IS__CGSCC____-LABEL: define {{[^@]+}}@o
; IS__CGSCC____-SAME: () #[[ATTR6]] {
; IS__CGSCC____-NEXT:    [[A:%.*]] = call i32 @called_by_norecurse_indirectly()
; IS__CGSCC____-NEXT:    ret i32 [[A]]
;
  %a = call i32 @called_by_norecurse_indirectly()
  ret i32 %a
}
define i32 @p() norecurse {
; IS__TUNIT____: Function Attrs: norecurse nosync readnone
; IS__TUNIT____-LABEL: define {{[^@]+}}@p
; IS__TUNIT____-SAME: () #[[ATTR6]] {
; IS__TUNIT____-NEXT:    [[A:%.*]] = call i32 @o() #[[ATTR2]]
; IS__TUNIT____-NEXT:    ret i32 [[A]]
;
; IS__CGSCC____: Function Attrs: norecurse nosync readnone
; IS__CGSCC____-LABEL: define {{[^@]+}}@p
; IS__CGSCC____-SAME: () #[[ATTR6]] {
; IS__CGSCC____-NEXT:    [[A:%.*]] = call i32 @o()
; IS__CGSCC____-NEXT:    ret i32 [[A]]
;
  %a = call i32 @o()
  ret i32 %a
}

define void @f(i32 %x)  {
; NOT_CGSCC_NPM: Function Attrs: nofree nosync nounwind readnone willreturn
; NOT_CGSCC_NPM-LABEL: define {{[^@]+}}@f
; NOT_CGSCC_NPM-SAME: (i32 [[X:%.*]]) #[[ATTR1]] {
; NOT_CGSCC_NPM-NEXT:  entry:
; NOT_CGSCC_NPM-NEXT:    [[X_ADDR:%.*]] = alloca i32, align 4
; NOT_CGSCC_NPM-NEXT:    store i32 [[X]], i32* [[X_ADDR]], align 4
; NOT_CGSCC_NPM-NEXT:    [[TOBOOL:%.*]] = icmp ne i32 [[X]], 0
; NOT_CGSCC_NPM-NEXT:    br i1 [[TOBOOL]], label [[IF_THEN:%.*]], label [[IF_END:%.*]]
; NOT_CGSCC_NPM:       if.then:
; NOT_CGSCC_NPM-NEXT:    br label [[IF_END]]
; NOT_CGSCC_NPM:       if.end:
; NOT_CGSCC_NPM-NEXT:    ret void
;
; IS__CGSCC_NPM: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; IS__CGSCC_NPM-LABEL: define {{[^@]+}}@f
; IS__CGSCC_NPM-SAME: (i32 [[X:%.*]]) #[[ATTR0]] {
; IS__CGSCC_NPM-NEXT:  entry:
; IS__CGSCC_NPM-NEXT:    [[X_ADDR:%.*]] = alloca i32, align 4
; IS__CGSCC_NPM-NEXT:    [[TOBOOL:%.*]] = icmp ne i32 [[X]], 0
; IS__CGSCC_NPM-NEXT:    br i1 [[TOBOOL]], label [[IF_THEN:%.*]], label [[IF_END:%.*]]
; IS__CGSCC_NPM:       if.then:
; IS__CGSCC_NPM-NEXT:    br label [[IF_END]]
; IS__CGSCC_NPM:       if.end:
; IS__CGSCC_NPM-NEXT:    ret void
;
entry:
  %x.addr = alloca i32, align 4
  store i32 %x, i32* %x.addr, align 4
  %0 = load i32, i32* %x.addr, align 4
  %tobool = icmp ne i32 %0, 0
  br i1 %tobool, label %if.then, label %if.end

if.then:
  call void @g() norecurse
  br label %if.end

if.end:
  ret void
}

define void @g() norecurse {
; CHECK: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; CHECK-LABEL: define {{[^@]+}}@g
; CHECK-SAME: () #[[ATTR0]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    ret void
;
entry:
  call void @f(i32 0)
  ret void
}

define linkonce_odr i32 @leaf_redefinable() {
; CHECK-LABEL: define {{[^@]+}}@leaf_redefinable() {
; CHECK-NEXT:    ret i32 1
;
  ret i32 1
}

; Call through a function pointer
define i32 @eval_func1(i32 (i32)* , i32) local_unnamed_addr {
; CHECK-LABEL: define {{[^@]+}}@eval_func1
; CHECK-SAME: (i32 (i32)* nocapture nofree noundef nonnull [[TMP0:%.*]], i32 [[TMP1:%.*]]) local_unnamed_addr {
; CHECK-NEXT:    [[TMP3:%.*]] = tail call i32 [[TMP0]](i32 [[TMP1]])
; CHECK-NEXT:    ret i32 [[TMP3]]
;
  %3 = tail call i32 %0(i32 %1) #2
  ret i32 %3
}

define i32 @eval_func2(i32 (i32)* , i32) local_unnamed_addr null_pointer_is_valid{
; CHECK: Function Attrs: null_pointer_is_valid
; CHECK-LABEL: define {{[^@]+}}@eval_func2
; CHECK-SAME: (i32 (i32)* nocapture nofree noundef [[TMP0:%.*]], i32 [[TMP1:%.*]]) local_unnamed_addr #[[ATTR7:[0-9]+]] {
; CHECK-NEXT:    [[TMP3:%.*]] = tail call i32 [[TMP0]](i32 [[TMP1]])
; CHECK-NEXT:    ret i32 [[TMP3]]
;
  %3 = tail call i32 %0(i32 %1) #2
  ret i32 %3
}

; Call an unknown function in a dead block.
declare void @unknown()
define i32 @call_unknown_in_dead_block() local_unnamed_addr {
; CHECK: Function Attrs: nofree norecurse nosync nounwind readnone willreturn
; CHECK-LABEL: define {{[^@]+}}@call_unknown_in_dead_block
; CHECK-SAME: () local_unnamed_addr #[[ATTR0]] {
; CHECK-NEXT:    ret i32 0
; CHECK:       Dead:
; CHECK-NEXT:    unreachable
;
  ret i32 0
Dead:
  tail call void @unknown()
  ret i32 1
}

define i1 @test_rec_neg(i1 %c) norecurse {
; IS__TUNIT____: Function Attrs: norecurse
; IS__TUNIT____-LABEL: define {{[^@]+}}@test_rec_neg
; IS__TUNIT____-SAME: (i1 [[C:%.*]]) #[[ATTR8:[0-9]+]] {
; IS__TUNIT____-NEXT:    [[RC1:%.*]] = call i1 @rec(i1 noundef true)
; IS__TUNIT____-NEXT:    br i1 [[RC1]], label [[T:%.*]], label [[F:%.*]]
; IS__TUNIT____:       t:
; IS__TUNIT____-NEXT:    [[RC2:%.*]] = call i1 @rec(i1 [[C]])
; IS__TUNIT____-NEXT:    ret i1 [[RC2]]
; IS__TUNIT____:       f:
; IS__TUNIT____-NEXT:    ret i1 [[RC1]]
;
; IS__CGSCC____: Function Attrs: norecurse
; IS__CGSCC____-LABEL: define {{[^@]+}}@test_rec_neg
; IS__CGSCC____-SAME: (i1 [[C:%.*]]) #[[ATTR8:[0-9]+]] {
; IS__CGSCC____-NEXT:    [[RC1:%.*]] = call noundef i1 @rec(i1 noundef true)
; IS__CGSCC____-NEXT:    br i1 [[RC1]], label [[T:%.*]], label [[F:%.*]]
; IS__CGSCC____:       t:
; IS__CGSCC____-NEXT:    [[RC2:%.*]] = call noundef i1 @rec(i1 [[C]])
; IS__CGSCC____-NEXT:    ret i1 [[RC2]]
; IS__CGSCC____:       f:
; IS__CGSCC____-NEXT:    ret i1 [[RC1]]
;
  %rc1 = call i1 @rec(i1 true)
  br i1 %rc1, label %t, label %f
t:
  %rc2 = call i1 @rec(i1 %c)
  ret i1 %rc2
f:
  ret i1 %rc1
}

define internal i1 @rec(i1 %c1) {
; CHECK-LABEL: define {{[^@]+}}@rec
; CHECK-SAME: (i1 [[C1:%.*]]) {
; CHECK-NEXT:    br i1 [[C1]], label [[T:%.*]], label [[F:%.*]]
; CHECK:       t:
; CHECK-NEXT:    ret i1 true
; CHECK:       f:
; CHECK-NEXT:    [[R:%.*]] = call i1 @rec(i1 noundef true)
; CHECK-NEXT:    call void @unknown()
; CHECK-NEXT:    ret i1 false
;
  br i1 %c1, label %t, label %f
t:
  ret i1 true
f:
  %r = call i1 @rec(i1 true)
  call void @unknown()
  ret i1 false
}

;.
; CHECK: attributes #[[ATTR0]] = { nofree norecurse nosync nounwind readnone willreturn }
; CHECK: attributes #[[ATTR1]] = { nofree nosync nounwind readnone willreturn }
; CHECK: attributes #[[ATTR2]] = { nosync readnone }
; CHECK: attributes #[[ATTR3:[0-9]+]] = { readnone }
; CHECK: attributes #[[ATTR4]] = { argmemonly nofree norecurse nosync nounwind willreturn }
; CHECK: attributes #[[ATTR5:[0-9]+]] = { argmemonly nocallback nofree nounwind willreturn }
; CHECK: attributes #[[ATTR6]] = { norecurse nosync readnone }
; CHECK: attributes #[[ATTR7]] = { null_pointer_is_valid }
; CHECK: attributes #[[ATTR8:[0-9]+]] = { norecurse }
; CHECK: attributes #[[ATTR9]] = { willreturn }
;.
