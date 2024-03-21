import timeit
from datetime import datetime
from typing import Callable
from linetimer import CodeTimer, linetimer
from pandas_custom import read_csv


def q():
    print("module {")
    print("func.func @q1() {")
    VAR1 = datetime(1998, 9, 2)
    type_dict = {
        "l_orderkey":"i32", 
        "l_partkey":"i32", 
        "l_suppkey":"i32", 
        "l_linenumber":"i32",
        "l_quantity":"i32", 
        "l_extendedprice":"f64", 
        "l_discount":"f64", 
        "l_tax":"f64",
        "l_returnflag":"!pd.string", 
        "l_linestatus":"!pd.string", 
        "l_shipdate":"!pd.datetime", 
        "l_commitdate":"!pd.datetime",
        "l_receiptdate":"!pd.datetime", 
        "l_shipinstruct":"!pd.string", 
        "l_shipmode":"!pd.string", 
        "comments":" !pd.string"
    }
    lineitem = read_csv("/home/ajayakar/compiler-project/data/lineitem.csv", type_dict)
    lineitem_filtered = lineitem.loc[
            :,
            [
                "l_quantity",
                "l_extendedprice",
                "l_discount",
                "l_tax",
                "l_returnflag",
                "l_linestatus",
                "l_shipdate",
                "l_orderkey",
            ],
        ]
    sel = lineitem_filtered.l_shipdate <= VAR1
    lineitem_filtered = lineitem_filtered[sel]
    lineitem_filtered["sum_qty"] = lineitem_filtered.l_quantity
    lineitem_filtered["sum_base_price"] = lineitem_filtered.l_extendedprice
    lineitem_filtered["avg_qty"] = lineitem_filtered.l_quantity
    lineitem_filtered["avg_price"] = lineitem_filtered.l_extendedprice

    lineitem_filtered["sum_disc_price"] = lineitem_filtered.l_extendedprice * (
            1 - lineitem_filtered.l_discount
        )
    lineitem_filtered["sum_charge"] = (
        lineitem_filtered.l_extendedprice
        * (1 - lineitem_filtered.l_discount)
        * (1 + lineitem_filtered.l_tax)
    )
    lineitem_filtered["avg_disc"] = lineitem_filtered.l_discount
    lineitem_filtered["count_order"] = lineitem_filtered.l_orderkey
    gb = lineitem_filtered.groupby(["l_returnflag", "l_linestatus"])
    total = gb.agg(
        {
            "sum_qty": "sum",
            "sum_base_price": "sum",
            "sum_disc_price": "sum",
            "sum_charge": "sum",
            "avg_qty": "mean",
            "avg_price": "mean",
            "avg_disc": "mean",
            "count_order": "count",
        }
    )
    result_df = total.reset_index().sort_values(["l_returnflag", "l_linestatus"])
    # return result_df

    print("return}}")

if __name__ == "__main__":
    q()