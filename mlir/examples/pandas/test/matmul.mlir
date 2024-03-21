

func.func @main() {
  %f = arith.constant 2.00000e+00 : f32
  %f4 = arith.constant 4.00000e+00 : f32
  %A = memref.alloc() : memref<3x4x5xf32>
  %B = memref.cast %A: memref<3x4x5xf32> to memref<?x?x?xf32>
  linalg.fill ins(%f : f32) outs(%B : memref<?x?x?xf32>)

  %c2 = arith.constant 2 : index
  memref.store %f4, %B[%c2, %c2, %c2]: memref<?x?x?xf32>
  %U = memref.cast %B : memref<?x?x?xf32> to memref<*xf32>
  call @printMemrefF32(%U): (memref<*xf32>) -> ()
  call @fun(): () -> ()
  memref.dealloc %A : memref<3x4x5xf32>
  return
}

func.func private @printMemrefF32(memref<*xf32>) attributes { llvm.emit_c_interface }
func.func private @fun() attributes { llvm.emit_c_interface }
