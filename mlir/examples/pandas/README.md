
## Building - Component Build

This setup assumes that you have built LLVM and MLIR in `$BUILD_DIR` and installed them to `$PREFIX`. To build and launch the tests, run
```sh
mkdir build && cd build
cmake -G Ninja .. -DMLIR_DIR=$PREFIX/lib/cmake/mlir -DLLVM_EXTERNAL_LIT=$BUILD_DIR/bin/llvm-lit
cmake --build . --target pandas-opt
```

**Note**: Make sure to pass `-DLLVM_INSTALL_UTILS=ON` when building LLVM with CMake in order to install `FileCheck` to the chosen installation prefix.

## Building - Monolithic Build

This setup assumes that you build the project as part of a monolithic LLVM build via the `LLVM_EXTERNAL_PROJECTS` mechanism.
To build LLVM, MLIR, the example and launch the tests run
```sh
mkdir build && cd build
cmake -G Ninja `$LLVM_SRC_DIR/llvm` \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_TARGETS_TO_BUILD=host
    -DLLVM_ENABLE_PROJECTS=mlir \
    -DLLVM_EXTERNAL_PROJECTS=standalone-dialect -DLLVM_EXTERNAL_STANDALONE_DIALECT_SOURCE_DIR=../
cmake --build . --target pandas-opt
```
Here, `$LLVM_SRC_DIR` needs to point to the root of the monorepo.


## Running queries on the test mlir files

The `pandas-opt` as currently 2 options, one which emits the mlir i.e., performs the printing and parsing of given input file, and second lower to affine and llvm dialect, which is unstable.

Following test can be run to see if mlir file is valid
```
build/bin/pandas-opt --emit=mlir test/q1.mlir
```