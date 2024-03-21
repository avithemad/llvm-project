module {
    func.func @q1() {
        %lineitem = pd.read_csv("/home/ajayakar/compiler-project/data/lineitem.csv") : !pd.df<<"c1": i1>, <"c2": i1>>

        %sel = pd.select(%lineitem: !pd.df<<"c1": i1>, <"c2": i1>>, ["c1"]) : !pd.df<<"c1": i1>>

        return
    }
}