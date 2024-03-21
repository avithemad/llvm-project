module {
    func.func @q3() {
        %customer_df = pd.read_csv("/home/ajayakar/compiler-project/data/customer.csv") :
                !pd.df<<"c_custkey" : i32>,<"c_name" : !pd.string>,
                <"c_address" : !pd.string>, <"c_nationkey" : i32>,
                <"c_phone" : !pd.string >, <"c_acctbal": f64>,
                <"c_mktsegment" : !pd.string>, <"c_comment": !pd.string>>
        %lineitem_df = pd.read_csv("/home/ajayakar/compiler-project/data/lineitem.csv") : 
            !pd.df<<"l_orderkey":i32>, <"l_partkey":i32>, 
            <"l_suppkey":i32>, <"l_linenumber":i32>,
            <"l_quantity":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_tax":f64>, <"l_returnflag":!pd.string>, 
            <"l_linestatus":!pd.string>, <"l_shipdate":!pd.datetime>, 
            <"l_commitdate":!pd.datetime>, <"l_receiptdate":!pd.datetime>, 
            <"l_shipinstruct":!pd.string>, <"l_shipmode":!pd.string>, 
            <"comments": !pd.string>>
        %order_df = pd.read_csv("/home/ajayakar/compiler-project/data/orders.csv") :
            !pd.df<<"o_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderstatus": !pd.string>,<"o_totalprice": i32>,
            <"o_orderdate": !pd.datetime>,<"o_orderpriority": !pd.string>,
            <"o_clerk": !pd.string>, <"o_shippriority": i32>,
            <"o_comment": !pd.string>>

        %lineitem_filtered = pd.select(%lineitem_df: 
            !pd.df<<"l_orderkey":i32>, <"l_partkey":i32>, 
            <"l_suppkey":i32>, <"l_linenumber":i32>,
            <"l_quantity":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_tax":f64>, <"l_returnflag":!pd.string>, 
            <"l_linestatus":!pd.string>, <"l_shipdate":!pd.datetime>, 
            <"l_commitdate":!pd.datetime>, <"l_receiptdate":!pd.datetime>, 
            <"l_shipinstruct":!pd.string>, <"l_shipmode":!pd.string>, 
            <"comments": !pd.string>>,
            ["l_orderkey", "l_extendedprice", "l_discount", "l_shipdate"]) : 
            !pd.df<<"l_orderkey":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pd.datetime>>

        %orders_filtered = pd.select(%order_df: 
            !pd.df<<"o_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderstatus": !pd.string>,<"o_totalprice": i32>,
            <"o_orderdate": !pd.datetime>,<"o_orderpriority": !pd.string>,
            <"o_clerk": !pd.string>, <"o_shippriority": i32>,
            <"o_comment": !pd.string>>, 
            ["o_orderkey", "o_custkey", "o_orderdate", "o_shippriority"]) :
            !pd.df<<"o_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderdate": !pd.datetime>, <"o_shippriority": i32>>

        %customer_filtered = pd.select(%customer_df: 
                !pd.df<<"c_custkey" : i32>,<"c_name" : !pd.string>,
                <"c_address" : !pd.string>, <"c_nationkey" : i32>,
                <"c_phone" : !pd.string >, <"c_acctbal": f64>,
                <"c_mktsegment" : !pd.string>, <"c_comment": !pd.string>>,
                ["c_mktsegment", "c_custkey"]) : 
                !pd.df<<"c_custkey" : i32>, <"c_mktsegment" : !pd.string>>
        
        %lsel = pd.filter(%lineitem_filtered: !pd.df<<"l_orderkey":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pd.datetime>>,
            "l_shipdate" oeq "1995-03-15" ) : !pd.ser<"lsel": i1>
        %osel = pd.filter(%orders_filtered: !pd.df<<"o_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderdate": !pd.datetime>, <"o_shippriority": i32>>,
            "o_orderdate" oeq "1995-03-15" ) : !pd.ser<"osel": i1>
        %csel = pd.filter(%customer_filtered: !pd.df<<"c_custkey" : i32>, <"c_mktsegment" : !pd.string>>,
            "c_mktsegment" true "BUILDING" ) : !pd.ser<"csel": i1>
        
        %flineitem = pd.filter_reduce(%lineitem_filtered: !pd.df<<"l_orderkey":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pd.datetime>>,
            %lsel: !pd.ser<"lsel": i1>) :
            !pd.df<<"l_orderkey":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pd.datetime>>
        %forders = pd.filter_reduce(%orders_filtered: !pd.df<<"o_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderdate": !pd.datetime>, <"o_shippriority": i32>>,
            %osel: !pd.ser<"osel": i1>) :
            !pd.df<<"o_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderdate": !pd.datetime>, <"o_shippriority": i32>>
        %fcustomer = pd.filter_reduce(%customer_filtered: !pd.df<<"c_custkey" : i32>, <"c_mktsegment" : !pd.string>>,
            %csel:  !pd.ser<"csel": i1>) : !pd.df<<"c_custkey" : i32>, <"c_mktsegment" : !pd.string>>
        
        %jn1 = pd.join(%forders: !pd.df<<"o_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderdate": !pd.datetime>, <"o_shippriority": i32>>,
            %fcustomer: !pd.df<<"c_custkey" : i32>, <"c_mktsegment" : !pd.string>>, 
            ["o_custkey"], ["c_custkey"]) : 
            !pd.df<<"o_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderdate": !pd.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pd.string>>
        %jn2 = pd.join(%jn1: 
            !pd.df<<"o_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderdate": !pd.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pd.string>>,
            %flineitem: !pd.df<<"l_orderkey":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pd.datetime>>,
            ["o_orderkey"], ["l_orderkey"]) :
            !pd.df<<"l_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderdate": !pd.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pd.string>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pd.datetime>>
        
        %jn2_ldisc = pd.get_column(%jn2: !pd.df<<"l_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderdate": !pd.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pd.string>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pd.datetime>>,
            "l_discount") : !pd.ser<"l_discount": f64>
        %const1 = pd.const_float(1.0): !pd.ser<"const": f64>
        %sub1 = pd.sub(%const1: !pd.ser<"const": f64>,
                    %jn2_ldisc: !pd.ser<"l_discount": f64>) :
                    !pd.ser<"sub": f64>
        %jn2_revenue = pd.multiply(%jn2_ldisc: !pd.ser<"l_discount": f64>,
                        %sub1: !pd.ser<"sub": f64>) : !pd.ser<"jn2_revenue": f64>
        
        %jn2_1 = pd.add_column(%jn2: !pd.df<<"l_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderdate": !pd.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pd.string>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pd.datetime>>,
            %jn2_revenue: !pd.ser<"jn2_revenue": f64>,
            "revenue") : !pd.df<<"l_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderdate": !pd.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pd.string>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pd.datetime>,
            <"revenue": f64>>

        %groupby = pd.groupby(%jn2_1: !pd.df<<"l_orderkey": i32>,<"o_custkey": i32>,
            <"o_orderdate": !pd.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pd.string>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pd.datetime>,
            <"revenue": f64>>, ["l_orderkey", "o_orderdate", "o_shippriority"]) :
            !pd.df<<"l_orderkey": i32>,<"o_custkey": !pd.group<i32>>,
            <"o_orderdate": !pd.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pd.group<!pd.string>>, <"l_extendedprice":!pd.group<f64>>, 
            <"l_discount":!pd.group<f64>>, <"l_shipdate":!pd.group<!pd.datetime>>,
            <"revenue": !pd.group<f64>>>
        
        %aggsum = pd.agg_sum(%groupby: !pd.df<<"l_orderkey": i32>,<"o_custkey": !pd.group<i32>>,
            <"o_orderdate": !pd.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pd.group<!pd.string>>, <"l_extendedprice":!pd.group<f64>>, 
            <"l_discount":!pd.group<f64>>, <"l_shipdate":!pd.group<!pd.datetime>>,
            <"revenue": !pd.group<f64>>>, ["revenue"]) : !pd.df<<"l_orderkey": i32>,<"o_custkey": !pd.group<i32>>,
            <"o_orderdate": !pd.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pd.group<!pd.string>>, <"l_extendedprice":!pd.group<f64>>, 
            <"l_discount":!pd.group<f64>>, <"l_shipdate":!pd.group<!pd.datetime>>,
            <"revenue": f64>>

        %sorted = pd.sortby(%aggsum: !pd.df<<"l_orderkey": i32>,<"o_custkey": !pd.group<i32>>,
            <"o_orderdate": !pd.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pd.group<!pd.string>>, <"l_extendedprice":!pd.group<f64>>, 
            <"l_discount":!pd.group<f64>>, <"l_shipdate":!pd.group<!pd.datetime>>,
            <"revenue": f64>>, "revenue", "asc") : 
            !pd.df<<"l_orderkey": i32>,<"o_custkey": !pd.group<i32>>,
            <"o_orderdate": !pd.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pd.group<!pd.string>>, <"l_extendedprice":!pd.group<f64>>, 
            <"l_discount":!pd.group<f64>>, <"l_shipdate":!pd.group<!pd.datetime>>,
            <"revenue": f64>>

        %first_ten = pd.filter_range %sorted: !pd.df<<"l_orderkey": i32>,<"o_custkey": !pd.group<i32>>,
            <"o_orderdate": !pd.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pd.group<!pd.string>>, <"l_extendedprice":!pd.group<f64>>, 
            <"l_discount":!pd.group<f64>>, <"l_shipdate":!pd.group<!pd.datetime>>,
            <"revenue": f64>> [0:10] 
            !pd.df<<"l_orderkey": i32>,<"o_custkey": !pd.group<i32>>,
            <"o_orderdate": !pd.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pd.group<!pd.string>>, <"l_extendedprice":!pd.group<f64>>, 
            <"l_discount":!pd.group<f64>>, <"l_shipdate":!pd.group<!pd.datetime>>,
            <"revenue": f64>>

        %final_out = pd.select(%first_ten: !pd.df<<"l_orderkey": i32>,<"o_custkey": !pd.group<i32>>,
            <"o_orderdate": !pd.datetime>, <"o_shippriority": i32>, 
            <"c_mktsegment" : !pd.group<!pd.string>>, <"l_extendedprice":!pd.group<f64>>, 
            <"l_discount":!pd.group<f64>>, <"l_shipdate":!pd.group<!pd.datetime>>,
            <"revenue": f64>>, 
            ["l_orderkey", "revenue", "o_orderdate", "o_shippriority"]) :
            !pd.df<<"l_orderkey": i32>,
            <"o_orderdate": !pd.datetime>, <"o_shippriority": i32>, 
            <"revenue": f64>>

        pd.print(%final_out: !pd.df<<"l_orderkey": i32>,
            <"o_orderdate": !pd.datetime>, <"o_shippriority": i32>, 
            <"revenue": f64>>)
        return
    }
}