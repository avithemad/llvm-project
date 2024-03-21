module {
  func.func private @readCsvColumnInt(!llvm.ptr<i8>, memref<2048xi32>, index)
  func.func private @readCsvColumnFloat(!llvm.ptr<i8>, memref<2048xf64>, index)
  llvm.mlir.global internal constant @"/home/ajayakar/compiler-project/data/lineitem.csv"("/home/ajayakar/compiler-project/data/lineitem.csv") {addr_space = 0 : i32}
  func.func @main() {
    %0 = llvm.mlir.addressof @"/home/ajayakar/compiler-project/data/lineitem.csv" : !llvm.ptr<array<49 x i8>>
    %1 = llvm.mlir.constant(0 : index) : i64
    %2 = llvm.getelementptr %0[%1, %1] : (!llvm.ptr<array<49 x i8>>, i64, i64) -> !llvm.ptr<i8>
    %alloc = memref.alloc() : memref<2048xf64>
    %c1 = arith.constant 1 : index
    call @readCsvColumnFloat(%2, %alloc, %c1) : (!llvm.ptr<i8>, memref<2048xf64>, index) -> ()
    %alloc_0 = memref.alloc() : memref<2048xi32>
    %c2 = arith.constant 2 : index
    call @readCsvColumnInt(%2, %alloc_0, %c2) : (!llvm.ptr<i8>, memref<2048xi32>, index) -> ()
    %alloc_1 = memref.alloc() : memref<2048xf64>
    memref.copy %alloc, %alloc_1 : memref<2048xf64> to memref<2048xf64>
    %alloc_2 = memref.alloc() : memref<2048xi32>
    memref.copy %alloc_0, %alloc_2 : memref<2048xi32> to memref<2048xi32>
    return
  }
}
