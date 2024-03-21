from datetime import datetime

from pandas_custom import read_csv

Q_NUM = 3


def q():
    print("module {")
    print("func.func @q1() {")
    date1 = datetime(1994, 1, 1)
    date2 = datetime(1995, 4, 1)
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
    nation_type_dict = {"n_nationkey" : "i32","n_name": "!pd.string",
            "n_regionkey": "i32", "n_comment": "!pd.string"}
    customer_ds = read_csv(
        "/home/ajayakar/compiler-project/data/customer.csv", cust_type_dict
    )
    line_item_ds = read_csv(
        "/home/ajayakar/compiler-project/data/lineitem.csv", line_type_dict
    )
    orders_ds = read_csv(
        "/home/ajayakar/compiler-project/data/orders.csv", orders_type_dict
    )
    nation_ds = read_csv(
        "/home/ajayakar/compiler-project/data/nation.csv", nation_type_dict
    )
    osel = (orders_ds.o_orderdate >= date1) & (orders_ds.o_orderdate < date2)
    lsel = line_item_ds.l_returnflag == "R"
    lineitem_filtered = line_item_ds[lsel]
    orders_filtered = orders_ds[osel]
    jn1 = customer_ds.merge(orders_filtered, left_on="c_custkey", right_on="o_custkey")
    jn2 = jn1.merge(lineitem_filtered, left_on="o_orderkey", right_on="l_orderkey")
    jn3 = jn2.merge(nation_ds, left_on="c_nationkey", right_on="n_nationkey")
    jn3["revenue"] = jn3.l_extendedprice * (1.0 - jn3.l_discount)
    total = (jn3.groupby(
        ["c_custkey", "c_name", "c_acctbal", "c_phone", "n_name", "c_address", "c_comment"]
    )["revenue"].sum().sort_values(["revenue"], ascending=False))
    result_df = total[0:20].loc[
        :, ["c_custkey", "c_name", "revenue", "c_acctbal", "n_name", "c_address", "c_phone", "c_comment"]
    ]
    print("return}}")
    return result_df


if __name__ == "__main__":
    q()
