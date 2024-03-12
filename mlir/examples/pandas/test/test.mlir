module {
    func.func @q1() {
        %df = pandas.read_csv ("hello.csv") : !pandas.df<<"column1": i32 >, <"column1": f64>>
        
        %ser1 = pandas.get_column(%df: !pandas.df<<"column1": i32 >, <"column1": f64>>, "column1") : !pandas.series<"column1": f64>
        %df2 = pandas.add_column(%df: !pandas.df<<"column1": i32 >, <"column1": f64>>, %ser1: !pandas.series<"column1": f64>, "newcol") : !pandas.df<<"column1": !pandas.string>>
        
        %df3 = pandas.select(%df: !pandas.df<<"column1": i32 >,<"column1": f64>>, ["column1", "column2"]) : !pandas.df<<"column1": !pandas.datetime>>
        
        %df5 = pandas.sortby(%df: !pandas.df<<"column1": i32 >,<"column1": f64>>, "column1") : !pandas.df<<"column1": i32 >>
        
        %df7 = pandas.join(%df: !pandas.df<<"column1": i32 >,<"column1": f64>>, %df: !pandas.df<<"column1": i32 >,<"column1": f64>>, "column1", "column2") : !pandas.df<<"column1": i32 >>
        
        %ser8 = pandas.filter(%df: !pandas.df<<"column1": i32 >, <"column1": f64>>, "column1" oeq "someval") : !pandas.series<"column1": i32 >
        %df8 = pandas.filter_reduce(%df: !pandas.df<<"column1": i32 >, <"column1": f64>>, %ser8: !pandas.series<"column1": i32 >) : !pandas.df<<"column1": i32 >, <"column1": f64>>
        
        %df9 = pandas.groupby(%df: !pandas.df<<"column1": i32 >,<"column1": f64>>, ["column1", "column2"]) : !pandas.df<<"column1": i32>, <"column2": !pandas.group<f64>>>
        
        %df10 = pandas.agg_sum(%df9: !pandas.df<<"column1": i32 >,<"column2": !pandas.group<f64>>>,  ["column2"]) : !pandas.df<<"column1": !pandas.string>>
        %df11 = pandas.agg_mean(%df9: !pandas.df<<"column1": i32 >,<"column2": !pandas.group<f64>>>,  ["column2"]) : !pandas.df<<"column1": !pandas.string>>
        %df12 = pandas.agg_count(%df9: !pandas.df<<"column1": i32 >,<"column2": !pandas.group<f64>>>,  ["column2"]) : !pandas.df<<"column1": !pandas.string>>
        return
    }
}