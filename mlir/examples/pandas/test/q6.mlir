module {
    func.func @q3() {
        %lineitem_df = pd.read_csv("/home/ajayakar/compiler-project/data/lineitem.csv") : 
            !pd.df<<"l_orderkey":i32>, <"l_partkey":i32>, 
            <"l_suppkey":i32>, <"l_linenumber":i32>,
            <"l_quantity":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_tax":f64>, <"l_returnflag":!pd.string>, 
            <"l_linestatus":!pd.string>, <"l_shipdate":!pd.datetime>, 
            <"l_commitdate":!pd.datetime>, <"l_receiptdate":!pd.datetime>, 
            <"l_shipinstruct":!pd.string>, <"l_shipmode":!pd.string>, 
            <"comments": !pd.string>>

        %lineitem_filtered = pd.select(%lineitem_df: 
            !pd.df<<"l_orderkey":i32>, <"l_partkey":i32>, 
            <"l_suppkey":i32>, <"l_linenumber":i32>,
            <"l_quantity":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_tax":f64>, <"l_returnflag":!pd.string>, 
            <"l_linestatus":!pd.string>, <"l_shipdate":!pd.datetime>, 
            <"l_commitdate":!pd.datetime>, <"l_receiptdate":!pd.datetime>, 
            <"l_shipinstruct":!pd.string>, <"l_shipmode":!pd.string>, 
            <"comments": !pd.string>>,
            ["l_quantity", "l_extendedprice", "l_discount", "l_shipdate"]) :
            !pd.df<<"l_quantity":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pd.datetime>>

        %sel1 = pd.filter(%lineitem_filtered: !pd.df<<"l_quantity":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pd.datetime>>,
            "l_shipdate" oge "1994-01-01") :
            !pd.ser<"sel1": i1>

        %sel2 =  pd.filter(%lineitem_filtered: !pd.df<<"l_quantity":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pd.datetime>>,
            "l_shipdate" ole "1995-01-01") :
            !pd.ser<"sel2": i1>
        
        %sel3 = pd.filter(%lineitem_filtered: !pd.df<<"l_quantity":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pd.datetime>>,
            "l_discount" oge "0.05") :
            !pd.ser<"sel3": i1>
        %sel4 = pd.filter(%lineitem_filtered: !pd.df<<"l_quantity":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pd.datetime>>,
            "l_discount" ole "0.07") :
            !pd.ser<"sel4": i1>

        %s1 = pd.multiply(%sel1: !pd.ser<"sel1": i1>,
            %sel2: !pd.ser<"sel2": i1>) : !pd.ser<"s1": i1>
        %s2 = pd.multiply(%sel3: !pd.ser<"sel3": i1>,
            %sel4: !pd.ser<"sel4": i1>) : !pd.ser<"s2": i1>
        %sel = pd.multiply(%s1: !pd.ser<"s1": i1>,
            %s2: !pd.ser<"s2": i1>) : !pd.ser<"sel": i1>

        %flineitem = pd.filter_reduce(%lineitem_filtered: 
            !pd.df<<"l_quantity":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pd.datetime>>,
            %sel: !pd.ser<"sel": i1>) : 
            !pd.df<<"l_quantity":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pd.datetime>>
        
        %flineitem_lextendedprice = pd.get_column(%flineitem: 
            !pd.df<<"l_quantity":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pd.datetime>>,
            "l_extendedprice"): <"l_extendedprice": f64>

        %flineitem_discount = pd.get_column(%flineitem: 
            !pd.df<<"l_quantity":i32>, <"l_extendedprice":f64>, 
            <"l_discount":f64>, <"l_shipdate":!pd.datetime>>,
            "l_discount"): <"l_discount": f64>

        %prod = pd.multiply(%flineitem_lextendedprice:  <"l_extendedprice": f64>,
            %flineitem_discount:  <"l_discount": f64>) :
            <"prod": f64>

        %result = pd.agg_sum(%prod: !pd.ser<"prod": f64>, ["prod"]) :
         !pd.ser<"prod": f64>

        pd.print(%result: !pd.ser<"prod": f64>)
        return
    }
}