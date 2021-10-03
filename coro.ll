
declare i8* @malloc(i32 %size)
declare void @free(i8* %ptr)
declare void @print_i32(i32 %val)

declare i1 @llvm.coro.alloc(token %id)
declare i8* @llvm.coro.free(token %id, i8* %frame)
declare void @llvm.coro.destroy(i8* %handle)
declare i8* @llvm.coro.begin(token %id, i8* %mem)
declare i1 @llvm.coro.end(i8* %handle, i1 %unwind)
declare i8 @llvm.coro.suspend(token %save, i1 %final)
declare void @llvm.coro.resume(i8* %handle)
declare token @llvm.coro.id(i32 %align, i8* %promise, i8* %coroaddr, i8* %fnaddrs)
declare i32 @llvm.coro.size.i32()
declare i64 @llvm.coro.size.i64()

define private i8* @f(i32 %n) {
entry:
  %id = call token @llvm.coro.id(i32 0, i8* null, i8* null, i8* null)
  %size = call i32 @llvm.coro.size.i32()
  %alloc = call i8* @malloc(i32 %size)
  %hdl = call noalias i8* @llvm.coro.begin(token %id, i8* %alloc)
  br label %loop
loop:
  %n.val = phi i32 [ %n, %entry ], [ %inc, %loop ]
  %inc = add nsw i32 %n.val, 1
  call void @print_i32(i32 %n.val)
  %0 = call i8 @llvm.coro.suspend(token none, i1 false)
  switch i8 %0, label %suspend [i8 0, label %loop
                                i8 1, label %cleanup]
cleanup:
  %mem = call i8* @llvm.coro.free(token %id, i8* %hdl)
  call void @free(i8* %mem)
  br label %suspend
suspend:
  %unused = call i1 @llvm.coro.end(i8* %hdl, i1 false)
  ret i8* %hdl
}

define i32 @main() {
entry:
  %hdl = call i8* @f(i32 4)
  call void @llvm.coro.resume(i8* %hdl)
  call void @llvm.coro.resume(i8* %hdl)
  call void @llvm.coro.destroy(i8* %hdl)
  ret i32 0
}
