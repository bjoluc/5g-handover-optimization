import sys

import numpy as np
from numpy.typing import NDArray


def get_model_name():
    return sys.argv[-1]


def get_model_path():
    model_name_components = get_model_name().split("/")
    model_name = model_name_components[0]
    file_name = (
        "last_model" if len(model_name_components) == 1 else model_name_components[1]
    )
    return f"./models/{model_name}/{file_name}.zip"


def compute_jains_fairness_index(x: NDArray):
    denominator = np.sum(np.square(x)) * len(x)
    return (
        np.sum(x) ** 2 / denominator
        if denominator != 0
        else 0  # to prevent reward hacking – although "no one gets anything" is technically fair (:
    )
