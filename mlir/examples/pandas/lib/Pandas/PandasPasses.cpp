//===- PandasPasses.cpp - Pandas passes -----------------*- C++ -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/IR/BuiltinDialect.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "llvm/ADT/Sequence.h"
#include <iostream>

#include "Pandas/PandasDialect.h"
#include "Pandas/PandasOps.h"
#include "Pandas/PandasPasses.h"

using namespace mlir;
namespace {
static std::map<std::string, std::vector<Value>> rewritermap;

struct PandasLoweringPass
    : public PassWrapper<PandasLoweringPass, OperationPass<ModuleOp>> {
  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<memref::MemRefDialect>();
  }
  void runOnOperation() final;
};
} // namespace

struct NewdfOpLowering : public OpConversionPattern<pandas::NewdfOp> {
  using OpConversionPattern<pandas::NewdfOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(pandas::NewdfOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const final {
    rewriter.updateRootInPlace(op,
                               [&] { op->setOperands(adaptor.getOperands()); });
    return success();
  }
};

struct SelectOpLowering : public OpConversionPattern<pandas::SelectOp> {
  using OpConversionPattern<pandas::SelectOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(pandas::SelectOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const final {
    Location loc = op.getLoc();
    memref::AllocOp alloc;
    Value v = op.getDfIn();
    Location l = v.getDefiningOp()->getLoc();
        std::string s;
    llvm::raw_string_ostream out(s);
    l.print(out);
    for (auto e: rewritermap[s]) {
      std::cout << "Found one operand bro\n";
      e.dump();
    }
    // int k = 0;
    // std::map<int, Value> mp;
    // for (auto i = op.getDfIn().begin(); i < op.getDfIn().end(); i++) {
    //   mp[k++] = (*i);
    //   Value v = *i;
    // }
    // if (mp[0].getDefiningOp() == mp[2].getDefiningOp()) {
    //   std::cout << "Equal value";
    // } else {
    //   std::cout << "Not equal";
    // }
    // for (auto i = adaptor.getDfIn().begin(); i < adaptor.getDfIn().end(); i++) {
    //   MemRefType p = (*i).getType().getImpl();
    //   MemRefType mrt = MemRefType::get({2048}, p.getElementType());
    //   alloc = rewriter.create<memref::AllocOp>(loc, mrt);
    //   rewriter.create<memref::CopyOp>(loc, *i, alloc);
    // }

    rewriter.eraseOp(op);
    return success();
  }
};

struct ReadCsvOpLowering : public OpConversionPattern<pandas::ReadCsvOp> {
  using OpConversionPattern<pandas::ReadCsvOp>::OpConversionPattern;

