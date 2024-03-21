# A pandas dialect for MLIR

In order to translate the queries written in pandas to MLIR a new dialect called `pd` (commonly used import name in python) is created which models the pandas library as close as possible. 


## Design

Following are few reasons for the design of this dialect:

- The operations and types are designed in such a way that for each pandas operation of the original library, we can emit a corresponding mlir code. 
- The type is associated for each dataframe in order for operation to completely know about the dataframe it is operating on.
- For lowering this dialect we will target the `affine`, `memref` and `llvm` dialect, where each series type can be just represented as `memref<?x type>` of 1 dimension and given type. 
- The input (read_csv) operation would be lowered as a library call function, which takes filepath and prepares the dataframe (an array of memrefs).
- Dataframe will be lowered to a set of memrefs, and each operation which operates on dataframe like filter, group by will be lowered to affine in order to reuse the existing optimization passes for affine dialect.

Few pros
- At each statement the mlir pass can easily detect the type errors 
- The type verifier can be implemented based on the semantic of the operation. For example for a join operation, we can check the types/schemas of input and see output type is correct which should be the join of the columns. 
For binary operations we can check if the inputs are of the same type.

Few cons of the design
- The IR would be too long if there are a lot of columns for the dataframe, even with type inference which only infers the result type.
- Indexing is not yet implemented, which means dataframe cannot be accessed by index, instead array index of each series is itself considered as the index.

## Types for the pandas dialect

The data in pandas is represented as a DataFrame, and the DataFrame is further composed of individual series.
For simplicity of designing the lowering, we assume the following
- DataFrame can be modelled as a dictionary of arrays
- Each Series in the dataframe will be of the same size
- The index for the row as a whole is just the index of the Series, which is modelled as a 0-indexed array

### DataFrame type

The dataframe type basically describes the schema of the dataframe, therefore it is modelled as an array of Series, which is explained further.

Examples:
`!pd.df<<"col1": f64>, <"col2": i32>, <"col3": memref<?xi8>>>`

### Series type

The series has 2 parameters
1. Column name: This is needed to address each of the column by its name. Most of the operations operate on the column using its name.
2. Column type: This is the data type of the column. The following simplified assumptions are made for the data types, they can be only of `float`, `int` or a `char[]`/`string`. 
    - For datetime, we are not using a separate type, since in standard format the date time string is already lexico-graphically ordered, and it can be represented as string.

Examples:
`!pd.ser<"col1": f64>`

## Operations on the pandas dialect

In order to model the given subset of pandas library, we implement the following operations.

1. `pd.read_csv`

This operation takes in a filepath as a string, and builds a dataframe, with the resulting type. 
The result type has to be specified in order to know the schema of the csv file.

`%df = pd.read_csv("/data/lineitem.csv") : !pd.df<<"col1": f64>, <"col2": i32>>`

2. `pd.select`

This is similar to select query in SQL. The operation takes in a dataframe as an operand, list of columns to be selected and outputs a new dataframe with selected columns.

`%selected = pd.select(%df:!pd.df<<"col1": f64>, <"col2": i32>>, ["col1"]) : !pd.df<<"col1": f64>>`

3. `pd.get_column`

This operation is actually defined to be used in conjunction with `pd.add_column`, in order to implement the column adding to a dataframe functionality. Given a dataframe and column name, this outputs a series with given column name.

`%col = pd.get_column(%df:!pd.df<<"col1": f64>, <"col2": i32>>, "col1") : !pd.ser<"col1": f64>`

4. `pd.add_column`

This operation takes in a dataframe, new column name and a series, creates a new dataframe with series added to the old dataframe, and renames the column to the given name.

`%new_df = pd.add_column(%df:!pd.df<<"col1": f64>, <"col2": i32>>, %col: !pd.ser<"col1": f64>, "new_col") : !pd.df<<"col1": f64>, <"col2": i32>, <"new_col": f64>>`

5. `pd.sortby`

This operation takes in a dataframe, the column name to be sorted by, the direction eiter ascending or descending and outputs a new dataframe.

`%sorted = pd.sortby(%df: !pd.df<<"col1": f64>, <"col2": i32>>, "col1", "asc") : !pd.df<<"col1": f64>, <"col2": i32>>`

6. `pd.const_int` / `pd.const_float`

This operation is created to create a series of given constant. Whenever used in conjunction with another series in a binary operation, it operates on all rows of the series.

`%const = pd.const_int(1) : !pd.ser<"const": i32>`
`%const = pd.const_float(1) : !pd.ser<"const": f64>`

7. Binary row-wise operations

Alls these operations takes in 2 series type and outputs a new series based on the operation required. This can be `add`, `sub`, `divide` and `multiply`

`%c = pd.add(%ser1: !pd.ser<"ser1": i32>, %ser2: !pd.ser<"ser2": i32>) : !pd.ser<"out": i32>`

8. `pd.join`

This operation takes in 2 dataframes, 2 column names(left table column name, right table column name) as string and outputs the equi-join as a dataframe. 

`%jn = pd.join(%df1: !pd.df<<"col1": f64>, <"col2": i32>>, %df2: !pd.df<<"col3": f64>, <"col4": i32>>, "col2", "col4"): !pd.df<<"col1": f64>, <"col2": i32>, <"col3": f64>> `

9. Filter operations

In order to implement the filter we implement it as 2 separate operation, one to compute the bitmask and one to reduce the dataframe based on the bitmask.

`%mask = pd.filter(%df: !pd.df<<"col1": f64>, <"col2": i32>>, "col1" ole "234") : !pd.ser<"mask": i1>`
`%filtered = pd.filter_reduce(%df: !pd.df<<"col1": f64>, <"col2": i32>>, %mask: !pd.ser<"mask": i1>) : !pd.df<<"col1": f64>, <"col2": i32>>`

For selecting a subset of rows there is an operation `filter_range`

`%filtered = pd.filter_range %df: !pd.df<<"col1": f64>, <"col2": i32>> [0, 20] !pd.df<<"col1": f64>, <"col2": i32>>`

10. Aggregation operations

For grouping, the operation is `groupby`. This takes in a dataframe, list of columns to perform group by on, then groups up the remaining columns of the dataframe, so if a column which is not in list of input was `f64`, then after grouping it would become `!pd.group<f64>`, represent grouped up set for the corresponding index.

`%group = pd.groupby(%df: !pd.df<<"col1": f64>, <"col2": i32>>, ["col1"]) : !pd.df<<"col1": f64>, <"col2": !pd.group<f64>>>`

Once group by is applied, any of the aggregation can be done `pd.agg_mean`, `pd.agg_count`, `pd.agg_sum`

`%summed = pd.agg_sum(%df: !pd.df<<"col1": f64>, <"col2": !pd.group<f64>>>, ["col2"]): !pd.df<<"col1": f64>, <"col2": f64>>`

11. Print operation 

The operation `pd.print` is for printing the given dataframe in the stdout file

`pd.print(%summed: !pd.df<<"col1": f64>, <"col2": f64>>)`

