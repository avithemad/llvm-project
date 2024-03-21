from datetime import datetime

from pandas_custom import read_csv

import pandas_custom as pd

Q_NUM = 3


def q():
    print("module {")
    print("func.func @q1() {")
    date1 = datetime(1994, 1, 1)
    date2 = datetime(1995, 1, 1)
    var3 = 24
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
    line_item_ds = read_csv(
        "/home/ajayakar/compiler-project/data/lineitem.csv", line_type_dict
    )
    lineitem_filtered = line_item_ds.loc[
        :, ["l_quantity", "l_extendedprice", "l_discount", "l_shipdate"]
    ]
    sel = (
        (lineitem_filtered.l_shipdate >= date1)
        & (lineitem_filtered.l_shipdate < date2)
        & (lineitem_filtered.l_discount >= 0.05)
        & (lineitem_filtered.l_discount <= 0.07)
        & (lineitem_filtered.l_quantity < var3)
    )
    flineitem = lineitem_filtered[sel]
    result_value = (flineitem.l_extendedprice * flineitem.l_discount).sum()
    print("return}}")
    # result_df = pd.DataFrame({"revenue": [result_value]})
    # return result_df


if __name__ == "__main__":
    q()
