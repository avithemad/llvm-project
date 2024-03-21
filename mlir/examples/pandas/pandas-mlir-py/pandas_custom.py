import datetime

ssa_id = 1


class DataFrame:
    def __init__(self, type_dict, ssa_id):
        self.loc = Location(self)
        self.type_dict = type_dict.copy()
        self.ssa_id = ssa_id
        for k in type_dict:
            setattr(self, k, Series(k, type_dict[k], self, -1))
        self.updated_df = self

    def __setitem__(self, col_name, series):
        # get column first
        if series.dataframe != None:
            global ssa_id
            get_col_ir = '%{ssa} = pd.get_column(%{df_ssa}: {df_ssa_type}, "{col_name}") : {ssa_type}'
            new_ser = Series(series.col_name, series.col_type, None, ssa_id)
            ssa_id += 1
            print(
                get_col_ir.format(
                    ssa=new_ser.ssa_id,
                    df_ssa=series.dataframe.ssa_id,
                    df_ssa_type=format_df_type(series.dataframe),
                    col_name=series.col_name,
                    ssa_type=format_ser_type(new_ser),
                )
            )

            # add the column to dataframe
            type_dict = self.type_dict
            new_df = DataFrame(type_dict, ssa_id)
            ssa_id += 1
            new_df.type_dict[col_name] = series.col_type
            new_ser.dataframe = new_df
            setattr(new_df, col_name, new_ser)
            add_col_ir = '%{ssa} = pd.add_column(%{df_ssa}: {df_ssa_type}, %{ser}: {ser_type}, "{col_name}") : {ssa_type}'
            print(
                add_col_ir.format(
                    ssa=new_df.ssa_id,
                    df_ssa=series.dataframe.ssa_id,
                    df_ssa_type=format_df_type(series.dataframe),
                    ser=new_ser.ssa_id,
                    ser_type=format_ser_type(new_ser),
                    col_name=col_name,
                    ssa_type=format_df_type(new_df),
                )
            )
            for s in new_df.type_dict:
                setattr(self, s, getattr(new_df, s))
            self.type_dict = new_df.type_dict
            self.ssa_id = new_df.ssa_id
            self.updated_df = new_df
        else:
            type_dict = self.type_dict
            new_ser = Series(col_name, series.col_type, self, ssa_id)
            ssa_id += 1
            new_df = DataFrame(type_dict, ssa_id)
            ssa_id += 1
            new_df.type_dict[col_name] = series.col_type
            new_ser.dataframe = new_df
            setattr(new_df, col_name, new_ser)
            add_col_ir = '%{ssa} = pd.add_column(%{df_ssa}: {df_ssa_type}, %{ser}: {ser_type}, "{col_name}") : {ssa_type}'
            print(
                add_col_ir.format(
                    ssa=new_df.ssa_id,
                    df_ssa=self.ssa_id,
                    df_ssa_type=format_df_type(self.updated_df),
                    ser=series.ssa_id,
                    ser_type=format_ser_type(series),
                    col_name=col_name,
                    ssa_type=format_df_type(new_df),
                )
            )
            for s in new_df.type_dict:
                setattr(self, s, getattr(new_df, s))
            self.type_dict = new_df.type_dict
            self.ssa_id = new_df.ssa_id
            self.updated_df = new_df

    def __getitem__(self, item):
        global ssa_id
        if type(item) == Series:
            global ssa_id
            ir = "%{ssa} = pd.filter_reduce(%{old_ssa}: {old_ssa_type}, %{mask}: {mask_type}): {ssa_type}"
            new_df = DataFrame(self.type_dict, ssa_id)
            ssa_id += 1
            print(
                ir.format(
                    ssa=(new_df.ssa_id),
                    old_ssa=(self.ssa_id),
                    old_ssa_type=format_df_type(self),
                    mask=(item.ssa_id),
                    mask_type=format_ser_type(item),
                    ssa_type=format_df_type(new_df),
                )
            )
            return new_df
        elif type(item) == str:
            get_col_ir = '%{ssa} = pd.get_column(%{df_ssa}: {df_ssa_type}, "{col_name}") : {ssa_type}'
            new_ser = Series(
                getattr(self, item).col_name, getattr(self, item).col_type, self, ssa_id
            )
            ssa_id += 1
            print(
                get_col_ir.format(
                    ssa=new_ser.ssa_id,
                    df_ssa=self.ssa_id,
                    df_ssa_type=format_df_type(self),
                    col_name=getattr(self, item).col_name,
                    ssa_type=format_ser_type(new_ser),
                )
            )
            return new_ser
        elif type(item) == slice:
            new_df = DataFrame(self.type_dict, ssa_id)
            ssa_id += 1
            start = item.start
            if item.start == None:
                start = 0
            filter_range_ir = (
                "%{ssa} = pd.filter_range %{df}: {df_type} [{start}:{stop}] {ssa_type}"
            )
            print(
                filter_range_ir.format(
                    ssa=new_df.ssa_id,
                    df=self.ssa_id,
                    df_type=format_df_type(self),
                    start=start,
                    stop=item.stop,
                    ssa_type=format_df_type(new_df),
                )
            )
            return new_df
        else:
            # TODO
            print("TODO:Type {t} unhandled".format(t=type(item)))

    def groupby(self, group_index, as_index=False):
        global ssa_id
        new_dict = {}
        if type(group_index) == str:
            group_index = [group_index]
        for index in group_index:
            new_dict[index] = self.type_dict[index]
        for index in self.type_dict:
            if index not in group_index:
                newty = "!pd.group<{ty}>".format(ty=self.type_dict[index])
                new_dict[index] = newty
        new_df = DataFrame(new_dict, ssa_id)
        ssa_id += 1
        groupby_ir = (
            "%{ssa} = pd.groupby(%{old_ssa}: {old_ssa_type}, {indices}): {ssa_type}"
        )

        indices = format_collist(group_index)
        print(
            groupby_ir.format(
                ssa=new_df.ssa_id,
                old_ssa=self.ssa_id,
                old_ssa_type=format_df_type(self),
                indices=indices,
                ssa_type=format_df_type(new_df),
            )
        )
        return new_df

    def agg(self, agg_dict):
        global ssa_id
        sum_list = []
        new_dict = self.type_dict.copy()
        for k in agg_dict:
            if agg_dict[k] == "sum":
                sum_list.append(k)
                new_dict[k] = new_dict[k].split("<")[1].split(">")[0]
        new_df = DataFrame(new_dict, ssa_id)
        ssa_id += 1
        agg_sum_ir = "%{ssa} = pd.agg_sum(%{df}: {df_type}, {agg_list}) : {ssa_type}"
        print(
            agg_sum_ir.format(
                ssa=new_df.ssa_id,
                df=self.ssa_id,
                df_type=format_df_type(self),
                agg_list=format_collist(sum_list),
                ssa_type=format_df_type(new_df),
            )
        )
        mean_list = []
        new_dict = new_df.type_dict.copy()
        for k in agg_dict:
            if agg_dict[k] == "mean":
                mean_list.append(k)
                new_dict[k] = new_dict[k].split("<")[1].split(">")[0]
        new_df_meaned = DataFrame(new_dict, ssa_id)
        ssa_id += 1
        agg_sum_ir = "%{ssa} = pd.agg_mean(%{df}: {df_type}, {agg_list}) : {ssa_type}"
        print(
            agg_sum_ir.format(
                ssa=new_df_meaned.ssa_id,
                df=new_df.ssa_id,
                df_type=format_df_type(new_df),
                agg_list=format_collist(mean_list),
                ssa_type=format_df_type(new_df_meaned),
            )
        )
        count_list = []
        new_dict = new_df_meaned.type_dict.copy()
        for k in agg_dict:
            if agg_dict[k] == "count":
                count_list.append(k)
                new_dict[k] = new_dict[k].split("<")[1].split(">")[0]
        new_df_counted = DataFrame(new_dict, ssa_id)
        ssa_id += 1
        agg_sum_ir = "%{ssa} = pd.agg_count(%{df}: {df_type}, {agg_list}) : {ssa_type}"
        print(
            agg_sum_ir.format(
                ssa=new_df_counted.ssa_id,
                df=new_df_meaned.ssa_id,
                df_type=format_df_type(new_df_meaned),
                agg_list=format_collist(mean_list),
                ssa_type=format_df_type(new_df_counted),
            )
        )
        return new_df

    def merge(self, other, left_on, right_on):
        global ssa_id
        join_ir = "%{ssa} = pd.join(%{df1}: {df1_type}, %{df2}: {df2_type}, {left_on}, {right_on}): {ssa_type}"
        new_type_dict = {}
        for k in self.type_dict:
            new_type_dict[k] = self.type_dict[k]
        for k in other.type_dict:
            new_type_dict[k] = other.type_dict[k]
        new_df = DataFrame(new_type_dict, ssa_id)
        ssa_id += 1
        if type(left_on) == list:
            left_on = format_collist(left_on)
            right_on = format_collist(right_on)
        else:
            left_on = format_collist([left_on])
            right_on = format_collist([right_on])

        print(
            join_ir.format(
                ssa=new_df.ssa_id,
                df1=self.ssa_id,
                df1_type=format_df_type(self),
                df2=other.ssa_id,
                df2_type=format_df_type(other),
                left_on=left_on,
                right_on=right_on,
                ssa_type=format_df_type(new_df),
            )
        )
        return new_df

    def reset_index(self):
        return self

    def sort_values(self, sort_list, ascending=True):
        global ssa_id
        direction = "asc"
        old_df = self
        new_df = DataFrame(self.type_dict, ssa_id)
        ssa_id += 1
        if not ascending:
            direction = "desc"
        sort_ir = '%{ssa} = pd.sortby(%{df}: {df_type}, "{sort_col}", "{direction}"): {ssa_type}'
        for sort in sort_list:
            new_df = DataFrame(old_df.type_dict, ssa_id)
            ssa_id += 1
            print(
                sort_ir.format(
                    ssa=new_df.ssa_id,
                    df=old_df.ssa_id,
                    df_type=format_df_type(old_df),
                    sort_col=sort,
                    direction=direction,
                    ssa_type=format_df_type(new_df),
                )
            )
            old_df = new_df

        return new_df


