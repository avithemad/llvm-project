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

def Pandas_SeriesType : Pandas_Type<"Series", "ser"> {
  let summary = "Pandas dataframe type to hold a dataframe";

  // TODO: check how to restrict the types to pandas string, pandas datetime, integer and float
  let parameters = (ins "std::string":$column, "mlir::Type":$type);

  let assemblyFormat = "`<` $column `:` $type `>`";
}

def Pandas_String : Pandas_Type<"String", "string"> {
  let summary = "String type for the pandas";
}

def Pandas_Datetime : Pandas_Type<"Datetime", "datetime"> {
  let summary = "Datetime type for the pandas";
}

def Pandas_Group : Pandas_Type<"Group", "group"> {
  // TODO: check how to restrict the types to pandas string, pandas datetime, integer and float
  let parameters = (ins "mlir::Type":$type);
  let assemblyFormat = "`<` $type `>`";
}

def Pandas_DataframeType : Pandas_Type<"Dataframe", "df"> {
  let summary = "Dataframe type";

  let parameters = (ins ArrayRefParameter<"pandas::SeriesType">:$columns);

  let assemblyFormat =  "`<` $columns  `>`";

  let builders = [
        TypeBuilderWithInferredContext<(ins 
        "Type":$typeParam), [{
          return $_get(typeParam.getContext());
        }]>
    ];
}


#endif // PANDAS_TYPES
