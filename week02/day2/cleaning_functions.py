"""Cleaning and formatting functions for the customer insurance dataset.

Each function does one job and returns a fresh copy of the DataFrame
(never mutates the one it's given) so they can be chained safely in
clean_data().
"""

import pandas as pd


def clean_column_names(df: pd.DataFrame) -> pd.DataFrame:
    df2 = df.copy()
    df2.columns = df2.columns.str.lower().str.replace(" ", "_")
    df2.rename(columns={"st": "state"}, inplace=True)
    return df2


def clean_invalid_values(df: pd.DataFrame) -> pd.DataFrame:
    df2 = df.copy()
    df2["gender"] = df2["gender"].str[0].str.upper()   # F/Femal/female -> F, M/Male -> M
    df2["state"] = df2["state"].replace({
        "AZ": "Arizona", "Cali": "California", "WA": "Washington",
    })
    df2["education"] = df2["education"].replace({"Bachelors": "Bachelor"})
    df2["customer_lifetime_value"] = df2["customer_lifetime_value"].str.replace("%", "", regex=False)
    df2["vehicle_class"] = df2["vehicle_class"].replace({
        "Sports Car": "Luxury", "Luxury SUV": "Luxury", "Luxury Car": "Luxury",
    })
    return df2


def format_data_types(df: pd.DataFrame) -> pd.DataFrame:
    df2 = df.copy()
    df2["customer_lifetime_value"] = pd.to_numeric(df2["customer_lifetime_value"], errors="coerce")
    # "1/0/00" -> take the middle number, e.g. "0"
    df2["number_of_open_complaints"] = df2["number_of_open_complaints"].str.split("/").str[1]
    df2["number_of_open_complaints"] = pd.to_numeric(df2["number_of_open_complaints"], errors="coerce")
    return df2


def handle_nulls(df: pd.DataFrame) -> pd.DataFrame:
    df2 = df.copy()
    df2 = df2.dropna(subset=["customer"])   # rows with no customer id are empty padding, not real data
    df2["gender"] = df2["gender"].fillna(df2["gender"].mode()[0])
    df2["customer_lifetime_value"] = df2["customer_lifetime_value"].fillna(
        df2["customer_lifetime_value"].median()
    )
    numeric_cols = df2.select_dtypes(include="number").columns
    df2[numeric_cols] = df2[numeric_cols].astype(int)   # last step: all numeric columns to int
    return df2


def handle_duplicates(df: pd.DataFrame) -> pd.DataFrame:
    df2 = df.copy()
    df2 = df2.drop_duplicates()
    df2.reset_index(drop=True, inplace=True)
    return df2


def clean_data(df: pd.DataFrame) -> pd.DataFrame:
    df2 = df.copy()
    df2 = clean_column_names(df2)
    df2 = clean_invalid_values(df2)
    df2 = format_data_types(df2)
    df2 = handle_nulls(df2)
    df2 = handle_duplicates(df2)
    return df2