def create_bin_operator(lhs, rhs, operation):
    self = rhs
    other = lhs
    global ssa_id
    if type(other) == int or type(other) == float:
        # get the column from current dataframe
        get_col = Series(self.col_name, self.col_type, self.dataframe, ssa_id)
        ssa_id += 1
        get_col_ir = '%{ssa} = pd.get_column(%{df_ssa}: {df_ssa_type}, "{col_name}") : {ssa_type}'
        print(
            get_col_ir.format(
                ssa=get_col.ssa_id,
                df_ssa=(self.dataframe.ssa_id),
                df_ssa_type=format_df_type(self.dataframe),
                col_name=self.col_name,
                ssa_type=format_ser_type(get_col),
            )
        )
        # create the constant in IR
        if self.col_type == "f64":
            const_df = Series("const_float", self.col_type, None, ssa_id)
            ssa_id += 1
            const_int_ir = "%{ssa} = pd.const_float({literal}) : {ssa_type}"
            print(
                const_int_ir.format(
                    ssa=const_df.ssa_id,
                    literal=str(str(float(other))),
                    ssa_type=format_ser_type(const_df),
                )
            )
            result = Series(self.col_name, self.col_type, None, ssa_id)
            ssa_id += 1
            sub_ir = (
                "%{ssa} = pd.{op}(%{lhs}: {lhs_type}, %{rhs}: {rhs_type}): {ssa_type}"
            )
            print(
                sub_ir.format(
                    ssa=result.ssa_id,
                    op=operation,
                    lhs=(const_df.ssa_id),
                    lhs_type=format_ser_type(const_df),
                    rhs=(get_col.ssa_id),
                    rhs_type=format_ser_type(get_col),
                    ssa_type=format_ser_type(result),
                )
            )
            return result
        # TODO
        elif self.col_type == "i32":
            const_df = Series("const_int", self.col_type, None, ssa_id)
            ssa_id += 1
            const_int_ir = "%{ssa} = pd.const_int({literal}) : {ssa_type}"
            print(
                const_int_ir.format(
                    ssa=const_df.ssa_id,
                    literal=other,
                    ssa_type=format_ser_type(const_df),
                )
            )
            result = Series(self.col_name, self.col_type, None, ssa_id)
            ssa_id += 1
            sub_ir = (
                "%{ssa} = pd.{op}(%{lhs}: {lhs_type}, %{rhs}: {rhs_type}): {ssa_type}"
            )
            print(
                sub_ir.format(
                    ssa=result.ssa_id,
                    op=operation,
                    lhs=(const_df.ssa_id),
                    lhs_type=format_ser_type(const_df),
                    rhs=(get_col.ssa_id),
                    rhs_type=format_ser_type(get_col),
                    ssa_type=format_ser_type(result),
                )
            )
            return result

    elif type(other) == Series:
        if other.ssa_id == -1:
            get_col_ir = '%{ssa} = pd.get_column(%{df_ssa}: {df_ssa_type}, "{col_name}") : {ssa_type}'
            print(
                get_col_ir.format(
                    ssa=ssa_id,
                    df_ssa=other.dataframe.ssa_id,
                    df_ssa_type=format_df_type(other.dataframe),
                    col_name=other.col_name,
                    ssa_type=format_ser_type(other),
                )
            )
            other.ssa_id = ssa_id
            ssa_id += 1
        if self.ssa_id == -1:
            get_col_ir = '%{ssa} = pd.get_column(%{df_ssa}: {df_ssa_type}, "{col_name}") : {ssa_type}'
            print(
                get_col_ir.format(
                    ssa=ssa_id,
                    df_ssa=self.dataframe.ssa_id,
                    df_ssa_type=format_df_type(self.dataframe),
                    col_name=self.col_name,
                    ssa_type=format_ser_type(self),
                )
            )
            self.ssa_id = ssa_id
            ssa_id += 1
        result = Series(operation, self.col_type, None, ssa_id)
        ssa_id += 1
        sub_ir = "%{ssa} = pd.{op}(%{lhs}: {lhs_type}, %{rhs}: {rhs_type}): {ssa_type}"
        print(
            sub_ir.format(
                ssa=result.ssa_id,
                op=operation,
                lhs=(other.ssa_id),
                lhs_type=format_ser_type(other),
                rhs=(self.ssa_id),
                rhs_type=format_ser_type(self),
                ssa_type=format_ser_type(result),
            )
        )
        return result


