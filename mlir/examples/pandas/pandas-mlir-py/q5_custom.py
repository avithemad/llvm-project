from datetime import datetime

from pandas_custom import read_csv

Q_NUM = 3


def q():
    print("module {")
    print("func.func @q1() {")
    date1 = datetime.strptime("1994-01-01", "%Y-%m-%d")
    date2 = datetime.strptime("1995-01-01", "%Y-%m-%d")
    line_type_dict = {
        "l_orderkey": "i32",
        "l_partkey": "i32",
        "l_suppkey": "i32",
        "l_linenumber": "i32",
        "l_quantity": "i32",
        "l_extendedprice": "f64",
        "l_discount": "f64",
        "l_tax": "f64",
        "l_returnflag": "!pd.string",
        "l_linestatus": "!pd.string",
        "l_shipdate": "!pd.datetime",
        "l_commitdate": "!pd.datetime",
        "l_receiptdate": "!pd.datetime",
        "l_shipinstruct": "!pd.string",
        "l_shipmode": "!pd.string",
        "comments": "!pd.string",
    }
    cust_type_dict = {
        "c_custkey": "i32",
        "c_name": "!pd.string",
        "c_address": "!pd.string",
        "c_nationkey": "i32",
        "c_phone": "!pd.string",
        "c_acctbal": "f64",
        "c_mktsegment": "!pd.string",
        "c_comment": "!pd.string",
    }
    orders_type_dict = {
        "o_orderkey": "i32",
        "o_custkey": "i32",
        "o_orderstatus": "!pd.string",
        "o_totalprice": "i32",
        "o_orderdate": "!pd.datetime",
        "o_orderpriority": "!pd.string",
        "o_clerk": "!pd.string",
        "o_shippriority": "i32",
        "o_comment": "!pd.string",
    }
    region_type_dict = {
        "r_regionkey": "i32", "r_name": "!pd.string",
            "r_comment": "!pd.string"
    }
    nation_type_dict = {"n_nationkey" : "i32","n_name": "!pd.string",
            "n_regionkey": "i32", "n_comment": "!pd.string"}
    supplier_type_dict = {"s_suppkey": "i32", "s_name" : "!pd.string",
            "s_address": "!pd.string", "s_nationkey": "i32",
            "s_phone": "!pd.string", "s_acctbal": "f64",
            "s_comment": "!pd.string"}
    customer_ds = read_csv(
        "/home/ajayakar/compiler-project/data/customer.csv", cust_type_dict
    )
    line_item_ds = read_csv(
        "/home/ajayakar/compiler-project/data/lineitem.csv", line_type_dict
    )
    orders_ds = read_csv(
        "/home/ajayakar/compiler-project/data/orders.csv", orders_type_dict
    )
    region_ds = read_csv(
        "/home/ajayakar/compiler-project/data/region.csv", region_type_dict
    )
    nation_ds = read_csv(
        "/home/ajayakar/compiler-project/data/nation.csv", nation_type_dict
    )
    supplier_ds = read_csv(
        "/home/ajayakar/compiler-project/data/nation.csv", supplier_type_dict
    )
    rsel = region_ds.r_name == "ASIA"
    osel = (orders_ds.o_orderdate >= date1) & (orders_ds.o_orderdate < date2)
    forders = orders_ds[osel]
    fregion = region_ds[rsel]
    jn1 = fregion.merge(nation_ds, left_on="r_regionkey", right_on="n_regionkey")
    jn2 = jn1.merge(customer_ds, left_on="n_nationkey", right_on="c_nationkey")
    jn3 = jn2.merge(forders, left_on="c_custkey", right_on="o_custkey")
    jn4 = jn3.merge(line_item_ds, left_on="o_orderkey", right_on="l_orderkey")
    jn5 = supplier_ds.merge(
        jn4,
        left_on=["s_suppkey", "s_nationkey"],
        right_on=["l_suppkey", "n_nationkey"],
    )
    jn5["revenue"] = jn5.l_extendedprice * (1.0 - jn5.l_discount)
    gb = jn5.groupby("n_name", as_index=False)["revenue"].sum()
    result_df = gb.sort_values("revenue", ascending=False)
    print("return}}")
    return result_df


if __name__ == "__main__":
    q()
