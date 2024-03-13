module {
    func.func @q3() {
        %lineitem_df = pandas.read_csv("/home/ajayakar/compiler-project/data/lineitem.csv") : 
            !pandas.df<<"l_orderkey":i32>, <"l_partkey":i32>, 
            <"l_suppkey":i32>, <"l_linenumber":i32>,
            <"l_quantity":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_tax":f64>, <"l_returnflag":!pandas.string>, 
            <"l_linestatus":!pandas.string>, <"l_shipdate":!pandas.datetime>, 
            <"l_commitdate":!pandas.datetime>, <"l_receiptdate":!pandas.datetime>, 
            <"l_shipinstruct":!pandas.string>, <"l_shipmode":!pandas.string>, 
            <"comments": !pandas.string>>

        %lineitem_filtered = pandas.select(%lineitem_df: 
            !pandas.df<<"l_orderkey":i32>, <"l_partkey":i32>, 
            <"l_suppkey":i32>, <"l_linenumber":i32>,
            <"l_quantity":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_tax":f64>, <"l_returnflag":!pandas.string>, 
            <"l_linestatus":!pandas.string>, <"l_shipdate":!pandas.datetime>, 
            <"l_commitdate":!pandas.datetime>, <"l_receiptdate":!pandas.datetime>, 
            <"l_shipinstruct":!pandas.string>, <"l_shipmode":!pandas.string>, 
            <"comments": !pandas.string>>,
            ["l_quantity", "l_extendedprice", "l_discount", "l_shipdate"]) :
            !pandas.df<<"l_quantity":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pandas.datetime>>

        %sel1 = pandas.filter(%lineitem_filtered: !pandas.df<<"l_quantity":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pandas.datetime>>,
            "l_shipdate" oge "1994-01-01") :
            !pandas.series<"sel1": i1>

        %sel2 =  pandas.filter(%lineitem_filtered: !pandas.df<<"l_quantity":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pandas.datetime>>,
            "l_shipdate" ole "1995-01-01") :
            !pandas.series<"sel2": i1>
        
        %sel3 = pandas.filter(%lineitem_filtered: !pandas.df<<"l_quantity":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pandas.datetime>>,
            "l_discount" oge "0.05") :
            !pandas.series<"sel3": i1>
        %sel4 = pandas.filter(%lineitem_filtered: !pandas.df<<"l_quantity":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pandas.datetime>>,
            "l_discount" ole "0.07") :
            !pandas.series<"sel4": i1>

        %s1 = pandas.multiply(%sel1: !pandas.series<"sel1": i1>,
            %sel2: !pandas.series<"sel2": i1>) : !pandas.series<"s1": i1>
        %s2 = pandas.multiply(%sel3: !pandas.series<"sel3": i1>,
            %sel4: !pandas.series<"sel4": i1>) : !pandas.series<"s2": i1>
        %sel = pandas.multiply(%s1: !pandas.series<"s1": i1>,
            %s2: !pandas.series<"s2": i1>) : !pandas.series<"sel": i1>

        %flineitem = pandas.filter_reduce(%lineitem_filtered: 
            !pandas.df<<"l_quantity":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pandas.datetime>>,
            %sel: !pandas.series<"sel": i1>) : 
            !pandas.df<<"l_quantity":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pandas.datetime>>
        
        %flineitem_lextendedprice = pandas.get_column(%flineitem: 
            !pandas.df<<"l_quantity":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pandas.datetime>>,
            "l_extendedprice"): <"l_extendedprice": f64>

        %flineitem_discount = pandas.get_column(%flineitem: 
            !pandas.df<<"l_quantity":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pandas.datetime>>,
            "l_discount"): <"l_discount": f64>

        %prod = pandas.multiply(%flineitem_lextendedprice:  <"l_extendedprice": f64>,
            %flineitem_discount:  <"l_discount": f64>) :
            <"prod": f64>

        %result = pandas.agg_sum(%prod: !pandas.series<"prod": f64>, ["prod"]) :
         !pandas.series<"prod": f64>

        pandas.print(%result: !pandas.series<"prod": f64>)
        return
    }
}