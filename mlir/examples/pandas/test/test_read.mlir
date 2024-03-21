module {
    func.func @main() {
        %df:2 = 
        pandas.read_csv("/home/ajayakar/compiler-project/data/lineitem.csv")
        : !pandas.series<"c1": f64>, !pandas.series<"c2":i32>

        %df_2 = pandas.read_csv("") : !pandas.series<"c3": f64> 

        %sel = pandas.project %df#0,%df#1 : !pandas.series<"c1": f64>,  !pandas.series<"c2": i32> ["c1"]
        -> !pandas.series<"c1": f64>
        
        %sel_2 = pandas.project %df_2: !pandas.series<"c3": f64> ["c3"] -> !pandas.series<"new name": f64> 
        
        return
    }
}
