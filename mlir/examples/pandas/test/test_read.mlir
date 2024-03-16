module {
    func.func @main() {
        %df = pandas.read_csv ("/home/ajayakar/compiler-project/data/lineitem.csv")
         : !pandas.df<<"column1": i32 >, <"column2": i32>, 
            <"column3": !pandas.datetime>, <"column4": !pandas.string>>
        pandas.print(%df: !pandas.df<<"column1": i32 >, <"column2": i32>, 
            <"column3": !pandas.datetime>, <"column4": !pandas.string>>) :
            !pandas.df<<"column1": i32 >, <"l_extendedprice": i32>, 
            <"column3": !pandas.datetime>, <"column4": !pandas.string>>
        return
    }
}