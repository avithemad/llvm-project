from datetime import datetime

import pandas as pd

from pandas_queries import utils

Q_NUM = 10


def q():
    date1 = datetime(1994, 1, 1)
    date2 = datetime(1995, 4, 1)
    var3 = 24

    customer_ds = utils.get_customer_ds
    orders_ds = utils.get_orders_ds
    line_item_ds = utils.get_line_item_ds
    nation_ds = utils.get_nation_ds

    # first call one time to cache in case we don't include the IO times
    customer_ds()
    orders_ds()
    line_item_ds()
    nation_ds()

    def query():
        nonlocal nation_ds
        nonlocal customer_ds
        nonlocal line_item_ds
        nonlocal orders_ds
        
        nation_ds = nation_ds()
        customer_ds = customer_ds()
        line_item_ds = line_item_ds()
        orders_ds = orders_ds()

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
        return result_df

    utils.run_query(Q_NUM, query)


if __name__ == "__main__":
    q()
