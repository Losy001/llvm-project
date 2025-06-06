; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 5
; RUN: opt -passes=gvn -S < %s | FileCheck %s

define i32 @f1(i32 %x) {
; CHECK-LABEL: define i32 @f1(
; CHECK-SAME: i32 [[X:%.*]]) {
; CHECK-NEXT:  [[BB0:.*:]]
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[X]], 0
; CHECK-NEXT:    br i1 [[CMP]], label %[[BB2:.*]], label %[[BB1:.*]]
; CHECK:       [[BB1]]:
; CHECK-NEXT:    br label %[[BB2]]
; CHECK:       [[BB2]]:
; CHECK-NEXT:    ret i32 [[X]]
;
bb0:
  %cmp = icmp eq i32 %x, 0
  br i1 %cmp, label %bb2, label %bb1
bb1:
  br label %bb2
bb2:
  %cond = phi i32 [ %x, %bb0 ], [ 0, %bb1 ]
  %foo = add i32 %cond, %x
  ret i32 %foo
}

define i32 @f2(i32 %x) {
; CHECK-LABEL: define i32 @f2(
; CHECK-SAME: i32 [[X:%.*]]) {
; CHECK-NEXT:  [[BB0:.*:]]
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne i32 [[X]], 0
; CHECK-NEXT:    br i1 [[CMP]], label %[[BB1:.*]], label %[[BB2:.*]]
; CHECK:       [[BB1]]:
; CHECK-NEXT:    br label %[[BB2]]
; CHECK:       [[BB2]]:
; CHECK-NEXT:    ret i32 [[X]]
;
bb0:
  %cmp = icmp ne i32 %x, 0
  br i1 %cmp, label %bb1, label %bb2
bb1:
  br label %bb2
bb2:
  %cond = phi i32 [ %x, %bb0 ], [ 0, %bb1 ]
  %foo = add i32 %cond, %x
  ret i32 %foo
}

define i32 @f3(i32 %x) {
; CHECK-LABEL: define i32 @f3(
; CHECK-SAME: i32 [[X:%.*]]) {
; CHECK-NEXT:  [[BB0:.*:]]
; CHECK-NEXT:    switch i32 [[X]], label %[[BB1:.*]] [
; CHECK-NEXT:      i32 0, label %[[BB2:.*]]
; CHECK-NEXT:    ]
; CHECK:       [[BB1]]:
; CHECK-NEXT:    br label %[[BB2]]
; CHECK:       [[BB2]]:
; CHECK-NEXT:    ret i32 [[X]]
;
bb0:
  switch i32 %x, label %bb1 [ i32 0, label %bb2]
bb1:
  br label %bb2
bb2:
  %cond = phi i32 [ %x, %bb0 ], [ 0, %bb1 ]
  %foo = add i32 %cond, %x
  ret i32 %foo
}

declare void @g(i1)
define void @f4(ptr %x)  {
; CHECK-LABEL: define void @f4(
; CHECK-SAME: ptr [[X:%.*]]) {
; CHECK-NEXT:  [[BB0:.*:]]
; CHECK-NEXT:    [[Y:%.*]] = icmp eq ptr null, [[X]]
; CHECK-NEXT:    br i1 [[Y]], label %[[BB2:.*]], label %[[BB1:.*]]
; CHECK:       [[BB1]]:
; CHECK-NEXT:    br label %[[BB2]]
; CHECK:       [[BB2]]:
; CHECK-NEXT:    call void @g(i1 [[Y]])
; CHECK-NEXT:    ret void
;
bb0:
  %y = icmp eq ptr null, %x
  br i1 %y, label %bb2, label %bb1
bb1:
  br label %bb2
bb2:
  %zed = icmp eq ptr null, %x
  call void @g(i1 %zed)
  ret void
}

define double @fcmp_oeq_not_zero(double %x, double %y) {
; CHECK-LABEL: define double @fcmp_oeq_not_zero(
; CHECK-SAME: double [[X:%.*]], double [[Y:%.*]]) {
; CHECK-NEXT:  [[ENTRY:.*]]:
; CHECK-NEXT:    [[CMP:%.*]] = fcmp oeq double [[Y]], 2.000000e+00
; CHECK-NEXT:    br i1 [[CMP]], label %[[IF:.*]], label %[[RETURN:.*]]
; CHECK:       [[IF]]:
; CHECK-NEXT:    [[DIV:%.*]] = fdiv double [[X]], 2.000000e+00
; CHECK-NEXT:    br label %[[RETURN]]
; CHECK:       [[RETURN]]:
; CHECK-NEXT:    [[RETVAL:%.*]] = phi double [ [[DIV]], %[[IF]] ], [ [[X]], %[[ENTRY]] ]
; CHECK-NEXT:    ret double [[RETVAL]]
;
entry:
  %cmp = fcmp oeq double %y, 2.0
  br i1 %cmp, label %if, label %return

if:
  %div = fdiv double %x, %y
  br label %return

return:
  %retval = phi double [ %div, %if ], [ %x, %entry ]
  ret double %retval
}

define double @fcmp_une_not_zero(double %x, double %y) {
; CHECK-LABEL: define double @fcmp_une_not_zero(
; CHECK-SAME: double [[X:%.*]], double [[Y:%.*]]) {
; CHECK-NEXT:  [[ENTRY:.*]]:
; CHECK-NEXT:    [[CMP:%.*]] = fcmp une double [[Y]], 2.000000e+00
; CHECK-NEXT:    br i1 [[CMP]], label %[[RETURN:.*]], label %[[ELSE:.*]]
; CHECK:       [[ELSE]]:
; CHECK-NEXT:    [[DIV:%.*]] = fdiv double [[X]], 2.000000e+00
; CHECK-NEXT:    br label %[[RETURN]]
; CHECK:       [[RETURN]]:
; CHECK-NEXT:    [[RETVAL:%.*]] = phi double [ [[DIV]], %[[ELSE]] ], [ [[X]], %[[ENTRY]] ]
; CHECK-NEXT:    ret double [[RETVAL]]
;
entry:
  %cmp = fcmp une double %y, 2.0
  br i1 %cmp, label %return, label %else

else:
  %div = fdiv double %x, %y
  br label %return

return:
  %retval = phi double [ %div, %else ], [ %x, %entry ]
  ret double %retval
}

define double @fcmp_one_possibly_nan(double %x, double %y) {
; CHECK-LABEL: define double @fcmp_one_possibly_nan(
; CHECK-SAME: double [[X:%.*]], double [[Y:%.*]]) {
; CHECK-NEXT:  [[ENTRY:.*]]:
; CHECK-NEXT:    [[CMP:%.*]] = fcmp one double [[Y]], 2.000000e+00
; CHECK-NEXT:    br i1 [[CMP]], label %[[RETURN:.*]], label %[[ELSE:.*]]
; CHECK:       [[ELSE]]:
; CHECK-NEXT:    [[DIV:%.*]] = fdiv double [[X]], [[Y]]
; CHECK-NEXT:    br label %[[RETURN]]
; CHECK:       [[RETURN]]:
; CHECK-NEXT:    [[RETVAL:%.*]] = phi double [ [[DIV]], %[[ELSE]] ], [ [[X]], %[[ENTRY]] ]
; CHECK-NEXT:    ret double [[RETVAL]]
;
entry:
  %cmp = fcmp one double %y, 2.0
  br i1 %cmp, label %return, label %else

else:
  %div = fdiv double %x, %y
  br label %return

return:
  %retval = phi double [ %div, %else ], [ %x, %entry ]
  ret double %retval
}

define double @fcmp_one_not_zero_or_nan(double %x, double %y) {
; CHECK-LABEL: define double @fcmp_one_not_zero_or_nan(
; CHECK-SAME: double [[X:%.*]], double [[Y:%.*]]) {
; CHECK-NEXT:  [[ENTRY:.*]]:
; CHECK-NEXT:    [[CMP:%.*]] = fcmp nnan one double [[Y]], 2.000000e+00
; CHECK-NEXT:    br i1 [[CMP]], label %[[RETURN:.*]], label %[[ELSE:.*]]
; CHECK:       [[ELSE]]:
; CHECK-NEXT:    [[DIV:%.*]] = fdiv double [[X]], 2.000000e+00
; CHECK-NEXT:    br label %[[RETURN]]
; CHECK:       [[RETURN]]:
; CHECK-NEXT:    [[RETVAL:%.*]] = phi double [ [[DIV]], %[[ELSE]] ], [ [[X]], %[[ENTRY]] ]
; CHECK-NEXT:    ret double [[RETVAL]]
;
entry:
  %cmp = fcmp nnan one double %y, 2.0
  br i1 %cmp, label %return, label %else

else:
  %div = fdiv double %x, %y
  br label %return

return:
  %retval = phi double [ %div, %else ], [ %x, %entry ]
  ret double %retval
}

; PR22376 - We can't propagate zero constants because -0.0
; compares equal to 0.0. If %y is -0.0 in this test case,
; we would produce the wrong sign on the infinity return value.
define double @fcmp_oeq_zero(double %x, double %y) {
; CHECK-LABEL: define double @fcmp_oeq_zero(
; CHECK-SAME: double [[X:%.*]], double [[Y:%.*]]) {
; CHECK-NEXT:  [[ENTRY:.*]]:
; CHECK-NEXT:    [[CMP:%.*]] = fcmp oeq double [[Y]], 0.000000e+00
; CHECK-NEXT:    br i1 [[CMP]], label %[[IF:.*]], label %[[RETURN:.*]]
; CHECK:       [[IF]]:
; CHECK-NEXT:    [[DIV:%.*]] = fdiv double [[X]], [[Y]]
; CHECK-NEXT:    br label %[[RETURN]]
; CHECK:       [[RETURN]]:
; CHECK-NEXT:    [[RETVAL:%.*]] = phi double [ [[DIV]], %[[IF]] ], [ [[X]], %[[ENTRY]] ]
; CHECK-NEXT:    ret double [[RETVAL]]
;
entry:
  %cmp = fcmp oeq double %y, 0.0
  br i1 %cmp, label %if, label %return

if:
  %div = fdiv double %x, %y
  br label %return

return:
  %retval = phi double [ %div, %if ], [ %x, %entry ]
  ret double %retval
}

; Denormals may be flushed to zero in some cases by the backend.
; Hence, treat denormals as 0.
define float @fcmp_oeq_denormal(float %x, float %y) {
; CHECK-LABEL: define float @fcmp_oeq_denormal(
; CHECK-SAME: float [[X:%.*]], float [[Y:%.*]]) {
; CHECK-NEXT:  [[ENTRY:.*]]:
; CHECK-NEXT:    [[CMP:%.*]] = fcmp oeq float [[Y]], 0x3800000000000000
; CHECK-NEXT:    br i1 [[CMP]], label %[[IF:.*]], label %[[RETURN:.*]]
; CHECK:       [[IF]]:
; CHECK-NEXT:    [[DIV:%.*]] = fdiv float [[X]], [[Y]]
; CHECK-NEXT:    br label %[[RETURN]]
; CHECK:       [[RETURN]]:
; CHECK-NEXT:    [[RETVAL:%.*]] = phi float [ [[DIV]], %[[IF]] ], [ [[X]], %[[ENTRY]] ]
; CHECK-NEXT:    ret float [[RETVAL]]
;
entry:
  %cmp = fcmp oeq float %y, 0x3800000000000000
  br i1 %cmp, label %if, label %return

if:
  %div = fdiv float %x, %y
  br label %return

return:
  %retval = phi float [ %div, %if ], [ %x, %entry ]
  ret float %retval
}

define double @fcmp_une_zero(double %x, double %y) {
; CHECK-LABEL: define double @fcmp_une_zero(
; CHECK-SAME: double [[X:%.*]], double [[Y:%.*]]) {
; CHECK-NEXT:  [[ENTRY:.*]]:
; CHECK-NEXT:    [[CMP:%.*]] = fcmp une double [[Y]], -0.000000e+00
; CHECK-NEXT:    br i1 [[CMP]], label %[[RETURN:.*]], label %[[ELSE:.*]]
; CHECK:       [[ELSE]]:
; CHECK-NEXT:    [[DIV:%.*]] = fdiv double [[X]], [[Y]]
; CHECK-NEXT:    br label %[[RETURN]]
; CHECK:       [[RETURN]]:
; CHECK-NEXT:    [[RETVAL:%.*]] = phi double [ [[DIV]], %[[ELSE]] ], [ [[X]], %[[ENTRY]] ]
; CHECK-NEXT:    ret double [[RETVAL]]
;
entry:
  %cmp = fcmp une double %y, -0.0
  br i1 %cmp, label %return, label %else

else:
  %div = fdiv double %x, %y
  br label %return

return:
  %retval = phi double [ %div, %else ], [ %x, %entry ]
  ret double %retval
}

; We also cannot propagate a value if it's not a constant.
; This is because the value could be 0.0, -0.0, or a denormal.

define double @fcmp_oeq_maybe_zero(double %x, double %y, double %z1, double %z2) {
; CHECK-LABEL: define double @fcmp_oeq_maybe_zero(
; CHECK-SAME: double [[X:%.*]], double [[Y:%.*]], double [[Z1:%.*]], double [[Z2:%.*]]) {
; CHECK-NEXT:  [[ENTRY:.*]]:
; CHECK-NEXT:    [[Z:%.*]] = fadd double [[Z1]], [[Z2]]
; CHECK-NEXT:    [[CMP:%.*]] = fcmp oeq double [[Y]], [[Z]]
; CHECK-NEXT:    br i1 [[CMP]], label %[[IF:.*]], label %[[RETURN:.*]]
; CHECK:       [[IF]]:
; CHECK-NEXT:    [[DIV:%.*]] = fdiv double [[X]], [[Z]]
; CHECK-NEXT:    br label %[[RETURN]]
; CHECK:       [[RETURN]]:
; CHECK-NEXT:    [[RETVAL:%.*]] = phi double [ [[DIV]], %[[IF]] ], [ [[X]], %[[ENTRY]] ]
; CHECK-NEXT:    ret double [[RETVAL]]
;
entry:
  %z = fadd double %z1, %z2
  %cmp = fcmp oeq double %y, %z
  br i1 %cmp, label %if, label %return

if:
  %div = fdiv double %x, %z
  br label %return

return:
  %retval = phi double [ %div, %if ], [ %x, %entry ]
  ret double %retval
}

define double @fcmp_une_maybe_zero(double %x, double %y, double %z1, double %z2) {
; CHECK-LABEL: define double @fcmp_une_maybe_zero(
; CHECK-SAME: double [[X:%.*]], double [[Y:%.*]], double [[Z1:%.*]], double [[Z2:%.*]]) {
; CHECK-NEXT:  [[ENTRY:.*]]:
; CHECK-NEXT:    [[Z:%.*]] = fadd double [[Z1]], [[Z2]]
; CHECK-NEXT:    [[CMP:%.*]] = fcmp une double [[Y]], [[Z]]
; CHECK-NEXT:    br i1 [[CMP]], label %[[RETURN:.*]], label %[[ELSE:.*]]
; CHECK:       [[ELSE]]:
; CHECK-NEXT:    [[DIV:%.*]] = fdiv double [[X]], [[Z]]
; CHECK-NEXT:    br label %[[RETURN]]
; CHECK:       [[RETURN]]:
; CHECK-NEXT:    [[RETVAL:%.*]] = phi double [ [[DIV]], %[[ELSE]] ], [ [[X]], %[[ENTRY]] ]
; CHECK-NEXT:    ret double [[RETVAL]]
;
entry:
  %z = fadd double %z1, %z2
  %cmp = fcmp une double %y, %z
  br i1 %cmp, label %return, label %else

else:
  %div = fdiv double %x, %z
  br label %return

return:
  %retval = phi double [ %div, %else ], [ %x, %entry ]
  ret double %retval
}


define double @fcmp_ueq_possibly_nan(double %x, double %y) {
; CHECK-LABEL: define double @fcmp_ueq_possibly_nan(
; CHECK-SAME: double [[X:%.*]], double [[Y:%.*]]) {
; CHECK-NEXT:  [[ENTRY:.*]]:
; CHECK-NEXT:    [[CMP:%.*]] = fcmp ueq double [[Y]], 2.000000e+00
; CHECK-NEXT:    br i1 [[CMP]], label %[[DO_DIV:.*]], label %[[RETURN:.*]]
; CHECK:       [[DO_DIV]]:
; CHECK-NEXT:    [[DIV:%.*]] = fdiv double [[X]], [[Y]]
; CHECK-NEXT:    br label %[[RETURN]]
; CHECK:       [[RETURN]]:
; CHECK-NEXT:    [[RETVAL:%.*]] = phi double [ [[DIV]], %[[DO_DIV]] ], [ [[X]], %[[ENTRY]] ]
; CHECK-NEXT:    ret double [[RETVAL]]
;
entry:
  %cmp = fcmp ueq double %y, 2.0
  br i1 %cmp, label %do_div, label %return

do_div:
  %div = fdiv double %x, %y
  br label %return

return:
  %retval = phi double [ %div, %do_div ], [ %x, %entry ]
  ret double %retval
}

define double @fcmp_ueq_not_zero_or_nan(double %x, double %y) {
; CHECK-LABEL: define double @fcmp_ueq_not_zero_or_nan(
; CHECK-SAME: double [[X:%.*]], double [[Y:%.*]]) {
; CHECK-NEXT:  [[ENTRY:.*]]:
; CHECK-NEXT:    [[CMP:%.*]] = fcmp nnan ueq double [[Y]], 2.000000e+00
; CHECK-NEXT:    br i1 [[CMP]], label %[[DO_DIV:.*]], label %[[RETURN:.*]]
; CHECK:       [[DO_DIV]]:
; CHECK-NEXT:    [[DIV:%.*]] = fdiv double [[X]], 2.000000e+00
; CHECK-NEXT:    br label %[[RETURN]]
; CHECK:       [[RETURN]]:
; CHECK-NEXT:    [[RETVAL:%.*]] = phi double [ [[DIV]], %[[DO_DIV]] ], [ [[X]], %[[ENTRY]] ]
; CHECK-NEXT:    ret double [[RETVAL]]
;
entry:
  %cmp = fcmp nnan ueq double %y, 2.0
  br i1 %cmp, label %do_div, label %return

do_div:
  %div = fdiv double %x, %y
  br label %return

return:
  %retval = phi double [ %div, %do_div ], [ %x, %entry ]
  ret double %retval
}
