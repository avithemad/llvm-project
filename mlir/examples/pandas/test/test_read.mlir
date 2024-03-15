module {
    func.func @main() {
        %df = pandas.read_csv ("/home/ajayakar/compiler-project/data/lineitem.csv") : !pandas.df<<"column1": i32 >, <"column1": f64>>
        %df3 = pandas.select(%df: !pandas.df<<"column1": i32 >,<"column1": f64>>, ["column1", "column2"]) : !pandas.df<<"column1": f64>>
        return
    }
}