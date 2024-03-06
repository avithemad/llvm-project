//===- PandasPasses.h - Pandas passes  ------------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
#ifndef PANDAS_PANDASPASSES_H
#define PANDAS_PANDASPASSES_H

#include "Pandas/PandasDialect.h"
#include "Pandas/PandasOps.h"
#include "mlir/Pass/Pass.h"
#include <memory>

namespace mlir {
namespace pandas {

std::unique_ptr<Pass> createLowerPass();
std::unique_ptr<mlir::Pass> createLowerToLLVMPass();

} // namespace pandas
} // namespace mlir

#endif
