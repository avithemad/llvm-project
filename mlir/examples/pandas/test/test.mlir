module {
    func.func @toy_func(%tensor: tensor<2x3xf64>) -> tensor<2x3xf64> {
    %t_tensor = "pandas.foo"()
            { value = dense<[[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]]> : tensor<2x3xf64> }
            : () -> tensor<2x3xf64>
    return %t_tensor : tensor<2x3xf64>
    }
}