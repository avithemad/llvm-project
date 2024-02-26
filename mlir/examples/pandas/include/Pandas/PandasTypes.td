//===- PandasTypes.td - Pandas dialect types -------*- tablegen -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef PANDAS_TYPES
#define PANDAS_TYPES

include "mlir/IR/AttrTypeBase.td"
include "Pandas/PandasDialect.td"

//===----------------------------------------------------------------------===//
// Pandas type definitions
//===----------------------------------------------------------------------===//

class Pandas_Type<string name, string typeMnemonic, list<Trait> traits = []>
    : TypeDef<Pandas_Dialect, name, traits> {
  let mnemonic = typeMnemonic;
}

def Pandas_CustomType : Pandas_Type<"Custom", "custom"> {
    let summary = "Pandas custom type";
    let description = "Custom type in pandas dialect";
    let parameters = (ins StringRefParameter<"the custom value">:$value);
    let assemblyFormat = "`<` $value `>`";
}

#endif // PANDAS_TYPES
