module attributes {llvm.data_layout = ""} {
  llvm.func @free(!llvm.ptr)
  llvm.func @malloc(i64) -> !llvm.ptr
  llvm.func @main() {
    %0 = llvm.mlir.constant(0 : index) : i64
    %1 = llvm.mlir.constant(20 : index) : i64
    %2 = llvm.mlir.constant(1 : index) : i64
    %3 = llvm.mlir.constant(5 : index) : i64
    %4 = llvm.mlir.constant(4 : index) : i64
    %5 = llvm.mlir.constant(3 : index) : i64
    %6 = llvm.mlir.constant(4.000000e+00 : f32) : f32
    %7 = llvm.mlir.constant(2.000000e+00 : f32) : f32
    %8 = llvm.mlir.constant(0 : index) : i64
    %9 = llvm.mlir.constant(3 : index) : i64
    %10 = llvm.mlir.constant(1 : index) : i64
    %11 = llvm.mlir.constant(4 : index) : i64
    %12 = llvm.mlir.constant(5 : index) : i64
    %13 = llvm.mlir.constant(2 : index) : i64
    %14 = llvm.mlir.null : !llvm.ptr
    %15 = llvm.getelementptr %14[60] : (!llvm.ptr) -> !llvm.ptr, f32
    %16 = llvm.ptrtoint %15 : !llvm.ptr to i64
    %17 = llvm.call @malloc(%16) : (i64) -> !llvm.ptr
    %18 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<3 x i64>, array<3 x i64>)>
    %19 = llvm.insertvalue %17, %18[0] : !llvm.struct<(ptr, ptr, i64, array<3 x i64>, array<3 x i64>)> 
    %20 = llvm.insertvalue %17, %19[1] : !llvm.struct<(ptr, ptr, i64, array<3 x i64>, array<3 x i64>)> 
    %21 = llvm.insertvalue %0, %20[2] : !llvm.struct<(ptr, ptr, i64, array<3 x i64>, array<3 x i64>)> 
    %22 = llvm.insertvalue %5, %21[3, 0] : !llvm.struct<(ptr, ptr, i64, array<3 x i64>, array<3 x i64>)> 
    %23 = llvm.insertvalue %4, %22[3, 1] : !llvm.struct<(ptr, ptr, i64, array<3 x i64>, array<3 x i64>)> 
    %24 = llvm.insertvalue %3, %23[3, 2] : !llvm.struct<(ptr, ptr, i64, array<3 x i64>, array<3 x i64>)> 
    %25 = llvm.insertvalue %1, %24[4, 0] : !llvm.struct<(ptr, ptr, i64, array<3 x i64>, array<3 x i64>)> 
    %26 = llvm.insertvalue %3, %25[4, 1] : !llvm.struct<(ptr, ptr, i64, array<3 x i64>, array<3 x i64>)> 
    %27 = llvm.insertvalue %2, %26[4, 2] : !llvm.struct<(ptr, ptr, i64, array<3 x i64>, array<3 x i64>)> 
    llvm.br ^bb1(%8 : i64)
  ^bb1(%28: i64):  // 2 preds: ^bb0, ^bb6
    %29 = llvm.icmp "slt" %28, %9 : i64
    llvm.cond_br %29, ^bb2(%8 : i64), ^bb7
  ^bb2(%30: i64):  // 2 preds: ^bb1, ^bb5
    %31 = llvm.icmp "slt" %30, %11 : i64
    llvm.cond_br %31, ^bb3(%8 : i64), ^bb6
  ^bb3(%32: i64):  // 2 preds: ^bb2, ^bb4
    %33 = llvm.icmp "slt" %32, %12 : i64
    llvm.cond_br %33, ^bb4, ^bb5
  ^bb4:  // pred: ^bb3
    %34 = llvm.mul %28, %1  : i64
    %35 = llvm.mul %30, %3  : i64
    %36 = llvm.add %34, %35  : i64
    %37 = llvm.add %36, %32  : i64
    %38 = llvm.getelementptr %17[%37] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %7, %38 : f32, !llvm.ptr
    %39 = llvm.add %32, %10  : i64
    llvm.br ^bb3(%39 : i64)
  ^bb5:  // pred: ^bb3
    %40 = llvm.add %30, %10  : i64
    llvm.br ^bb2(%40 : i64)
  ^bb6:  // pred: ^bb2
    %41 = llvm.add %28, %10  : i64
    llvm.br ^bb1(%41 : i64)
  ^bb7:  // pred: ^bb1
    %42 = llvm.mul %13, %1  : i64
    %43 = llvm.mul %13, %3  : i64
    %44 = llvm.add %42, %43  : i64
    %45 = llvm.add %44, %13  : i64
    %46 = llvm.getelementptr %17[%45] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %6, %46 : f32, !llvm.ptr
    %47 = llvm.alloca %2 x !llvm.struct<(ptr, ptr, i64, array<3 x i64>, array<3 x i64>)> : (i64) -> !llvm.ptr
    llvm.store %27, %47 : !llvm.struct<(ptr, ptr, i64, array<3 x i64>, array<3 x i64>)>, !llvm.ptr
    %48 = llvm.mlir.undef : !llvm.struct<(i64, ptr)>
    %49 = llvm.insertvalue %5, %48[0] : !llvm.struct<(i64, ptr)> 
    %50 = llvm.insertvalue %47, %49[1] : !llvm.struct<(i64, ptr)> 
    llvm.call @printMemrefF32(%5, %47) : (i64, !llvm.ptr) -> ()
    llvm.call @free(%17) : (!llvm.ptr) -> ()
    llvm.return
  }
  llvm.func private @printMemrefF32(%arg0: i64, %arg1: !llvm.ptr) attributes {llvm.emit_c_interface, sym_visibility = "private"} {
    %0 = llvm.mlir.undef : !llvm.struct<(i64, ptr)>
    %1 = llvm.insertvalue %arg0, %0[0] : !llvm.struct<(i64, ptr)> 
    %2 = llvm.insertvalue %arg1, %1[1] : !llvm.struct<(i64, ptr)> 
    %3 = llvm.mlir.constant(1 : index) : i64
    %4 = llvm.alloca %3 x !llvm.struct<(i64, ptr)> : (i64) -> !llvm.ptr
    llvm.store %2, %4 : !llvm.struct<(i64, ptr)>, !llvm.ptr
    llvm.call @_mlir_ciface_printMemrefF32(%4) : (!llvm.ptr) -> ()
    llvm.return
  }
  llvm.func @_mlir_ciface_printMemrefF32(!llvm.ptr) attributes {llvm.emit_c_interface, sym_visibility = "private"}
}

