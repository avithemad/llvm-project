Following are the features we need to model in the IR
- Construction of data frames.
    - Read data from CSV files into a dataframe.
- Add new columns to data frame.
- Construct new dataframe from a subset of columns.
- Row-wise operations on columns.
- Groupby
    - Grouping by single and multiple columns.
- Filtering.
    - Only simple predicates on columns (like <, > etc). No UDFs.
- Reductions
    - Sum, Mean, Count.
    - Reductions on the output of groupby are also supported.
    - No custom reductions.
- Join
    - Only equi-joins where columns are explicitly specified.
- Sorting by a column (ORDER BY)

Let us define a few operations in our pandas dialect in order to do these

## Constructing data frames.

In python with the pandas library we construct the data frame using the following 

`df = pd.read_csv("csvfile.csv")`

Similary in our pandas IR we would need an equivalent operation that handles this reading and returns the dataframe
The type of the operation must be `(string) -> dataframe`

To begin with we model the type dataframe as a tensor. 

## Add new columns to the data frame

## The dataframe type

We need a custom type in our IR that can model the dataframe. Tuple is a good candidate. 
