import numpy as np
import pyperclip


def copy_data_as_typst(
    x_values: np.ndarray, y_values: np.ndarray, include_variable_definition=True
):
    # Build a two-dimensional list string for Typst
    values = np.column_stack((x_values, y_values))
    value_strings = [f"({round(x,5)},{round(y,4)})" for x, y in values]
    values_string = f"({','.join(value_strings)})"

    if include_variable_definition:
        values_string = "#let data = " + values_string

    pyperclip.copy(values_string)
