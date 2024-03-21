module {
func.func @q1() {
%1 = pd.read_csv ("/home/ajayakar/compiler-project/data/lineitem.csv") : !pd.df<<"l_orderkey" : i32>,<"l_partkey" : i32>,<"l_suppkey" : i32>,<"l_linenumber" : i32>,<"l_quantity" : i32>,<"l_extendedprice" : f64>,<"l_discount" : f64>,<"l_tax" : f64>,<"l_returnflag" : !pd.string>,<"l_linestatus" : !pd.string>,<"l_shipdate" : !pd.datetime>,<"l_commitdate" : !pd.datetime>,<"l_receiptdate" : !pd.datetime>,<"l_shipinstruct" : !pd.string>,<"l_shipmode" : !pd.string>,<"comments" : !pd.string>>
%2 = pd.select(%1: !pd.df<<"l_orderkey" : i32>,<"l_partkey" : i32>,<"l_suppkey" : i32>,<"l_linenumber" : i32>,<"l_quantity" : i32>,<"l_extendedprice" : f64>,<"l_discount" : f64>,<"l_tax" : f64>,<"l_returnflag" : !pd.string>,<"l_linestatus" : !pd.string>,<"l_shipdate" : !pd.datetime>,<"l_commitdate" : !pd.datetime>,<"l_receiptdate" : !pd.datetime>,<"l_shipinstruct" : !pd.string>,<"l_shipmode" : !pd.string>,<"comments" : !pd.string>>, ["l_quantity", "l_extendedprice", "l_discount", "l_shipdate"]) : !pd.df<<"l_quantity" : i32>,<"l_extendedprice" : f64>,<"l_discount" : f64>,<"l_shipdate" : !pd.datetime>>
%3 = pd.filter(%2: !pd.df<<"l_quantity" : i32>,<"l_extendedprice" : f64>,<"l_discount" : f64>,<"l_shipdate" : !pd.datetime>>, "l_shipdate" oge "1994-01-01 00:00:00") : !pd.ser<"1994-01-01 00:00:00" : i1>
%4 = pd.filter(%2: !pd.df<<"l_quantity" : i32>,<"l_extendedprice" : f64>,<"l_discount" : f64>,<"l_shipdate" : !pd.datetime>>, "l_shipdate" olt "1995-01-01 00:00:00") : !pd.ser<"1995-01-01 00:00:00" : i1>
%5 = pd.multiply(%3: !pd.ser<"1994-01-01 00:00:00" : i1>, %4: !pd.ser<"1995-01-01 00:00:00" : i1>): !pd.ser<"multiply" : i1>
%6 = pd.filter(%2: !pd.df<<"l_quantity" : i32>,<"l_extendedprice" : f64>,<"l_discount" : f64>,<"l_shipdate" : !pd.datetime>>, "l_discount" oge "0.05") : !pd.ser<"0.05" : i1>
%7 = pd.multiply(%5: !pd.ser<"multiply" : i1>, %6: !pd.ser<"0.05" : i1>): !pd.ser<"multiply" : i1>
%8 = pd.filter(%2: !pd.df<<"l_quantity" : i32>,<"l_extendedprice" : f64>,<"l_discount" : f64>,<"l_shipdate" : !pd.datetime>>, "l_discount" ole "0.07") : !pd.ser<"0.07" : i1>
%9 = pd.multiply(%7: !pd.ser<"multiply" : i1>, %8: !pd.ser<"0.07" : i1>): !pd.ser<"multiply" : i1>
%10 = pd.filter(%2: !pd.df<<"l_quantity" : i32>,<"l_extendedprice" : f64>,<"l_discount" : f64>,<"l_shipdate" : !pd.datetime>>, "l_quantity" olt "24") : !pd.ser<"24" : i1>
%11 = pd.multiply(%9: !pd.ser<"multiply" : i1>, %10: !pd.ser<"24" : i1>): !pd.ser<"multiply" : i1>
%12 = pd.filter_reduce(%2: !pd.df<<"l_quantity" : i32>,<"l_extendedprice" : f64>,<"l_discount" : f64>,<"l_shipdate" : !pd.datetime>>, %11: !pd.ser<"multiply" : i1>): !pd.df<<"l_quantity" : i32>,<"l_extendedprice" : f64>,<"l_discount" : f64>,<"l_shipdate" : !pd.datetime>>
%13 = pd.get_column(%12: !pd.df<<"l_quantity" : i32>,<"l_extendedprice" : f64>,<"l_discount" : f64>,<"l_shipdate" : !pd.datetime>>, "l_extendedprice") : !pd.ser<"l_extendedprice" : f64>
%14 = pd.get_column(%12: !pd.df<<"l_quantity" : i32>,<"l_extendedprice" : f64>,<"l_discount" : f64>,<"l_shipdate" : !pd.datetime>>, "l_discount") : !pd.ser<"l_discount" : f64>
%15 = pd.multiply(%13: !pd.ser<"l_extendedprice" : f64>, %14: !pd.ser<"l_discount" : f64>): !pd.ser<"multiply" : f64>
%16 = pd.agg_sum(%15: !pd.ser<"multiply" : f64>, ["multiply"]) : !pd.ser<"multiply" : f64>
return}}
