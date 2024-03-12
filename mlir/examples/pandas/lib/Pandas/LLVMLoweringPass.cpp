#include "Pandas/PandasDialect.h"
#include "Pandas/PandasPasses.h"

#include "mlir/Conversion/AffineToStandard/AffineToStandard.h"
#include "mlir/Conversion/ArithToLLVM/ArithToLLVM.h"
#include "mlir/Conversion/ControlFlowToLLVM/ControlFlowToLLVM.h"
#include "mlir/Conversion/FuncToLLVM/ConvertFuncToLLVM.h"
#include "mlir/Conversion/FuncToLLVM/ConvertFuncToLLVMPass.h"
#include "mlir/Conversion/LLVMCommon/ConversionTarget.h"
#include "mlir/Conversion/LLVMCommon/TypeConverter.h"
#include "mlir/Conversion/MemRefToLLVM/MemRefToLLVM.h"
#include "mlir/Conversion/SCFToControlFlow/SCFToControlFlow.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"
#include "llvm/ADT/Sequence.h"
#include <iostream>
using namespace mlir;

namespace {
class ReadCsvOpLowering : public ConversionPattern {
public:
  explicit ReadCsvOpLowering(MLIRContext *context)
      : ConversionPattern(pandas::ReadCsvOp::getOperationName(), 1, context) {}

  LogicalResult
  matchAndRewrite(Operation *op, ArrayRef<Value> operands,
                  ConversionPatternRewriter &rewriter) const override {
    std::cout << "Number of operands = " << operands.size() << "\n";
    std::string s;
    llvm::raw_string_ostream out(s);
    op->getAttrs().front().getValue().print(out);
    std::cout << "Attributes are : " << s <<  "\n";
    // auto memRefType = llvm::cast<VectorType>((*op->operand_type_begin()));
    std::cout << "Inside match and rewrite print op lowering\n";
    // Generate a call to printf for the current element of the loop.

    // Notify the rewriter that this operation has been removed.
    rewriter.eraseOp(op);
    return success();
  }
};
} // namespace

namespace {
struct PandasToLLVMLoweringPass
    : public PassWrapper<PandasToLLVMLoweringPass, OperationPass<ModuleOp>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(PandasToLLVMLoweringPass)

  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<LLVM::LLVMDialect, scf::SCFDialect>();
  }
  void runOnOperation() final;
};
} // namespace

void PandasToLLVMLoweringPass::runOnOperation() {

  LLVMConversionTarget target(getContext());
  target.addLegalOp<ModuleOp>();

  LLVMTypeConverter typeConverter(&getContext());

  RewritePatternSet patterns(&getContext());
  populateAffineToStdConversionPatterns(patterns);
  populateSCFToControlFlowConversionPatterns(patterns);
  mlir::arith::populateArithToLLVMConversionPatterns(typeConverter, patterns);
  populateFinalizeMemRefToLLVMConversionPatterns(typeConverter, patterns);
  cf::populateControlFlowToLLVMConversionPatterns(typeConverter, patterns);
  populateFuncToLLVMConversionPatterns(typeConverter, patterns);

  patterns.add<ReadCsvOpLowering>(&getContext());
  std::cout << "Inside runonoperation print op lowering\n";

  auto module = getOperation();
  std::cout << "Got the operation\n";
  if (failed(applyFullConversion(module, target, std::move(patterns))))
    signalPassFailure();
}

std::unique_ptr<mlir::Pass> mlir::pandas::createLowerToLLVMPass() {
  return std::make_unique<PandasToLLVMLoweringPass>();
}