def create_predicates(self, other, operator):
    global ssa_id
    cmp = str(other)
    new_ser = Series(other, "i1", None, ssa_id)
    ssa_id += 1
    ir = '%{ssa} = pd.filter(%{df_ssa}: {df_ssa_type}, "{col_name}" {op} "{date}") : {ssa_type}'
    print(
        ir.format(
            ssa=new_ser.ssa_id,
            df_ssa=self.dataframe.ssa_id,
            df_ssa_type=format_df_type(self.dataframe),
            col_name=self.col_name,
            op=operator,
            date=cmp,
            ssa_type=format_ser_type(new_ser),
        )
    )
    return new_ser


class Series:
    def __init__(self, col_name, col_type, dataframe, ssa_id):
        self.col_name = col_name
        self.col_type = col_type
        self.dataframe = dataframe
        self.ssa_id = ssa_id

    def sum(self):
        global ssa_id
        agg_sum_ir = "%{ssa} = pd.agg_sum(%{df}: {df_type}, {agg_list}) : {ssa_type}"
        agg_list = format_collist([self.col_name])
        df = self.dataframe
        if df == None:
            new_ser = Series("agg_sum", self.col_type, None, ssa_id)
            ssa_id += 1
            print(
                agg_sum_ir.format(
                    ssa=new_ser.ssa_id,
                    df=self.ssa_id,
                    df_type=format_ser_type(self),
                    agg_list=agg_list,
                    ssa_type=format_ser_type(self),
                )
            )
            return new_ser
        new_df = DataFrame(df.type_dict, ssa_id)
        ssa_id += 1
        print(
            agg_sum_ir.format(
                ssa=new_df.ssa_id,
                df=df.ssa_id,
                df_type=format_df_type(df),
                agg_list=agg_list,
                ssa_type=format_df_type(new_df),
            )
        )

        return new_df

    def __and__(self, other):
        return create_bin_operator(self, other, "multiply")

    def __le__(self, other):
        return create_predicates(self, other, "ole")

    def __lt__(self, other):
        return create_predicates(self, other, "olt")

    def __eq__(self, other):
        return create_predicates(self, other, "oeq")

    def __ge__(self, other):
        return create_predicates(self, other, "oge")

    def __gt__(self, other):
        return create_predicates(self, other, "ogt")

    def __sub__(self, other):
        return create_bin_operator(lhs=self, rhs=other, operation="sub")

    def __rsub__(self, other):
        return create_bin_operator(lhs=other, rhs=self, operation="sub")

    def __mul__(self, other):
        return create_bin_operator(lhs=self, rhs=other, operation="multiply")

    def __rmul__(self, other):
        return create_bin_operator(lhs=other, rhs=self, operation="multiply")

    def __add__(self, other):
        return create_bin_operator(lhs=self, rhs=other, operation="add")

    def __radd__(self, other):
        return create_bin_operator(lhs=other, rhs=self, operation="add")


class Location:
    # expected item 1st argument to be slice, 2nd to be list of columns
    def __init__(self, dataframe):
        self.dataframe = dataframe

    def __getitem__(self, item):
        slc = item[0]
        global ssa_id
        columns = item[1:][0]
        new_dict = {}
        for k in columns:
            new_dict[k] = self.dataframe.type_dict[k]
        new_df = DataFrame(new_dict, ssa_id)
        ssa_id += 1
        ir = "%{ssa} = pd.select(%{old_ssa}: {old_ssa_type}, {columns}) : {ssa_type}"
        old_ssa_type = format_df_type(self.dataframe)
        ssa_type = format_df_type(new_df)
        print(
            ir.format(
                ssa=new_df.ssa_id,
                old_ssa=self.dataframe.ssa_id,
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
    global ssa_id
    dataframe = DataFrame(type_dict, ssa_id)
    ssa_id += 1
    ir = '%{ssa} = pd.read_csv ("{filename}") : {return_type}'
    print(
        ir.format(
            ssa=dataframe.ssa_id,
            filename=filename,
            return_type=format_df_type(dataframe),
        )
    )
    return dataframe
