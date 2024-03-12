//===- PandasPasses.cpp - Pandas passes -----------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/BuiltinDialect.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "llvm/ADT/Sequence.h"

#include "Pandas/PandasPasses.h"
#include "Pandas/PandasDialect.h"
#include "Pandas/PandasOps.h"

using namespace mlir;
namespace {
  struct PandasLoweringPass 
    : public PassWrapper<PandasLoweringPass, OperationPass<ModuleOp>> {
      void getDependentDialects(DialectRegistry &registry) const override {
        registry.insert<memref::MemRefDialect>();
      }
      void runOnOperation() final;
    };
}

struct SelectOpLowering : public OpRewritePattern<pandas::SelectOp> {
  using OpRewritePattern<pandas::SelectOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(pandas::SelectOp op, 
    PatternRewriter &rewriter) const final {
      Location loc = op.getLoc();

      auto alloc = rewriter.create<arith::ConstantIndexOp>(loc, 0);

      rewriter.replaceOp(op, alloc);
      return success();
  }
};

struct ReadCsvOpLowering : public OpConversionPattern<pandas::ReadCsvOp> {
  using OpConversionPattern<pandas::ReadCsvOp>::OpConversionPattern;

  LogicalResult matchAndRewrite(pandas::ReadCsvOp op, OpAdaptor adaptor,
    ConversionPatternRewriter &rewriter) const final {
    rewriter.updateRootInPlace(op,
                               [&] { op->setOperands(adaptor.getOperands()); });
    return success();
  }
};

void PandasLoweringPass::runOnOperation() {
  ConversionTarget target(getContext());

  target.addLegalDialect<memref::MemRefDialect, BuiltinDialect,
  arith::ArithDialect>();

  target.addIllegalDialect<pandas::PandasDialect>();
  target.addDynamicallyLegalOp<pandas::ReadCsvOp>([](pandas::ReadCsvOp op) {
    return llvm::none_of(op->getOperandTypes(),
                         [](Type type) { return type.isa<TensorType>(); });
  });

  RewritePatternSet patterns(&getContext());
  patterns.add<SelectOpLowering,ReadCsvOpLowering>(&getContext());

  if (failed(applyPartialConversion(getOperation(), target, std::move(patterns))))
    signalPassFailure();
}

std::unique_ptr<Pass> mlir::pandas::createLowerPass() {
  return std::make_unique<PandasLoweringPass>();
}

