from datetime import datetime

from pandas_custom import read_csv

Q_NUM = 3


def q():
    print("module {")
    print("func.func @q1() {")
    var1 = var2 = datetime(1995, 3, 15)
    var3 = "BUILDING"
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
        "o_orderkey": "i32","o_custkey": "i32",
            "o_orderstatus": " !pd.string","o_totalprice": "i32",
            "o_orderdate": "!pd.datetime","o_orderpriority": " !pd.string",
            "o_clerk": " !pd.string", "o_shippriority": "i32",
            "o_comment": " !pd.string"
    }
    customer_ds = read_csv(
        "/home/ajayakar/compiler-project/data/customer.csv", cust_type_dict
    )
    line_item_ds = read_csv(
        "/home/ajayakar/compiler-project/data/lineitem.csv", line_type_dict
    )
    orders_ds = read_csv(
        "/home/ajayakar/compiler-project/data/orders.csv", orders_type_dict
    )

    # first call one time to cache in case we don't include the IO times
    lineitem_filtered = line_item_ds.loc[
        :, ["l_orderkey", "l_extendedprice", "l_discount", "l_shipdate"]
    ]
    orders_filtered = orders_ds.loc[
        :, ["o_orderkey", "o_custkey", "o_orderdate", "o_shippriority"]
    ]
    customer_filtered = customer_ds.loc[:, ["c_mktsegment", "c_custkey"]]
    lsel = lineitem_filtered.l_shipdate > var1
    osel = orders_filtered.o_orderdate < var2
    csel = customer_filtered.c_mktsegment == var3
    flineitem = lineitem_filtered[lsel]
    forders = orders_filtered[osel]
    fcustomer = customer_filtered[csel]
    jn1 = fcustomer.merge(forders, left_on="c_custkey", right_on="o_custkey")
    jn2 = jn1.merge(flineitem, left_on="o_orderkey", right_on="l_orderkey")
    jn2["revenue"] = jn2.l_extendedprice * (1 - jn2.l_discount)
    total = (
        jn2.groupby(["l_orderkey", "o_orderdate", "o_shippriority"], as_index=False)[
            "revenue"
        ]
        .sum()
        .sort_values(["revenue"], ascending=False)
    )
    result_df = total[:10].loc[
        :, ["l_orderkey", "revenue", "o_orderdate", "o_shippriority"]
    ]
    print("return}}")


if __name__ == "__main__":
    q()
