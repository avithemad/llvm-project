//===- PandasDialect.cpp - Pandas dialect ---------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "Pandas/PandasDialect.h"
#include "Pandas/PandasOps.h"
#include "Pandas/PandasTypes.h"

using namespace mlir;
using namespace mlir::pandas;

#include "Pandas/PandasOpsDialect.cpp.inc"

//===----------------------------------------------------------------------===//
// Pandas dialect.
//===----------------------------------------------------------------------===//

/// A generalized printer for binary operations. It prints in two different
/// forms depending on if all of the types match.
static void printBinaryOp(mlir::OpAsmPrinter &printer, mlir::Operation *op) {
  printer << " " << op->getOperands();
  printer.printOptionalAttrDict(op->getAttrs());
  printer << " : ";

  // If all of the types are the same, print the type directly.
  Type resultType = *op->result_type_begin();
  if (llvm::all_of(op->getOperandTypes(),
                   [=](Type type) { return type == resultType; })) {
    printer << resultType;
    return;
  }

  // Otherwise, print a functional type.
  printer.printFunctionalType(op->getOperandTypes(), op->getResultTypes());
}

void PandasDialect::initialize() {
  addOperations<
#define GET_OP_LIST
#include "Pandas/PandasOps.cpp.inc"
      >();
  registerTypes();
}

void FooOp::print(mlir::OpAsmPrinter &p) { 
  printBinaryOp(p, *this);
 }
mlir::ParseResult FooOp::parse(mlir::OpAsmParser &parser,
                               mlir::OperationState &result) {
  return mlir::success();
}