  LogicalResult
  matchAndRewrite(pandas::ReadCsvOp op, OpAdaptor adaptor,
                  ConversionPatternRewriter &rewriter) const final {
    Location loc = op.getLoc();
    ModuleOp parentModule = op->getParentOfType<ModuleOp>();
    Value fnameCst =
        getOrCreateGlobalString(loc, rewriter, op.getFilename(),
                                StringRef(op.getFilename()), parentModule);
    auto results = op.getRes();
    std::vector<Value> vr;
    int colid = 1;
    // for (auto i = results.begin(); i < results.end(); i++) {
    //   pandas::SeriesType p = (*i).getType().getImpl();
    //   mlir::Type c_type = p.getType();
    //   MemRefType mrt = MemRefType::get({2048}, c_type);
    //   auto alloc = rewriter.create<memref::AllocOp>(loc, mrt);
    //   if (c_type.isInteger(32)) {
    //     FlatSymbolRefAttr readCsvIntRef =
    //         getOrInsertReadCsvIntFn(rewriter, parentModule);

    //     rewriter.create<func::CallOp>(
    //         loc, readCsvIntRef, ArrayRef<Type>(),
    //         ArrayRef<Value>(
    //             {fnameCst, alloc,
    //              rewriter.create<arith::ConstantIndexOp>(loc, colid)}));
    //   } else if (c_type.isF64()) {
    //     FlatSymbolRefAttr readCsvFloatRef =
    //         getOrInsertReadCsvFloatFn(rewriter, parentModule);

    //     rewriter.create<func::CallOp>(
    //         loc, readCsvFloatRef, ArrayRef<Type>(),
    //         ArrayRef<Value>(
    //             {fnameCst, alloc,
    //              rewriter.create<arith::ConstantIndexOp>(loc, colid)}));
    //   }
    //   colid++;

    //   vr.push_back(alloc);
    // }
    // ValueRange v(vr);

    MemRefType mrt =
        MemRefType::get({2048}, IntegerType::get(rewriter.getContext(), 32));
    auto alloc = rewriter.create<memref::AllocOp>(loc, mrt);
    auto alloc2 = rewriter.create<memref::AllocOp>(loc, mrt);
    // op.replaceAllUsesWith({alloc, alloc2});
    std::string s;
    llvm::raw_string_ostream out(s);
    op.getLoc().print(out);
    
    std::vector<Value> v;
    v.push_back(alloc);
    v.push_back(alloc2);
    rewritermap[s] = v;

    op->getParentOfType<ModuleOp>()->dump();
    for (auto e: rewritermap) {
      std::cout << e.first << "\n";
    }
    std::cout << "\n";
    rewriter.eraseOp(op);
    return success();
  }

private:
  static FlatSymbolRefAttr getOrInsertReadCsvIntFn(PatternRewriter &rewriter,
                                                   ModuleOp module) {
    auto *context = module.getContext();
    if (module.lookupSymbol<func::FuncOp>("readCsvColumnInt"))
      return SymbolRefAttr::get(context, "readCsvColumnInt");
    PatternRewriter::InsertionGuard insertGuard(rewriter);
    // TODO:
    // 1. Get the number of lines dynamically
    // 2. Handle memref of string
    FunctionType fnType = FunctionType::get(
        context,
        ArrayRef<Type>({LLVM::LLVMPointerType::get(
                            IntegerType::get(rewriter.getContext(), 8)),
                        MemRefType::get({2048}, IntegerType::get(context, 32)),
                        IndexType::get(context)}),
        ArrayRef<Type>());
    rewriter.setInsertionPointToStart(module.getBody());
    auto opFunc = rewriter.create<func::FuncOp>(module.getLoc(),
                                                "readCsvColumnInt", fnType);
    opFunc.setPrivate();
    return SymbolRefAttr::get(context, "readCsvColumnInt");
  }
  static FlatSymbolRefAttr getOrInsertReadCsvFloatFn(PatternRewriter &rewriter,
                                                     ModuleOp module) {
    auto *context = module.getContext();
    if (module.lookupSymbol<func::FuncOp>("readCsvColumnFloat"))
      return SymbolRefAttr::get(context, "readCsvColumnFloat");
    PatternRewriter::InsertionGuard insertGuard(rewriter);
    FunctionType fnType = FunctionType::get(
        context,
        ArrayRef<Type>({LLVM::LLVMPointerType::get(
                            IntegerType::get(rewriter.getContext(), 8)),
                        MemRefType::get({2048}, FloatType::getF64(context)),
                        IndexType::get(context)}),
        ArrayRef<Type>());
    rewriter.setInsertionPointToStart(module.getBody());
    auto opFunc = rewriter.create<func::FuncOp>(module.getLoc(),
                                                "readCsvColumnFloat", fnType);
    opFunc.setPrivate();
    return SymbolRefAttr::get(context, "readCsvColumnFloat");
  }

  static Value getOrCreateGlobalString(Location loc, OpBuilder &builder,
                                       StringRef name, StringRef value,
                                       ModuleOp module) {
    // Create the global at the entry of the module.
    LLVM::GlobalOp global;
    if (!(global = module.lookupSymbol<LLVM::GlobalOp>(name))) {
      OpBuilder::InsertionGuard insertGuard(builder);
      builder.setInsertionPointToStart(module.getBody());
      auto type = LLVM::LLVMArrayType::get(
          IntegerType::get(builder.getContext(), 8), value.size());
      global = builder.create<LLVM::GlobalOp>(loc, type, /*isConstant=*/true,
                                              LLVM::Linkage::Internal, name,
                                              builder.getStringAttr(value),
                                              /*alignment=*/0);
    }

    // Get the pointer to the first character in the global string.
    Value globalPtr = builder.create<LLVM::AddressOfOp>(loc, global);
    Value cst0 = builder.create<LLVM::ConstantOp>(loc, builder.getI64Type(),
                                                  builder.getIndexAttr(0));
    return builder.create<LLVM::GEPOp>(
        loc,
        LLVM::LLVMPointerType::get(IntegerType::get(builder.getContext(), 8)),
        globalPtr, ArrayRef<Value>({cst0, cst0}));
  }
};
void PandasLoweringPass::runOnOperation() {
  ConversionTarget target(getContext());

  target.addLegalDialect<memref::MemRefDialect, BuiltinDialect,
                         arith::ArithDialect, mlir::linalg::LinalgDialect,
                         func::FuncDialect, LLVM::LLVMDialect>();

  target.addIllegalDialect<pandas::PandasDialect>();

  target.addDynamicallyLegalOp<pandas::NewdfOp>([](pandas::NewdfOp op) {
    return llvm::none_of(op->getOperandTypes(),
                         [](Type type) { return type.isa<TensorType>(); });
  });
  RewritePatternSet patterns(&getContext());
  // PandasToStandardTypeConverter typeConverter(&getContext());
  patterns.add<SelectOpLowering, ReadCsvOpLowering, NewdfOpLowering>(
      &getContext());

  if (failed(
          applyPartialConversion(getOperation(), target, std::move(patterns))))
    signalPassFailure();
}

std::unique_ptr<Pass> mlir::pandas::createLowerPass() {
  return std::make_unique<PandasLoweringPass>();
}
