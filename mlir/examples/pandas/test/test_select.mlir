module {
    func.func @q1() {
        %df = pandas.read_csv ("hello.csv") : !pandas.df<<"column1": "int" >, <"column1": "float">>
        %df3 = pandas.select(%df: !pandas.df<<"column1": "int" >,<"column1": "float">>, ["column1", "column2"]) : !pandas.df<<"column1": "std::string">>
        return
    }
}