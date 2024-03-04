module {
    func.func @q1() {
        %df = pandas.read_csv ("hello.csv") : !pandas.df<<"column1": "int" >, <"column1": "float">>
        %df2 = pandas.add_columns(%df: !pandas.df<<"column1": "int" >, <"column1": "float">>, ["column3"]) : !pandas.df<<"column1": "std::string">>
        %df3 = pandas.select(%df: !pandas.df<<"column1": "int" >,<"column1": "float">>, ["column1", "column2"]) : !pandas.df<<"column1": "std::string">>
        %ser4 = pandas.index(%df: !pandas.df<<"column1": "int" >,<"column1": "float">>, "column1") : !pandas.series<"column1": "int" >
        %df5 = pandas.sortby(%df: !pandas.df<<"column1": "int" >,<"column1": "float">>, "column1") : !pandas.df<<"column1": "int" >>
        %df6 = pandas.add(%ser4: !pandas.series<"column1": "int" >, %ser4: !pandas.series<"column1": "int" >) : !pandas.series<"column1": "int">
        %df7 = pandas.join(%df: !pandas.df<<"column1": "int" >,<"column1": "float">>, %df: !pandas.df<<"column1": "int" >,<"column1": "float">>) : !pandas.df<<"column1": "int" >>
        return
    }
}