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
    std::string filename;
    for (auto c: s) {
      if (c!='\"') filename+=c;
    }
    // Generate a call to printf for the current element of the loop.
    ModuleOp parentModule = op->getParentOfType<ModuleOp>();
    auto loc = op->getLoc();
    auto printfRef = getOrInsertPrintf(rewriter, parentModule);
    auto scanfRef = getOrInsertScanf(rewriter, parentModule);
    auto fscanfRef = getOrInsertFscanf(rewriter, parentModule);
    auto fopenRef = getOrInsertFopen(rewriter, parentModule);
    std::string mode = "r";
    Value filenameConst = getOrCreateGlobalString(
        loc, rewriter, "filename", StringRef(filename), parentModule);
    Value modeConst = getOrCreateGlobalString(
        loc, rewriter, "mode", StringRef(mode), parentModule);
    Value newlineConst = getOrCreateGlobalString(
        loc, rewriter, "newline", StringRef("\n"), parentModule);
    Value scanformatConst = getOrCreateGlobalString(
        loc, rewriter, "scanformat", StringRef("%d"), parentModule);
    // Notify the rewriter that this operation has been removed.

    rewriter.create<func::CallOp>(loc, printfRef, rewriter.getIntegerType(32),
                                  filenameConst);
    rewriter.create<func::CallOp>(loc, printfRef, rewriter.getIntegerType(32),
                                  newlineConst);

    Value fl = rewriter.create<LLVM::CallOp>(loc, 
                                  LLVM::LLVMPointerType::get(parentModule.getContext()),
                                  fopenRef,
                                  ArrayRef<Value>({filenameConst, modeConst})).getResult();
    Value cst0 = rewriter.create<LLVM::ConstantOp>(loc, rewriter.getI64Type(),
                                                  rewriter.getIndexAttr(0));
    rewriter.create<func::CallOp>(loc, fscanfRef, 
                                  LLVM::LLVMPointerType::get(IntegerType::get(parentModule.getContext(), 8)),
                                  ArrayRef<Value>({fl, scanformatConst, cst0}));

    rewriter.create<func::CallOp>(loc, printfRef, rewriter.getIntegerType(32),
                                  modeConst);
    rewriter.create<func::CallOp>(loc, printfRef, rewriter.getIntegerType(32),
                                  newlineConst);

    // kept for not exiting for now
    rewriter.create<func::CallOp>(loc, scanfRef, rewriter.getIntegerType(32),
                                  filenameConst);
    rewriter.eraseOp(op);
    return success();
  }

private:
  /// Return a symbol reference to the printf function, inserting it into the
  /// module if necessary.
  static FlatSymbolRefAttr getOrInsertPrintf(PatternRewriter &rewriter,
                                             ModuleOp module) {
    auto *context = module.getContext();
    if (module.lookupSymbol<LLVM::LLVMFuncOp>("printf"))
      return SymbolRefAttr::get(context, "printf");

    // Create a function declaration for printf, the signature is:
    //   * `i32 (i8*, ...)`
    auto llvmI32Ty = IntegerType::get(context, 32);
    auto llvmI8PtrTy = LLVM::LLVMPointerType::get(IntegerType::get(context, 8));
    auto llvmFnType = LLVM::LLVMFunctionType::get(llvmI32Ty, llvmI8PtrTy,
                                                  /*isVarArg=*/true);

    // Insert the printf function into the body of the parent module.
    PatternRewriter::InsertionGuard insertGuard(rewriter);
    rewriter.setInsertionPointToStart(module.getBody());
    rewriter.create<LLVM::LLVMFuncOp>(module.getLoc(), "printf", llvmFnType);
    return SymbolRefAttr::get(context, "printf");
  }

  static FlatSymbolRefAttr getOrInsertScanf(PatternRewriter &rewriter,
                                            ModuleOp module) {
    auto *context = module.getContext();
    if (module.lookupSymbol<LLVM::LLVMFuncOp>("scanf"))
      return SymbolRefAttr::get(context, "scanf");

    // Create a function declaration for printf, the signature is:
    //   * `i32 (i8*, ...)`
    auto llvmI32Ty = IntegerType::get(context, 32);
    auto llvmI8PtrTy = LLVM::LLVMPointerType::get(IntegerType::get(context, 8));
    auto llvmFnType = LLVM::LLVMFunctionType::get(llvmI32Ty, llvmI8PtrTy,
                                                  /*isVarArg=*/true);

    // Insert the printf function into the body of the parent module.
    PatternRewriter::InsertionGuard insertGuard(rewriter);
    rewriter.setInsertionPointToStart(module.getBody());
    rewriter.create<LLVM::LLVMFuncOp>(module.getLoc(), "scanf", llvmFnType);
    return SymbolRefAttr::get(context, "scanf");
  }

  static FlatSymbolRefAttr getOrInsertFopen(PatternRewriter &rewriter,
                                            ModuleOp module) {
    auto *context = module.getContext();
    if (module.lookupSymbol<LLVM::LLVMFuncOp>("fopen"))
      return SymbolRefAttr::get(context, "fopen");

    // Create a function declaration for printf, the signature is:
    //   * `i32 (i8*, ...)`
    auto llvmI8PtrTy = LLVM::LLVMPointerType::get(IntegerType::get(context, 8));
    auto llvmOpaquePtrTy = LLVM::LLVMPointerType::get(context);
    std::vector<Type> args;
    args.push_back(llvmI8PtrTy);
    args.push_back(llvmI8PtrTy);
    ArrayRef<Type> args_ar = ArrayRef(args);
    auto llvmFnType = LLVM::LLVMFunctionType::get(llvmOpaquePtrTy, args_ar,
                                                  /*isVarArg=*/false);

    // Insert the printf function into the body of the parent module.
    PatternRewriter::InsertionGuard insertGuard(rewriter);
    rewriter.setInsertionPointToStart(module.getBody());
    rewriter.create<LLVM::LLVMFuncOp>(module.getLoc(), "fopen", llvmFnType);
    return SymbolRefAttr::get(context, "fopen");
  }

  static FlatSymbolRefAttr getOrInsertFscanf(PatternRewriter &rewriter,
                                               ModuleOp module) {
    auto *context = module.getContext();
    if (module.lookupSymbol<LLVM::LLVMFuncOp>("fscanf"))
      return SymbolRefAttr::get(context, "fscanf");
    
    // define the types required
    auto llvmI8PtrTy = LLVM::LLVMPointerType::get(IntegerType::get(context, 8));
    auto llvmOpaquePtrTy = LLVM::LLVMPointerType::get(context);
    std::vector<Type> args;
    args.push_back(llvmOpaquePtrTy);
    args.push_back(llvmI8PtrTy);
    ArrayRef<Type> args_ar = ArrayRef(args);
    auto llvmFnType = LLVM::LLVMFunctionType::get(llvmI8PtrTy, args_ar,
                                                  /*isVarArg=*/true);


    PatternRewriter::InsertionGuard insertGuard(rewriter);
    rewriter.setInsertionPointToStart(module.getBody());
    rewriter.create<LLVM::LLVMFuncOp>(module.getLoc(), "fscanf", llvmFnType);
    return SymbolRefAttr::get(context, "fscanf");

  }
  /// Return a value representing an access into a global string with the given
  /// name, creating the string if necessary.
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

  auto module = getOperation();
  if (failed(applyFullConversion(module, target, std::move(patterns))))
    signalPassFailure();
}

std::unique_ptr<mlir::Pass> mlir::pandas::createLowerToLLVMPass() {
  return std::make_unique<PandasToLLVMLoweringPass>();
}