module {
    func.func @q3() {
        %customer_df = pandas.read_csv("/home/ajayakar/compiler-project/data/customer.csv") :
                !pandas.df<<"c_custkey" : i32>,<"c_name" : !pandas.string>,
                <"c_address" : !pandas.string>, <"c_nationkey" : i32>,
                <"c_phone" : !pandas.string >, <"c_acctbal": f64>,
                <"c_mktsegment" : !pandas.string>, <"c_comment": !pandas.string>>
        %lineitem_df = pandas.read_csv("/home/ajayakar/compiler-project/data/lineitem.csv") : 
            !pandas.df<<"l_orderkey":i32>, <"l_partkey":i32>, 
            <"l_suppkey":i32>, <"l_linenumber":i32>,
            <"l_quantity":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_tax":f64>, <"l_returnflag":!pandas.string>, 
            <"l_linestatus":!pandas.string>, <"l_shipdate":!pandas.datetime>, 
            <"l_commitdate":!pandas.datetime>, <"l_receiptdate":!pandas.datetime>, 
            <"l_shipinstruct":!pandas.string>, <"l_shipmode":!pandas.string>, 
            <"comments": !pandas.string>>
        %order_df = pandas.read_csv("/home/ajayakar/compiler-project/data/orders.csv") :
            !pandas.df<<"o_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderstatus": !pandas.string>,<"o_totalprice": i32>,
            <"o_orderdate": !pandas.datetime>,<"o_orderpriority": !pandas.string>,
            <"o_clerk": !pandas.string>, <"o_shippriority": i32>,
            <"o_comment": !pandas.string>>

        %lineitem_filtered = pandas.select(%lineitem_df: 
            !pandas.df<<"l_orderkey":i32>, <"l_partkey":i32>, 
            <"l_suppkey":i32>, <"l_linenumber":i32>,
            <"l_quantity":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_tax":f64>, <"l_returnflag":!pandas.string>, 
            <"l_linestatus":!pandas.string>, <"l_shipdate":!pandas.datetime>, 
            <"l_commitdate":!pandas.datetime>, <"l_receiptdate":!pandas.datetime>, 
            <"l_shipinstruct":!pandas.string>, <"l_shipmode":!pandas.string>, 
            <"comments": !pandas.string>>,
            ["l_orderkey", "l_extendedprice", "l_discount", "l_shipdate"]) : 
            !pandas.df<<"l_orderkey":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pandas.datetime>>

        %orders_filtered = pandas.select(%order_df: 
            !pandas.df<<"o_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderstatus": !pandas.string>,<"o_totalprice": i32>,
            <"o_orderdate": !pandas.datetime>,<"o_orderpriority": !pandas.string>,
            <"o_clerk": !pandas.string>, <"o_shippriority": i32>,
            <"o_comment": !pandas.string>>, 
            ["o_orderkey", "o_custkey", "o_orderdate", "o_shippriority"]) :
            !pandas.df<<"o_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderdate": !pandas.datetime>, <"o_shippriority": i32>>

        %customer_filtered = pandas.select(%customer_df: 
                !pandas.df<<"c_custkey" : i32>,<"c_name" : !pandas.string>,
                <"c_address" : !pandas.string>, <"c_nationkey" : i32>,
                <"c_phone" : !pandas.string >, <"c_acctbal": f64>,
                <"c_mktsegment" : !pandas.string>, <"c_comment": !pandas.string>>,
                ["c_mktsegment", "c_custkey"]) : 
                !pandas.df<<"c_custkey" : i32>, <"c_mktsegment" : !pandas.string>>
        
        %lsel = pandas.filter(%lineitem_filtered: !pandas.df<<"l_orderkey":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pandas.datetime>>,
            "l_shipdate" oeq "1995-03-15" ) : !pandas.series<"lsel": i1>
        %osel = pandas.filter(%orders_filtered: !pandas.df<<"o_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderdate": !pandas.datetime>, <"o_shippriority": i32>>,
            "o_orderdate" oeq "1995-03-15" ) : !pandas.series<"osel": i1>
        %csel = pandas.filter(%customer_filtered: !pandas.df<<"c_custkey" : i32>, <"c_mktsegment" : !pandas.string>>,
            "c_mktsegment" true "BUILDING" ) : !pandas.series<"csel": i1>
        
        %flineitem = pandas.filter_reduce(%lineitem_filtered: !pandas.df<<"l_orderkey":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pandas.datetime>>,
            %lsel: !pandas.series<"lsel": i1>) :
            !pandas.df<<"l_orderkey":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pandas.datetime>>
        %forders = pandas.filter_reduce(%orders_filtered: !pandas.df<<"o_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderdate": !pandas.datetime>, <"o_shippriority": i32>>,
            %osel: !pandas.series<"osel": i1>) :
            !pandas.df<<"o_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderdate": !pandas.datetime>, <"o_shippriority": i32>>
        %fcustomer = pandas.filter_reduce(%customer_filtered: !pandas.df<<"c_custkey" : i32>, <"c_mktsegment" : !pandas.string>>,
            %csel:  !pandas.series<"csel": i1>) : !pandas.df<<"c_custkey" : i32>, <"c_mktsegment" : !pandas.string>>
        
        %jn1 = pandas.join(%forders: !pandas.df<<"o_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderdate": !pandas.datetime>, <"o_shippriority": i32>>,
            %fcustomer: !pandas.df<<"c_custkey" : i32>, <"c_mktsegment" : !pandas.string>>, 
            ["o_custkey"], ["c_custkey"]) : 
            !pandas.df<<"o_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderdate": !pandas.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pandas.string>>
        %jn2 = pandas.join(%jn1: 
            !pandas.df<<"o_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderdate": !pandas.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pandas.string>>,
            %flineitem: !pandas.df<<"l_orderkey":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pandas.datetime>>,
            ["o_orderkey"], ["l_orderkey"]) :
            !pandas.df<<"l_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderdate": !pandas.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pandas.string>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pandas.datetime>>
        
        %jn2_ldisc = pandas.get_column(%jn2: !pandas.df<<"l_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderdate": !pandas.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pandas.string>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pandas.datetime>>,
            "l_discount") : !pandas.series<"l_discount": f64>
        %const1 = pandas.const_float(1.0): !pandas.series<"const": f64>
        %sub1 = pandas.sub(%const1: !pandas.series<"const": f64>,
                    %jn2_ldisc: !pandas.series<"l_discount": f64>) :
                    !pandas.series<"sub": f64>
        %jn2_revenue = pandas.multiply(%jn2_ldisc: !pandas.series<"l_discount": f64>,
                        %sub1: !pandas.series<"sub": f64>) : !pandas.series<"jn2_revenue": f64>
        
        %jn2_1 = pandas.add_column(%jn2: !pandas.df<<"l_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderdate": !pandas.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pandas.string>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pandas.datetime>>,
            %jn2_revenue: !pandas.series<"jn2_revenue": f64>,
            "revenue") : !pandas.df<<"l_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderdate": !pandas.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pandas.string>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pandas.datetime>,
            <"revenue": f64>>

        %groupby = pandas.groupby(%jn2_1: !pandas.df<<"l_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderdate": !pandas.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pandas.string>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pandas.datetime>,
            <"revenue": f64>>, ["l_orderkey", "o_orderdate", "o_shippriority"]) :
            !pandas.df<<"l_orderkey": i32>,<"o_custkey": !pandas.group<i32>>,
            <"o_orderdate": !pandas.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pandas.group<!pandas.string>>, <"l_extendedprice":!pandas.group<f64>>, 
            <"l_discount":!pandas.group<f64>>, <"l_shipdate":!pandas.group<!pandas.datetime>>,
            <"revenue": !pandas.group<f64>>>
        
        %aggsum = pandas.agg_sum(%groupby: !pandas.df<<"l_orderkey": i32>,<"o_custkey": !pandas.group<i32>>,
            <"o_orderdate": !pandas.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pandas.group<!pandas.string>>, <"l_extendedprice":!pandas.group<f64>>, 
            <"l_discount":!pandas.group<f64>>, <"l_shipdate":!pandas.group<!pandas.datetime>>,
            <"revenue": !pandas.group<f64>>>, ["revenue"]) : !pandas.df<<"l_orderkey": i32>,<"o_custkey": !pandas.group<i32>>,
            <"o_orderdate": !pandas.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pandas.group<!pandas.string>>, <"l_extendedprice":!pandas.group<f64>>, 
            <"l_discount":!pandas.group<f64>>, <"l_shipdate":!pandas.group<!pandas.datetime>>,
            <"revenue": f64>>

        %sorted = pandas.sortby(%aggsum: !pandas.df<<"l_orderkey": i32>,<"o_custkey": !pandas.group<i32>>,
            <"o_orderdate": !pandas.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pandas.group<!pandas.string>>, <"l_extendedprice":!pandas.group<f64>>, 
            <"l_discount":!pandas.group<f64>>, <"l_shipdate":!pandas.group<!pandas.datetime>>,
            <"revenue": f64>>, "revenue") : 
            !pandas.df<<"l_orderkey": i32>,<"o_custkey": !pandas.group<i32>>,
            <"o_orderdate": !pandas.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pandas.group<!pandas.string>>, <"l_extendedprice":!pandas.group<f64>>, 
            <"l_discount":!pandas.group<f64>>, <"l_shipdate":!pandas.group<!pandas.datetime>>,
            <"revenue": f64>>

        %first_ten = pandas.filter_range %sorted: !pandas.df<<"l_orderkey": i32>,<"o_custkey": !pandas.group<i32>>,
            <"o_orderdate": !pandas.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pandas.group<!pandas.string>>, <"l_extendedprice":!pandas.group<f64>>, 
            <"l_discount":!pandas.group<f64>>, <"l_shipdate":!pandas.group<!pandas.datetime>>,
            <"revenue": f64>> [0:10] 
            !pandas.df<<"l_orderkey": i32>,<"o_custkey": !pandas.group<i32>>,
            <"o_orderdate": !pandas.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pandas.group<!pandas.string>>, <"l_extendedprice":!pandas.group<f64>>, 
            <"l_discount":!pandas.group<f64>>, <"l_shipdate":!pandas.group<!pandas.datetime>>,
            <"revenue": f64>>

        %final_out = pandas.select(%first_ten: !pandas.df<<"l_orderkey": i32>,<"o_custkey": !pandas.group<i32>>,
            <"o_orderdate": !pandas.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pandas.group<!pandas.string>>, <"l_extendedprice":!pandas.group<f64>>, 
            <"l_discount":!pandas.group<f64>>, <"l_shipdate":!pandas.group<!pandas.datetime>>,
            <"revenue": f64>>, 
            ["l_orderkey", "revenue", "o_orderdate", "o_shippriority"]) :
            !pandas.df<<"l_orderkey": i32>,
            <"o_orderdate": !pandas.datetime>, <"o_shippriority": i32>, 
            <"revenue": f64>>

        pandas.print(%final_out: !pandas.df<<"l_orderkey": i32>,
            <"o_orderdate": !pandas.datetime>, <"o_shippriority": i32>, 
            <"revenue": f64>>)
        return
    }
}