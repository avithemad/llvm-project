get_property(dialect_libs GLOBAL PROPERTY MLIR_DIALECT_LIBS)
get_property(conversion_libs GLOBAL PROPERTY MLIR_CONVERSION_LIBS)
set(LIBS
        ${dialect_libs}
        ${conversion_libs}
        MLIRArithDialect
        MLIROptLib
        MLIRStandalone
        )
add_llvm_executable(pandas-opt pandas-opt.cpp)

llvm_update_compile_flags(pandas-opt)
target_link_libraries(pandas-opt PRIVATE ${LIBS})

mlir_check_all_link_libraries(pandas-opt)
