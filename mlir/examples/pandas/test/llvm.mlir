module {
  llvm.mlir.global internal constant @scanformat("%d") {addr_space = 0 : i32}
  llvm.mlir.global internal constant @newline("\0A") {addr_space = 0 : i32}
  llvm.mlir.global internal constant @mode("r") {addr_space = 0 : i32}
  llvm.mlir.global internal constant @filename("/home/ajayakar/compiler-project/data/lineitem.csv") {addr_space = 0 : i32}
  llvm.func @fopen(!llvm.ptr<i8>, !llvm.ptr<i8>) -> !llvm.ptr
  llvm.func @fscanf(!llvm.ptr, !llvm.ptr<i8>, ...) -> !llvm.ptr<i8>
  llvm.func @scanf(!llvm.ptr<i8>, ...) -> i32
  llvm.func @printf(!llvm.ptr<i8>, ...) -> i32
  llvm.func @main() {
    %0 = llvm.mlir.addressof @filename : !llvm.ptr<array<49 x i8>>
    %1 = llvm.mlir.constant(0 : index) : i64
    %2 = llvm.getelementptr %0[%1, %1] : (!llvm.ptr<array<49 x i8>>, i64, i64) -> !llvm.ptr<i8>
    %3 = llvm.mlir.addressof @mode : !llvm.ptr<array<1 x i8>>
    %4 = llvm.mlir.constant(0 : index) : i64
    %5 = llvm.getelementptr %3[%4, %4] : (!llvm.ptr<array<1 x i8>>, i64, i64) -> !llvm.ptr<i8>
    %6 = llvm.mlir.addressof @newline : !llvm.ptr<array<1 x i8>>
    %7 = llvm.mlir.constant(0 : index) : i64
    %8 = llvm.getelementptr %6[%7, %7] : (!llvm.ptr<array<1 x i8>>, i64, i64) -> !llvm.ptr<i8>
    %9 = llvm.mlir.addressof @scanformat : !llvm.ptr<array<2 x i8>>
    %10 = llvm.mlir.constant(0 : index) : i64
    %11 = llvm.getelementptr %9[%10, %10] : (!llvm.ptr<array<2 x i8>>, i64, i64) -> !llvm.ptr<i8>
    %12 = llvm.call @printf(%2) : (!llvm.ptr<i8>) -> i32
    %13 = llvm.call @printf(%8) : (!llvm.ptr<i8>) -> i32
    
    %14 = llvm.call @fopen(%2, %5) : (!llvm.ptr<i8>, !llvm.ptr<i8>) -> !llvm.ptr
    %15 = llvm.mlir.constant(234 : i64) : i64
    %add = llvm.alloca %15 x i32 : (i64) -> !llvm.ptr
    
    %16 = llvm.call @fscanf(%14, %11, %add) : (!llvm.ptr, !llvm.ptr<i8>, !llvm.ptr) -> !llvm.ptr<i8>
    %loaded = llvm.load %add : !llvm.ptr -> i64
    %17 = llvm.call @printf(%11, %loaded) : (!llvm.ptr<i8>, i64) -> i32
    %18 = llvm.call @printf(%8) : (!llvm.ptr<i8>) -> i32
    
    %19 = llvm.call @scanf(%2) : (!llvm.ptr<i8>) -> i32
    %20 = llvm.mlir.constant(0 : index) : i64
    llvm.return
  }
}