module {
    func.func @q1() {
        %lineitem = pd.read_csv("/home/ajayakar/compiler-project/data/lineitem.csv") : !pd.df<
            <"l_orderkey":i32>, <"l_partkey":i32>, <"l_suppkey":i32>, <"l_linenumber":i32>,
            <"l_quantity":i32>, <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
            <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, <"l_shipdate":!pd.datetime>, 
            <"l_commitdate":!pd.datetime>,
            <"l_receiptdate":!pd.datetime>, <"l_shipinstruct":!pd.string>, <"l_shipmode":!pd.string>, 
            <"comments": !pd.string>>

        %lineitem_filtered = pd.select(%lineitem: !pd.df<
            <"l_orderkey":i32>, <"l_partkey":i32>, <"l_suppkey":i32>, <"l_linenumber":i32>,
            <"l_quantity":i32>, <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
            <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, <"l_shipdate":!pd.datetime>, 
            <"l_commitdate":!pd.datetime>,
            <"l_receiptdate":!pd.datetime>, <"l_shipinstruct":!pd.string>, <"l_shipmode":!pd.string>, 
            <"comments": !pd.string>>, ["l_quantity",
                "l_extendedprice",
                "l_discount",
                "l_tax",
                "l_returnflag",
                "l_linestatus",
                "l_shipdate",
                "l_orderkey"]) : !pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>, 
                    <"l_orderkey":i32>>

        %filter_indices = pd.filter(%lineitem_filtered:!pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>, 
                    <"l_orderkey":i32>>, "l_shipdate" oeq "1998-09-02") : !pd.ser<"filter": i1>
        %lineitem_filtered_1 = pd.filter_reduce(%lineitem_filtered:!pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>,
                    <"l_orderkey":i32>>, %filter_indices: !pd.ser<"filter": i1>) : !pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>, 
                    <"l_orderkey":i32>>

        %sum_qty = pd.get_column(%lineitem_filtered_1: !pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>, 
                    <"l_orderkey":i32>>, "l_quantity") : !pd.ser<"l_quantity": i32>
        %lineitem_filtered_2 = pd.add_column(%lineitem_filtered_1: !pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>, 
                    <"l_orderkey":i32>>, %sum_qty: !pd.ser<"l_quantity": i32>, "sum_qty") : !pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>>

        %sum_base_price = pd.get_column(%lineitem_filtered_1: !pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>, 
                    <"l_orderkey":i32>>, "l_extendedprice") : !pd.ser<"l_extendedprice": f64>
        %lineitem_filtered_3 = pd.add_column(%lineitem_filtered_2: !pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>>, %sum_base_price: !pd.ser<"l_extendedprice": f64>, "sum_base_price") 
                    : !pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>>             
        
        %avg_qty = pd.get_column(%lineitem_filtered_1: !pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>, 
                    <"l_orderkey":i32>>, 
                    "l_quantity") 
                    : !pd.ser<"l_quantity": i32>
        %lineitem_filtered_4 = pd.add_column(%lineitem_filtered_3: !pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>>, 
                    %avg_qty: !pd.ser<"l_quantity": i32>, "avg_qty") 
                    : !pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>>  

        %avg_price = pd.get_column(%lineitem_filtered_1: !pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>, 
                    <"l_orderkey":i32>>, 
                    "l_quantity") 
                    : !pd.ser<"l_extendedprice": f64>
        %lineitem_filtered_5 = pd.add_column(%lineitem_filtered_4: !pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>>, 
                    %avg_price: !pd.ser<"l_extendedprice": f64>, "avg_price") 
                    : !pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>> 

        %l_disc = pd.get_column(%lineitem_filtered_5: !pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>> , "l_discount" ) : !pd.ser<"l_discount" : f64>
        %l_orkey = pd.get_column(%lineitem_filtered_5: !pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>> , "l_orderkey" ) : !pd.ser<"l_orderkey" : i32>
        %const_1 = pd.const_float(1.0) : !pd.ser<"const": f64>
        
        %diff_1 = pd.sub(%const_1 : !pd.ser<"const": f64>, %l_disc: !pd.ser<"l_discount" : f64>)
                    : !pd.ser<"diff" : f64>
        %mul_1 = pd.multiply(%avg_price: !pd.ser<"l_extendedprice": f64>, 
                            %diff_1: !pd.ser<"diff": f64>) : !pd.ser<"sum_disc_price": f64>
        %lineitem_filtered_6 = pd.add_column(%lineitem_filtered_5: !pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>> , %mul_1: !pd.ser<"sum_disc_price": f64>, "sum_disc_price") : !pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, <"sum_disc_price": f64>>

        %l_tx = pd.get_column(%lineitem_filtered_5: !pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>> , "l_tax" ) : !pd.ser<"l_tax" : f64>
        %diff_2 = pd.add(%const_1 : !pd.ser<"const": f64>, %l_tx: !pd.ser<"l_tax" : f64>)
                    : !pd.ser<"sm" : f64>
        %mul_2 = pd.multiply(%mul_1: !pd.ser<"sum_disc_price": f64>,
                            %diff_2: !pd.ser<"sm": f64>) : !pd.ser<"sum_charge": f64>
        %lineitem_filtered_7 = pd.add_column(%lineitem_filtered_6: !pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, <"sum_disc_price": f64>>, %mul_2: !pd.ser<"sum_charge": f64>,
                    "sum_charge") : !pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, <"sum_disc_price": f64>, <"sum_charge": f64>>
        
        %lineitem_filtered_8 = pd.add_column(%lineitem_filtered_7: !pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, <"sum_disc_price": f64>, <"sum_charge": f64>>, 
                    %l_disc: !pd.ser<"l_discount": f64>, "avg_disc") : !pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, <"sum_disc_price": f64>, <"sum_charge": f64>, <"avg_disc": f64>>

        %lineitem_filtered_9 = pd.add_column(%lineitem_filtered_8: !pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, <"sum_disc_price": f64>, <"sum_charge": f64>, <"avg_disc": f64>>, 
                    %l_orkey: !pd.ser<"l_orderkey": i32>, "count_order") : !pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, <"sum_disc_price": f64>, <"sum_charge": f64>, <"avg_disc": f64>,
                    <"count_order": i32>>


        %gb = pd.groupby(%lineitem_filtered_9: !pd.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, <"sum_disc_price": f64>, <"sum_charge": f64>, <"avg_disc": f64>,
                    <"count_order": i32>>, ["l_returnflag", "l_linestatus"] ) :  
                    !pd.df<<"l_quantity": !pd.group<i32>>,
                    <"l_extendedprice":!pd.group<f64>>, <"l_discount":!pd.group<f64>>, 
                    <"l_tax":!pd.group<f64>>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.group<!pd.datetime>>, 
                    <"l_orderkey":!pd.group<i32>>, <"sum_qty": !pd.group<i32>>, 
                    <"sum_base_price": !pd.group<f64>>, <"avg_qty": !pd.group<i32>>,
                    <"avg_price": !pd.group<f64>>, <"sum_disc_price": !pd.group<f64>>,
                    <"sum_charge": !pd.group<f64>>, <"avg_disc": !pd.group<f64>>,
                    <"count_order": !pd.group<i32>>>

        %summed = pd.agg_sum(%gb: !pd.df<<"l_quantity": !pd.group<i32>>,
                    <"l_extendedprice":!pd.group<f64>>, <"l_discount":!pd.group<f64>>, 
                    <"l_tax":!pd.group<f64>>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.group<!pd.datetime>>, 
                    <"l_orderkey":!pd.group<i32>>, <"sum_qty": !pd.group<i32>>, 
                    <"sum_base_price": !pd.group<f64>>, <"avg_qty": !pd.group<i32>>,
                    <"avg_price": !pd.group<f64>>, <"sum_disc_price": !pd.group<f64>>,
                    <"sum_charge": !pd.group<f64>>, <"avg_disc": !pd.group<f64>>,
                    <"count_order": !pd.group<i32>>>, ["sum_qty", "sum_base_price", "sum_disc_price",
                    "sum_charge"]) : !pd.df<<"l_quantity": !pd.group<i32>>,
                    <"l_extendedprice":!pd.group<f64>>, <"l_discount":!pd.group<f64>>, 
                    <"l_tax":!pd.group<f64>>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.group<!pd.datetime>>, 
                    <"l_orderkey":!pd.group<i32>>, <"sum_qty": i32>, 
                    <"sum_base_price": f64>, <"avg_qty": !pd.group<i32>>,
                    <"avg_price": !pd.group<f64>>, <"sum_disc_price": f64>,
                    <"sum_charge": f64>, <"avg_disc": !pd.group<f64>>,
                    <"count_order": !pd.group<i32>>>

        %meaned = pd.agg_mean(%summed: !pd.df<<"l_quantity": !pd.group<i32>>,
                    <"l_extendedprice":!pd.group<f64>>, <"l_discount":!pd.group<f64>>, 
                    <"l_tax":!pd.group<f64>>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.group<!pd.datetime>>, 
                    <"l_orderkey":!pd.group<i32>>, <"sum_qty": i32>, 
                    <"sum_base_price": f64>, <"avg_qty": !pd.group<i32>>,
                    <"avg_price": !pd.group<f64>>, <"sum_disc_price": f64>,
                    <"sum_charge": f64>, <"avg_disc": !pd.group<f64>>,
                    <"count_order": !pd.group<i32>>>, ["avg_qty", "avg_price", "avg_disc"]) : !pd.df<<"l_quantity": !pd.group<i32>>,
                    <"l_extendedprice":!pd.group<f64>>, <"l_discount":!pd.group<f64>>, 
                    <"l_tax":!pd.group<f64>>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.group<!pd.datetime>>, 
                    <"l_orderkey":!pd.group<i32>>, <"sum_qty": i32>, 
                    <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64> , <"sum_disc_price": f64>,
                    <"sum_charge": f64>, <"avg_disc": f64>,
                    <"count_order": !pd.group<i32>>>

        %final = pd.agg_count(%meaned: !pd.df<<"l_quantity": !pd.group<i32>>,
                    <"l_extendedprice":!pd.group<f64>>, <"l_discount":!pd.group<f64>>, 
                    <"l_tax":!pd.group<f64>>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.group<!pd.datetime>>, 
                    <"l_orderkey":!pd.group<i32>>, <"sum_qty": i32>, 
                    <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, <"sum_disc_price": f64>,
                    <"sum_charge": f64>, <"avg_disc": f64>,
                    <"count_order": !pd.group<i32>>>, ["count_order"]) : !pd.df<<"l_quantity": !pd.group<i32>>,
                    <"l_extendedprice":!pd.group<f64>>, <"l_discount":!pd.group<f64>>, 
                    <"l_tax":!pd.group<f64>>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.group<!pd.datetime>>, 
                    <"l_orderkey":!pd.group<i32>>, <"sum_qty": i32>, 
                    <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64> , <"sum_disc_price": f64>,
                    <"sum_charge": f64>, <"avg_disc": f64>,
                    <"count_order": i32>>

        %sort1 = pd.sortby(%final: !pd.df<<"l_quantity": !pd.group<i32>>,
                    <"l_extendedprice":!pd.group<f64>>, <"l_discount":!pd.group<f64>>, 
                    <"l_tax":!pd.group<f64>>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.group<!pd.datetime>>, 
                    <"l_orderkey":!pd.group<i32>>, <"sum_qty": i32>, 
                    <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, <"sum_disc_price": f64>,
                    <"sum_charge": f64>, <"avg_disc": f64>,
                    <"count_order": i32>>, "l_returnflag", "asc") : !pd.df<<"l_quantity": !pd.group<i32>>,
                    <"l_extendedprice":!pd.group<f64>>, <"l_discount":!pd.group<f64>>, 
                    <"l_tax":!pd.group<f64>>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.group<!pd.datetime>>, 
                    <"l_orderkey":!pd.group<i32>>, <"sum_qty": i32>, 
                    <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, <"sum_disc_price": f64>,
                    <"sum_charge": f64>, <"avg_disc": f64>,
                    <"count_order": i32>>

        %sort2 = pd.sortby(%sort1: !pd.df<<"l_quantity": !pd.group<i32>>,
                    <"l_extendedprice":!pd.group<f64>>, <"l_discount":!pd.group<f64>>, 
                    <"l_tax":!pd.group<f64>>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.group<!pd.datetime>>, 
                    <"l_orderkey":!pd.group<i32>>, <"sum_qty": i32>, 
                    <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, <"sum_disc_price": f64>,
                    <"sum_charge": f64>, <"avg_disc": f64>,
                    <"count_order": i32>>, "l_linestatus", "asc") : !pd.df<<"l_quantity": !pd.group<i32>>,
                    <"l_extendedprice":!pd.group<f64>>, <"l_discount":!pd.group<f64>>, 
                    <"l_tax":!pd.group<f64>>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.group<!pd.datetime>>, 
                    <"l_orderkey":!pd.group<i32>>, <"sum_qty": i32>, 
                    <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, <"sum_disc_price": f64>,
                    <"sum_charge": f64>, <"avg_disc": f64>,
                    <"count_order": i32>>

        pd.print(%sort2: !pd.df<<"l_quantity": !pd.group<i32>>,
                    <"l_extendedprice":!pd.group<f64>>, <"l_discount":!pd.group<f64>>, 
                    <"l_tax":!pd.group<f64>>,
                    <"l_returnflag":!pd.string>, <"l_linestatus":!pd.string>, 
                    <"l_shipdate":!pd.group<!pd.datetime>>, 
                    <"l_orderkey":!pd.group<i32>>, <"sum_qty": i32>, 
                    <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, <"sum_disc_price": f64>,
                    <"sum_charge": f64>, <"avg_disc": f64>,
                    <"count_order": i32>>)

        return
    }
}