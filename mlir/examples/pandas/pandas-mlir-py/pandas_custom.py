import datetime


class DataFrame:
    def __init__(self, type_dict):
        self.loc = Location(self)
        self.type_dict = type_dict.copy()
        for k in type_dict:
            setattr(self, k, Series(k, type_dict[k], self))

    def __setitem__(self, col_name, series):
        # get column first
        get_col_ir = '%{ssa} = pd.get_column(%{df_ssa}: {df_ssa_type}, "{col_name}") : {ssa_type}'
        new_ser = Series(series.col_name, series.col_type, None)
        print(
            get_col_ir.format(
                ssa=id(new_ser),
                df_ssa=id(series.dataframe),
                df_ssa_type=format_df_type(series.dataframe),
                col_name=series.col_name,
                ssa_type=format_ser_type(new_ser),
            )
        )

        # add the column to dataframe
        type_dict = self.type_dict
        new_df = DataFrame(type_dict)
        new_df.type_dict[col_name] = series.col_type
        new_ser.dataframe = new_df
        setattr(new_df, col_name, new_ser)
        add_col_ir = '%{ssa} = pd.add_column(%{df_ssa}: {df_ssa_type}, %{ser}: {ser_type}, "{col_name}") : {ssa_type}'
        print(
            add_col_ir.format(
                ssa=id(new_df),
                df_ssa=id(series.dataframe),
                df_ssa_type=format_df_type(series.dataframe),
                ser=id(new_ser),
                ser_type=format_ser_type(new_ser),
                col_name=col_name,
                ssa_type=format_df_type(new_df),
            )
        )
        for s in new_df.type_dict:
            setattr(self, s, getattr(new_df, s))
        self.type_dict = new_df.type_dict

    def __getitem__(self, item):
        if type(item) == Series:
            ir = "%{ssa} = pd.filter_reduce(%{old_ssa}: {old_ssa_type}, %{mask}: {mask_type}): {ssa_type}"
            new_df = DataFrame(self.type_dict)
            print(
                ir.format(
                    ssa=id(new_df),
                    old_ssa=id(self),
                    old_ssa_type=format_df_type(self),
                    mask=id(item),
                    mask_type=format_ser_type(item),
                    ssa_type=format_df_type(new_df),
                )
            )
            return new_df
        else:
            print("TODO: other type")


class Series:
    def __init__(self, col_name, col_type, dataframe):
        self.col_name = col_name
        self.col_type = col_type
        self.dataframe = dataframe

    def __le__(self, other):
        if type(other) == datetime.datetime:
            new_ser = Series(other, "i1", None)
            ir = '%{ssa} = pd.filter(%{df_ssa}: {df_ssa_type}, "{col_name}" ole "{date}") : {ssa_type}'
            print(
                ir.format(
                    ssa=id(new_ser),
                    df_ssa=id(self.dataframe),
                    df_ssa_type=format_df_type(self.dataframe),
                    col_name=self.col_name,
                    date=str(other),
                    ssa_type=format_ser_type(new_ser),
                )
            )
            return new_ser
        else:
            print("TODO: some other type")


class Location:
    # expected item 1st argument to be slice, 2nd to be list of columns
    def __init__(self, dataframe):
        self.dataframe = dataframe

    def __getitem__(self, item):
        slc = item[0]
        columns = item[1:][0]
        new_dict = {}
        for k in columns:
            new_dict[k] = self.dataframe.type_dict[k]
        new_df = DataFrame(new_dict)
        ir = "%{ssa} = pd.select(%{old_ssa}: {old_ssa_type}, {columns}) : {ssa_type}"
        old_ssa_type = format_df_type(self.dataframe)
        ssa_type = format_df_type(new_df)
        print(
            ir.format(
                ssa=id(new_df),
                old_ssa=id(self.dataframe),
                old_ssa_type=old_ssa_type,
                columns=format_collist(columns),
                ssa_type=ssa_type,
            )
        )
        return new_df


def format_collist(columns):
    s = "["
    for i in range(len(columns)):
        s += '"{c}"'.format(c=columns[i])
        if i < (len(columns) - 1):
            s += ", "
    s += "]"
    return s


def format_ser_type(series):
    return '!pd.ser<"{col_name}" : {col_type}>'.format(
        col_name=series.col_name, col_type=series.col_type
    )


def format_df_type(df):
    type_dict = df.type_dict
    formatted = "!pd.df<"
    i = 0
    for k in type_dict:
        if i < (len(type_dict) - 1):
            formatted += '<"{col_name}" : {type}>,'.format(
                col_name=k, type=type_dict[k]
            )
        else:
            formatted += '<"{col_name}" : {type}>'.format(col_name=k, type=type_dict[k])
        i += 1
    formatted += ">"
    return formatted


def read_csv(filename, type_dict):
    dataframe = DataFrame(type_dict)
    ir = '%{ssa} = pd.read_csv ("{filename}") : {return_type}'
    print(
        ir.format(
            ssa=id(dataframe), filename=filename, return_type=format_df_type(dataframe)
        )
    )
    return dataframe
