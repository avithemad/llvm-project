module {
    func.func @q1() {
        %df = pandas.read_csv ("hello.csv") : !pandas.df<<"column1": i32 >, <"column1": f64>>
        %df2 = pandas.add_columns(%df: !pandas.df<<"column1": i32 >, <"column1": f64>>, ["column3"]) : !pandas.df<<"column1": "std::string">>
        %df3 = pandas.select(%df: !pandas.df<<"column1": i32 >,<"column1": f64>>, ["column1", "column2"]) : !pandas.df<<"column1": "std::string">>
        %ser4 = pandas.index(%df: !pandas.df<<"column1": i32 >,<"column1": f64>>, "column1") : !pandas.series<"column1": i32 >
        %df5 = pandas.sortby(%df: !pandas.df<<"column1": i32 >,<"column1": f64>>, "column1") : !pandas.df<<"column1": i32 >>
        %df6 = pandas.add(%ser4: !pandas.series<"column1": i32 >, %ser4: !pandas.series<"column1": i32 >) : !pandas.series<"column1": i32>
        %df7 = pandas.join(%df: !pandas.df<<"column1": i32 >,<"column1": f64>>, %df: !pandas.df<<"column1": i32 >,<"column1": f64>>) : !pandas.df<<"column1": i32 >>
        %df8 = pandas.where(%df: !pandas.df<<"column1": i32 >,<"column1": f64>>, "column1" oeq "someval") : !pandas.df<<"column1": i32 >>
        %df9 = pandas.groupby(%df: !pandas.df<<"column1": i32 >,<"column1": f64>>, ["column1", "column2"]) : !pandas.df<<"column1": i32>, <"column2": "std::set<float>">>
        %df10 = pandas.agg_sum(%df9: !pandas.df<<"column1": i32 >,<"column2": "std::set<float>">>) : !pandas.df<<"column1": "std::string">>
        %df11 = pandas.agg_mean(%df9: !pandas.df<<"column1": i32 >,<"column2": "std::set<float>">>) : !pandas.df<<"column1": "std::string">>
        %df12 = pandas.agg_count(%df9: !pandas.df<<"column1": i32 >,<"column2": "std::set<float>">>) : !pandas.df<<"column1": "std::string">>
        return
    }
}