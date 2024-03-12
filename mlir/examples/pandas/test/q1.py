import timeit
from datetime import datetime
from typing import Callable
from linetimer import CodeTimer, linetimer
import pandas as pd
from pandas.core.frame import DataFrame as PandasDF
Q_NUM = 1


def run_query(q_num: int, query: Callable):
    @linetimer(name=f"Overall execution of pandas Query {q_num}", unit="s")
    def run():
        with CodeTimer(name=f"Get result of pandas Query {q_num}", unit="s"):
            t0 = timeit.default_timer()
            result = query()
            secs = timeit.default_timer() - t0

        print(result)

    run()

def q():
    VAR1 = datetime(1998, 9, 2)

    lineitem = pd.read_parquet("/home/ajayakar/compiler-project/data/lineitem.parquet", dtype_backend="pyarrow", engine="pyarrow")

    # first call one time to cache in case we don't include the IO times
    print(lineitem)
    def query():
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

        return result_df

    run_query(Q_NUM, query)


if __name__ == "__main__":
    q()
