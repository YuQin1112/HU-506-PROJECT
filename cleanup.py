import pandas as pd
import numpy as np
import sys

OUTPUT = "real_data.csv"
NAN = np.NaN

def _is_number(x):
    """
    Return true if input unknown data type can be converted to a number (int or float).
    """
    try:
        float(x)
    except:
        return False
    else:
        return True


def _fix_data_cell(column):
    """
    For each cell in a given column:
    - Remove unicode if a cell is alphabatical.
    - Replace cells that contain invalid data with NA.

    Data is invalid if it is not a number and not alphabatical.
    """
    for i in range(len(column)):
        if isinstance(column[i], str) and not _is_number(column[i]):
            ascii = column[i].encode('utf-8').decode('ascii', 'ignore')
            # TODO replace data instead of messing up with copies.
            column[i] = ascii if ascii.isalpha() else NAN
    return column


def read_dataframe(df_csv):
    """
    Read csv file into pandas dataframe, and fix column name unicode.
    """
    with open(df_csv, 'r') as csvfile:
        df = pd.read_csv(csvfile, sep=',' , encoding = 'utf-8')

    # fix unicode
    df.columns = [x.encode('utf-8').decode('ascii', 'ignore') for x in df.columns]
    df = df.rename(columns = {'ommunityname':'communityname'})

    return df


def replace_invalid_cells(df):
    """
    Process all data and replace invalid data with NA.
    """
    for column in df:
        df[column].replace(_fix_data_cell(df[column]))
    return df


def df_to_csv(df):
    """
    Dump dataframe to csv file.
    """
    df.to_csv(OUTPUT, encoding='utf-8', index=False)


def main():
    data = sys.argv[1]
    df = read_dataframe(data)
    df = replace_invalid_cells(df)
    df_to_csv(df)


if __name__ == "__main__":
    main()
