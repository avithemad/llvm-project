//===- PandasDialect.td - Pandas dialect -----------*- tablegen -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef PANDAS_DIALECT
#define PANDAS_DIALECT

include "mlir/IR/OpBase.td"

//===----------------------------------------------------------------------===//
// Pandas dialect definition.
//===----------------------------------------------------------------------===//

def Pandas_Dialect : Dialect {
    let name = "pandas";
    let summary = "A pandas out-of-tree MLIR dialect.";
    let description = [{
        This dialect is an example of an out-of-tree MLIR dialect designed to
        illustrate the basic setup required to develop MLIR-based tools without
        working inside of the LLVM source tree.
    }];
    let cppNamespace = "::mlir::pandas";

    let useDefaultTypePrinterParser = 1;
    let extraClassDeclaration = [{
        void registerTypes();
    }];
}

//===----------------------------------------------------------------------===//
// Base pandas operation definition.
//===----------------------------------------------------------------------===//

class Pandas_Op<string mnemonic, list<Trait> traits = []> :
        Op<Pandas_Dialect, mnemonic, traits>;

#endif // PANDAS_DIALECT
