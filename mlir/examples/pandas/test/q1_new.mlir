module {
    func.func @main() {
        %df:16 = pd.read_csv("/home/ajayakar/compiler-project/data/lineitem.csv")
        : !pd.ser<"l_orderkey":i32>, !pd.ser<"l_partkey":i32>, !pd.ser<"l_suppkey":i32>, !pd.ser<"l_linenumber":i32>,
            !pd.ser<"l_quantity":i32>, !pd.ser<"l_extendedprice":f64>, !pd.ser<"l_discount":f64>, !pd.ser<"l_tax":f64>,
            !pd.ser<"l_returnflag":memref<?xi8>>, !pd.ser<"l_linestatus":memref<?xi8>>, !pd.ser<"l_shipdate":memref<?xi8>>, 
            !pd.ser<"l_commitdate":memref<?xi8>>,
            !pd.ser<"l_receiptdate":memref<?xi8>>, !pd.ser<"l_shipinstruct":memref<?xi8>>, !pd.ser<"l_shipmode":memref<?xi8>>, 
            !pd.ser<"comments": memref<?xi8>>
        
        %lineitem_filtered:8 = pd.project %df#0, %df#1, %df#2, %df#3, %df#4, %df#5, %df#6, %df#7, %df#8, %df#9, %df#10, %df#11, %df#12, %df#13, %df#14, %df#15 : !pd.ser<"l_orderkey":i32>, !pd.ser<"l_partkey":i32>, !pd.ser<"l_suppkey":i32>, !pd.ser<"l_linenumber":i32>,
            !pd.ser<"l_quantity":i32>, !pd.ser<"l_extendedprice":f64>, !pd.ser<"l_discount":f64>, !pd.ser<"l_tax":f64>,
            !pd.ser<"l_returnflag":memref<?xi8>>, !pd.ser<"l_linestatus":memref<?xi8>>, !pd.ser<"l_shipdate":memref<?xi8>>, 
            !pd.ser<"l_commitdate":memref<?xi8>>,
            !pd.ser<"l_receiptdate":memref<?xi8>>, !pd.ser<"l_shipinstruct":memref<?xi8>>, !pd.ser<"l_shipmode":memref<?xi8>>, 
            !pd.ser<"comments": memref<?xi8>> ["l_quantity",
                "l_extendedprice","l_discount","l_tax","l_returnflag","l_linestatus", "l_shipdate","l_orderkey"]
            -> !pd.ser<"l_quantity": i32>,
                    !pd.ser<"l_extendedprice":f64>, !pd.ser<"l_discount":f64>, !pd.ser<"l_tax":f64>,
                    !pd.ser<"l_returnflag":memref<?xi8>>, !pd.ser<"l_linestatus":memref<?xi8>>, 
                    !pd.ser<"l_shipdate":memref<?xi8>>, 
                    !pd.ser<"l_orderkey":i32>

        %filter_mask = pd.filter %lineitem_filtered#6: !pd.ser<"l_shipdate":memref<?xi8>> olt "1998-09-02" -> !pd.ser<"l_shipdate":memref<?xi1>>


        return
    }
}
