module {
    func.func @q1() {
        %lineitem = pandas.read_csv("/home/ajayakar/compiler-project/data/lineitem.csv") : !pandas.df<
            <"l_orderkey":i32>, <"l_partkey":i32>, <"l_suppkey":i32>, <"l_linenumber":i32>,
            <"l_quantity":i32>, <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
            <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, <"l_shipdate":!pandas.datetime>, 
            <"l_commitdate":!pandas.datetime>,
            <"l_receiptdate":!pandas.datetime>, <"l_shipinstruct":!pandas.string>, <"l_shipmode":!pandas.string>, 
            <"comments": !pandas.string>>

        %lineitem_filtered = pandas.select(%lineitem: !pandas.df<
            <"l_orderkey":i32>, <"l_partkey":i32>, <"l_suppkey":i32>, <"l_linenumber":i32>,
            <"l_quantity":i32>, <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
            <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, <"l_shipdate":!pandas.datetime>, 
            <"l_commitdate":!pandas.datetime>,
            <"l_receiptdate":!pandas.datetime>, <"l_shipinstruct":!pandas.string>, <"l_shipmode":!pandas.string>, 
            <"comments": !pandas.string>>, ["l_quantity",
                "l_extendedprice",
                "l_discount",
                "l_tax",
                "l_returnflag",
                "l_linestatus",
                "l_shipdate",
                "l_orderkey"]) : !pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>, 
                    <"l_orderkey":i32>>

        %filter_indices = pandas.filter(%lineitem_filtered:!pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>, 
                    <"l_orderkey":i32>>, "l_shipdate" oeq "1998-09-02") : !pandas.series<"filter": i1>
        %lineitem_filtered_1 = pandas.filter_reduce(%lineitem_filtered:!pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>,
                    <"l_orderkey":i32>>, %filter_indices: !pandas.series<"filter": i1>) : !pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>, 
                    <"l_orderkey":i32>>

        %sum_qty = pandas.get_column(%lineitem_filtered_1: !pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>, 
                    <"l_orderkey":i32>>, "l_quantity") : !pandas.series<"l_quantity": i32>
        %lineitem_filtered_2 = pandas.add_column(%lineitem_filtered_1: !pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>, 
                    <"l_orderkey":i32>>, %sum_qty: !pandas.series<"l_quantity": i32>, "sum_qty") : !pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>>

        %sum_base_price = pandas.get_column(%lineitem_filtered_1: !pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>, 
                    <"l_orderkey":i32>>, "l_extendedprice") : !pandas.series<"l_extendedprice": f64>
        %lineitem_filtered_3 = pandas.add_column(%lineitem_filtered_2: !pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>>, %sum_base_price: !pandas.series<"l_extendedprice": f64>, "sum_base_price") 
                    : !pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>>             
        
        %avg_qty = pandas.get_column(%lineitem_filtered_1: !pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>, 
                    <"l_orderkey":i32>>, 
                    "l_quantity") 
                    : !pandas.series<"l_quantity": i32>
        %lineitem_filtered_4 = pandas.add_column(%lineitem_filtered_3: !pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>>, 
                    %avg_qty: !pandas.series<"l_quantity": i32>, "avg_qty") 
                    : !pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>>  

        %avg_price = pandas.get_column(%lineitem_filtered_1: !pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>, 
                    <"l_orderkey":i32>>, 
                    "l_quantity") 
                    : !pandas.series<"l_extendedprice": f64>
        %lineitem_filtered_5 = pandas.add_column(%lineitem_filtered_4: !pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>>, 
                    %avg_price: !pandas.series<"l_extendedprice": f64>, "avg_price") 
                    : !pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>> 

        %l_disc = pandas.get_column(%lineitem_filtered_5: !pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>> , "l_discount" ) : !pandas.series<"l_discount" : f64>
        %l_orkey = pandas.get_column(%lineitem_filtered_5: !pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>> , "l_orderkey" ) : !pandas.series<"l_orderkey" : i32>
        %const_1 = pandas.const_float(1.0) : !pandas.series<"const": f64>
        
        %diff_1 = pandas.sub(%const_1 : !pandas.series<"const": f64>, %l_disc: !pandas.series<"l_discount" : f64>)
                    : !pandas.series<"diff" : f64>
        %mul_1 = pandas.multiply(%avg_price: !pandas.series<"l_extendedprice": f64>, 
                            %diff_1: !pandas.series<"diff": f64>) : !pandas.series<"sum_disc_price": f64>
        %lineitem_filtered_6 = pandas.add_column(%lineitem_filtered_5: !pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>> , %mul_1: !pandas.series<"sum_disc_price": f64>, "sum_disc_price") : !pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, <"sum_disc_price": f64>>

        %l_tx = pandas.get_column(%lineitem_filtered_5: !pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>> , "l_tax" ) : !pandas.series<"l_tax" : f64>
        %diff_2 = pandas.add(%const_1 : !pandas.series<"const": f64>, %l_tx: !pandas.series<"l_tax" : f64>)
                    : !pandas.series<"sm" : f64>
        %mul_2 = pandas.multiply(%mul_1: !pandas.series<"sum_disc_price": f64>,
                            %diff_2: !pandas.series<"sm": f64>) : !pandas.series<"sum_charge": f64>
        %lineitem_filtered_7 = pandas.add_column(%lineitem_filtered_6: !pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, <"sum_disc_price": f64>>, %mul_2: !pandas.series<"sum_charge": f64>,
                    "sum_charge") : !pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, <"sum_disc_price": f64>, <"sum_charge": f64>>
        
        %lineitem_filtered_8 = pandas.add_column(%lineitem_filtered_7: !pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, <"sum_disc_price": f64>, <"sum_charge": f64>>, 
                    %l_disc: !pandas.series<"l_discount": f64>, "avg_disc") : !pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, <"sum_disc_price": f64>, <"sum_charge": f64>, <"avg_disc": f64>>

        %lineitem_filtered_9 = pandas.add_column(%lineitem_filtered_8: !pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, <"sum_disc_price": f64>, <"sum_charge": f64>, <"avg_disc": f64>>, 
                    %l_orkey: !pandas.series<"l_orderkey": i32>, "count_order") : !pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, <"sum_disc_price": f64>, <"sum_charge": f64>, <"avg_disc": f64>,
                    <"count_order": i32>>


        %gb = pandas.groupby(%lineitem_filtered_9: !pandas.df<<"l_quantity": i32>,
                    <"l_extendedprice":f64>, <"l_discount":f64>, <"l_tax":f64>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.datetime>, 
                    <"l_orderkey":i32>, <"sum_qty": i32>, <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, <"sum_disc_price": f64>, <"sum_charge": f64>, <"avg_disc": f64>,
                    <"count_order": i32>>, ["l_returnflag", "l_linestatus"] ) :  
                    !pandas.df<<"l_quantity": !pandas.group<i32>>,
                    <"l_extendedprice":!pandas.group<f64>>, <"l_discount":!pandas.group<f64>>, 
                    <"l_tax":!pandas.group<f64>>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.group<!pandas.datetime>>, 
                    <"l_orderkey":!pandas.group<i32>>, <"sum_qty": !pandas.group<i32>>, 
                    <"sum_base_price": !pandas.group<f64>>, <"avg_qty": !pandas.group<i32>>,
                    <"avg_price": !pandas.group<f64>>, <"sum_disc_price": !pandas.group<f64>>,
                    <"sum_charge": !pandas.group<f64>>, <"avg_disc": !pandas.group<f64>>,
                    <"count_order": !pandas.group<i32>>>

        %summed = pandas.agg_sum(%gb: !pandas.df<<"l_quantity": !pandas.group<i32>>,
                    <"l_extendedprice":!pandas.group<f64>>, <"l_discount":!pandas.group<f64>>, 
                    <"l_tax":!pandas.group<f64>>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.group<!pandas.datetime>>, 
                    <"l_orderkey":!pandas.group<i32>>, <"sum_qty": !pandas.group<i32>>, 
                    <"sum_base_price": !pandas.group<f64>>, <"avg_qty": !pandas.group<i32>>,
                    <"avg_price": !pandas.group<f64>>, <"sum_disc_price": !pandas.group<f64>>,
                    <"sum_charge": !pandas.group<f64>>, <"avg_disc": !pandas.group<f64>>,
                    <"count_order": !pandas.group<i32>>>, ["sum_qty", "sum_base_price", "sum_disc_price",
                    "sum_charge"]) : !pandas.df<<"l_quantity": !pandas.group<i32>>,
                    <"l_extendedprice":!pandas.group<f64>>, <"l_discount":!pandas.group<f64>>, 
                    <"l_tax":!pandas.group<f64>>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.group<!pandas.datetime>>, 
                    <"l_orderkey":!pandas.group<i32>>, <"sum_qty": i32>, 
                    <"sum_base_price": f64>, <"avg_qty": !pandas.group<i32>>,
                    <"avg_price": !pandas.group<f64>>, <"sum_disc_price": f64>,
                    <"sum_charge": f64>, <"avg_disc": !pandas.group<f64>>,
                    <"count_order": !pandas.group<i32>>>

        %meaned = pandas.agg_mean(%summed: !pandas.df<<"l_quantity": !pandas.group<i32>>,
                    <"l_extendedprice":!pandas.group<f64>>, <"l_discount":!pandas.group<f64>>, 
                    <"l_tax":!pandas.group<f64>>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.group<!pandas.datetime>>, 
                    <"l_orderkey":!pandas.group<i32>>, <"sum_qty": i32>, 
                    <"sum_base_price": f64>, <"avg_qty": !pandas.group<i32>>,
                    <"avg_price": !pandas.group<f64>>, <"sum_disc_price": f64>,
                    <"sum_charge": f64>, <"avg_disc": !pandas.group<f64>>,
                    <"count_order": !pandas.group<i32>>>, ["avg_qty", "avg_price", "avg_disc"]) : !pandas.df<<"l_quantity": !pandas.group<i32>>,
                    <"l_extendedprice":!pandas.group<f64>>, <"l_discount":!pandas.group<f64>>, 
                    <"l_tax":!pandas.group<f64>>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.group<!pandas.datetime>>, 
                    <"l_orderkey":!pandas.group<i32>>, <"sum_qty": i32>, 
                    <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, , <"sum_disc_price": f64>,
                    <"sum_charge": f64>, <"avg_disc": f64>,
                    <"count_order": !pandas.group<i32>>>

        %final = pandas.agg_count(%meaned: !pandas.df<<"l_quantity": !pandas.group<i32>>,
                    <"l_extendedprice":!pandas.group<f64>>, <"l_discount":!pandas.group<f64>>, 
                    <"l_tax":!pandas.group<f64>>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.group<!pandas.datetime>>, 
                    <"l_orderkey":!pandas.group<i32>>, <"sum_qty": i32>, 
                    <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, , <"sum_disc_price": f64>,
                    <"sum_charge": f64>, <"avg_disc": f64>,
                    <"count_order": !pandas.group<i32>>>, ["count_order"]) : !pandas.df<<"l_quantity": !pandas.group<i32>>,
                    <"l_extendedprice":!pandas.group<f64>>, <"l_discount":!pandas.group<f64>>, 
                    <"l_tax":!pandas.group<f64>>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.group<!pandas.datetime>>, 
                    <"l_orderkey":!pandas.group<i32>>, <"sum_qty": i32>, 
                    <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, , <"sum_disc_price": f64>,
                    <"sum_charge": f64>, <"avg_disc": f64>,
                    <"count_order": i32>>

        %sort1 = pandas.sortby(%final: !!pandas.df<<"l_quantity": !pandas.group<i32>>,
                    <"l_extendedprice":!pandas.group<f64>>, <"l_discount":!pandas.group<f64>>, 
                    <"l_tax":!pandas.group<f64>>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.group<!pandas.datetime>>, 
                    <"l_orderkey":!pandas.group<i32>>, <"sum_qty": i32>, 
                    <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, , <"sum_disc_price": f64>,
                    <"sum_charge": f64>, <"avg_disc": f64>,
                    <"count_order": i32>>, "l_returnflag") : !pandas.df<<"l_quantity": !pandas.group<i32>>,
                    <"l_extendedprice":!pandas.group<f64>>, <"l_discount":!pandas.group<f64>>, 
                    <"l_tax":!pandas.group<f64>>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.group<!pandas.datetime>>, 
                    <"l_orderkey":!pandas.group<i32>>, <"sum_qty": i32>, 
                    <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, , <"sum_disc_price": f64>,
                    <"sum_charge": f64>, <"avg_disc": f64>,
                    <"count_order": i32>>

        %sort2 = pandas.sortby(%sort1: !pandas.df<<"l_quantity": !pandas.group<i32>>,
                    <"l_extendedprice":!pandas.group<f64>>, <"l_discount":!pandas.group<f64>>, 
                    <"l_tax":!pandas.group<f64>>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.group<!pandas.datetime>>, 
                    <"l_orderkey":!pandas.group<i32>>, <"sum_qty": i32>, 
                    <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, , <"sum_disc_price": f64>,
                    <"sum_charge": f64>, <"avg_disc": f64>,
                    <"count_order": i32>>, "l_linestatus") : !pandas.df<<"l_quantity": !pandas.group<i32>>,
                    <"l_extendedprice":!pandas.group<f64>>, <"l_discount":!pandas.group<f64>>, 
                    <"l_tax":!pandas.group<f64>>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.group<!pandas.datetime>>, 
                    <"l_orderkey":!pandas.group<i32>>, <"sum_qty": i32>, 
                    <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>, , <"sum_disc_price": f64>,
                    <"sum_charge": f64>, <"avg_disc": f64>,
                    <"count_order": i32>>

        pandas.print(%sort2: !pandas.df<<"l_quantity": !pandas.group<i32>>,
                    <"l_extendedprice":!pandas.group<f64>>, <"l_discount":!pandas.group<f64>>, 
                    <"l_tax":!pandas.group<f64>>,
                    <"l_returnflag":!pandas.string>, <"l_linestatus":!pandas.string>, 
                    <"l_shipdate":!pandas.group<!pandas.datetime>>, 
                    <"l_orderkey":!pandas.group<i32>>, <"sum_qty": i32>, 
                    <"sum_base_price": f64>, <"avg_qty": i32>,
                    <"avg_price": f64>>)

        return
    }
}