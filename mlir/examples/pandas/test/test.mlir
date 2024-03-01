module {
    func.func @q1() {
        %df = pandas.read_csv ("hello.csv") -> !pandas.df<3>
        return
    }
}