import matplotlib.pyplot as plt
import numpy as np

from scripts.utils import copy_data_as_typst

N = 8


def analytical_approximation(x):
    return (1 - (1 - x) ** N) ** (N + 1)


def monte_carlo_approximation(x):
    total_samples = 10**5 * 3
    valid_samples = 0

    for _ in range(total_samples):
        iats = np.random.dirichlet(np.ones(N + 1))

        if np.max(iats) < x:
            valid_samples += 1

    return valid_samples / total_samples


if __name__ == "__main__":
    x_values = np.linspace(0, 1, 50)
    analytical_values = [analytical_approximation(x) for x in x_values]
    monte_carlo_values = [monte_carlo_approximation(x) for x in x_values]

    copy_data_as_typst(x_values, monte_carlo_values)

    plt.figure()
    plt.xlabel("x")
    plt.ylabel("P")
    plt.plot(
        x_values, analytical_values, label="Analytical Approximation", linestyle="--"
    )
    plt.plot(
        x_values, monte_carlo_values, label="Monte Carlo Approximation", linestyle="-"
    )
    plt.legend()
    plt.grid(True)
    plt.show()
