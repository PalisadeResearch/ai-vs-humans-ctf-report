import argparse
import math
import sys

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
from loguru import logger
from sklearn.linear_model import LogisticRegression

from src.data import Event, ai_vs_hum_event, ca_event


# %%
def plot_is_ai_solved_vs_median_human_time(
    event: Event, select_n_fastest_humans: list[int | None] | None = None
):
    if select_n_fastest_humans is None:
        select_n_fastest_humans = [None]

    challenge_data = event.challenges_data.copy()
    data = []
    for _, row in challenge_data.iterrows():
        if row["category"] == "OSINT":
            # Some OSINT challenges have no docker or files, so impossible to calculate
            # median human time. Hence we just skip them.
            continue
        challenge_name = row["name"]
        for top_n_human_teams in select_n_fastest_humans:
            human_team_names = event.human_team_names
            if top_n_human_teams is not None:
                human_team_names = human_team_names[:top_n_human_teams]
            human_solve_times = [
                event.teams_data[team]
                .challenge_interactions[challenge_name]
                .get_solve_time()
                for team in human_team_names
                if event.teams_data[team]
                .challenge_interactions[challenge_name]
                .get_solve_time()
                and event.teams_data[team]
                .challenge_interactions[challenge_name]
                .get_solve_time()
                != 0
            ]
            is_ai_solved = any(
                event.teams_data[team]
                .challenge_interactions[challenge_name]
                .first_challenge_solved
                is not None
                for team in event.ai_team_names
            )

            median_human_time = np.median(human_solve_times)
            data.append(
                {
                    "challenge_name": challenge_name,
                    "median_human_time": median_human_time,
                    "is_ai_solved": is_ai_solved,
                    "top_n_human_teams": top_n_human_teams,
                }
            )

    df = pd.DataFrame(data)

    # Convert seconds to hours
    df["median_human_time"] = df["median_human_time"] / 3600

    # Create categorical labels combining team group and AI status
    if select_n_fastest_humans == [None]:
        df["category"] = df.apply(
            lambda x: "Solved by AI" if x["is_ai_solved"] else "Not Solved by AI",
            axis=1,
        )
    else:
        df["category"] = df.apply(
            lambda x: (
                "All teams"
                if x["top_n_human_teams"] is None
                else (
                    str(int(x["top_n_human_teams"])) + " top teams"
                    if not math.isnan(x["top_n_human_teams"])
                    else "All teams"
                )
                + " "
                + ("✓" if x["is_ai_solved"] else "✗")
            ),
            axis=1,
        )
        df = df.sort_values(
            [
                "top_n_human_teams",
                "is_ai_solved",
                "median_human_time",
                "challenge_name",
            ],
            ascending=[True, False, True, True],
            kind="stable",
        ).reset_index(drop=True)

    plt.figure(figsize=(12, 2 * len(select_n_fastest_humans)))

    sns.boxplot(
        data=df,
        x="median_human_time",
        y="category",
        hue="is_ai_solved",
        width=0.5,
        log_scale=True,
    )

    sns.scatterplot(
        data=df,
        x="median_human_time",
        y="category",
        hue="is_ai_solved",
        alpha=0.5,
        legend=False,
    )

    plt.xlabel("Median Human Solve Time")
    if select_n_fastest_humans == [None]:
        plt.ylabel("")
    else:
        plt.ylabel("Human teams used as reference")

    plt.xticks(
        [5 / 60, 10 / 60, 30 / 60, 1, 2, 10, 80],
        ["5min", "10min", "30min", "1h", "2h", "10h", "80h"],
    )

    plt.title(f"Is Solved by AI vs Median Human Solve Time - {event.event_name}")
    plt.legend(
        title="Is Solved by AI",
    )


# Sample calls for direct execution
# Uncomment these for debugging if needed
# plot_is_ai_solved_vs_median_human_time(ai_vs_hum_event)
# plot_is_ai_solved_vs_median_human_time(
#     ai_vs_hum_event, select_n_fastest_humans=[3, 10, 50, None]
# )
# plot_is_ai_solved_vs_median_human_time(ca_event)
# plot_is_ai_solved_vs_median_human_time(
#     ca_event, select_n_fastest_humans=[10, 100, 500, None]
# )

# %%


def plot_is_ai_solved_vs_median_human_time_regression(
    event: Event,
    select_n_fastest_humans: list[float | None] | None = None,
    show_title: bool = True,
):
    if select_n_fastest_humans is None:
        select_n_fastest_humans = [None]

    selected_human_team_names = [
        team_name
        for team_name in event.human_team_names
        if event.teams_data[team_name].total_solves > 0
    ]

    challenge_data = event.challenges_data.copy().sort_values(by="name")

    data = []
    for _, row in challenge_data.iterrows():
        if row["category"] == "OSINT":
            # Some OSINT challenges have no docker or files, so impossible to calculate
            # median human time. Hence we just skip them.
            continue
        challenge_name = row["name"]
        for top_n_human_teams in select_n_fastest_humans:
            if top_n_human_teams is not None:
                selected_top_teams_count = int(
                    top_n_human_teams * len(selected_human_team_names)
                )
            else:
                selected_top_teams_count = len(selected_human_team_names)
            top_human_team_names = selected_human_team_names[:selected_top_teams_count]
            human_solve_times = [
                event.teams_data[team]
                .challenge_interactions[challenge_name]
                .get_solve_time()
                for team in top_human_team_names
                if event.teams_data[team]
                .challenge_interactions[challenge_name]
                .get_solve_time()
                and event.teams_data[team]
                .challenge_interactions[challenge_name]
                .get_solve_time()
                != 0
            ]
            is_ai_solved = any(
                event.teams_data[team]
                .challenge_interactions[challenge_name]
                .first_challenge_solved
                is not None
                for team in event.ai_team_names
            )

            median_human_time = np.median(human_solve_times)
            data.append(
                {
                    "challenge_name": challenge_name,
                    "median_human_time": median_human_time,
                    "is_ai_solved": is_ai_solved,
                    "top_n_human_teams": top_n_human_teams,
                    "selected_top_teams_count": selected_top_teams_count,
                }
            )

    df = pd.DataFrame(data)

    # Convert seconds to hours
    df["median_human_time"] = df["median_human_time"] / 3600

    # Create categorical labels combining team group and AI status
    if select_n_fastest_humans == [None]:
        df["category"] = df.apply(
            lambda x: "Solved by AI" if x["is_ai_solved"] else "Not Solved by AI",
            axis=1,
        )
    else:
        df["category"] = df.apply(
            lambda x: (
                "All teams"
                if x["top_n_human_teams"] is None
                else (
                    str(int(x["top_n_human_teams"])) + " top teams"
                    if not math.isnan(x["top_n_human_teams"])
                    else "All teams"
                )
                + " "
                + ("✓" if x["is_ai_solved"] else "✗")
            ),
            axis=1,
        )
        df = df.sort_values(
            [
                "top_n_human_teams",
                "is_ai_solved",
                "median_human_time",
                "challenge_name",
            ],
            ascending=[True, False, True, True],
            kind="stable",
        ).reset_index(drop=True)

    # Create vertically stacked subplots
    n_plots = len(select_n_fastest_humans)
    fig, axes = plt.subplots(
        n_plots,
        1,
        figsize=(12, 2 * n_plots if n_plots > 1 else 3),
        sharex=True,
        squeeze=False,
    )

    # Plot each group in its own subplot
    for idx, n in enumerate(select_n_fastest_humans):
        # Handle None/NaN comparison properly
        subset = (
            df[pd.isna(df["top_n_human_teams"])]
            if n is None
            else df[df["top_n_human_teams"] == n]
        )

        # Scatter plot with different colors
        solved = subset[subset["is_ai_solved"]]
        not_solved = subset[~subset["is_ai_solved"]]

        axes[idx, 0].scatter(
            solved["median_human_time"],
            solved["is_ai_solved"],
            alpha=0.5,
            label="Challenges AI could solve" if idx == 0 else None,
            color="green",
        )
        axes[idx, 0].scatter(
            not_solved["median_human_time"],
            not_solved["is_ai_solved"],
            alpha=0.5,
            label="Challenges AI couldn't solve" if idx == 0 else None,
            color="red",
        )

        # Regression curve with log-transformed times
        X = np.log(subset["median_human_time"].values).reshape(-1, 1)
        time_points = np.linspace(X.min(), X.max(), 100)
        model = LogisticRegression()
        model.fit(X, subset["is_ai_solved"].values)
        pred_probs = model.predict_proba(time_points.reshape(-1, 1))[:, 1]

        # Convert back to original scale for plotting
        axes[idx, 0].plot(
            np.exp(time_points),
            pred_probs,
            "--",
            label="Fitted curve" if idx == 0 else None,  # Only label first subplot
            color="blue",
        )

        # Find and plot the 50% threshold
        threshold_time = -model.intercept_[0] / model.coef_[0][0]  # in log space
        threshold_time = np.exp(threshold_time)  # convert back to hours

        if X.min() < np.log(threshold_time) < X.max():
            axes[idx, 0].axvline(
                x=threshold_time, color="gray", linestyle=":", alpha=0.5
            )
            # Format time string
            if threshold_time < 1:  # less than an hour
                time_str = f"{threshold_time * 60:.1f}min"
            else:
                time_str = f"{threshold_time:.1f}h"
            axes[idx, 0].annotate(
                f"50% at {time_str}",
                xy=(threshold_time, 0.5),
                xytext=(10, 10),
                textcoords="offset points",
                ha="left",
                va="bottom",
                bbox=dict(boxstyle="round,pad=0.5", fc="white", alpha=0.8),
                arrowprops=dict(arrowstyle="->", connectionstyle="arc3,rad=0"),
            )

        # Customize subplot
        axes[idx, 0].set_xscale("log")
        if idx == n_plots - 1:  # Only show xlabel on bottom subplot
            axes[idx, 0].set_xlabel("Median Human Solve Time")
        axes[idx, 0].grid(True, alpha=0.3)
        axes[idx, 0].set_ylim(-0.1, 1.1)
        axes[idx, 0].set_yticks([0, 0.5, 1])
        axes[idx, 0].set_xticks(
            [5 / 60, 10 / 60, 30 / 60, 1, 2, 4, 10, 40],
            ["5 min", "10 min", "30 min", "1 h", "2 h", "4 h", "10 h", "40 h"],
        )
        axes[idx, 0].minorticks_off()
        # Conditionally set title
        if show_title:
            axes[idx, 0].set_title(
                "Time estimates based on "
                + (
                    f"top {n * 100}% ({list(subset['selected_top_teams_count'])[0]}) "
                    if n is not None
                    else f"all ({len(selected_human_team_names)}) "
                )
                + "human teams"
            )

        if idx == 0:
            axes[idx, 0].legend()

        for spine in axes[idx, 0].spines.values():
            spine.set_visible(False)

    if n_plots == 1:
        plt.ylabel("Probability of AI Solving")
    else:
        fig.supylabel("Probability of AI Solving")

    plt.tight_layout()


# Dictionary of available figure functions
FIGURE_FUNCTIONS = {
    # Simple AI solved vs human time plots
    "is_ai_solved_vs_median_human_time_aivshum": lambda: plot_is_ai_solved_vs_median_human_time(
        ai_vs_hum_event
    ),
    "is_ai_solved_vs_median_human_time_aivshum_detailed": lambda: plot_is_ai_solved_vs_median_human_time(
        ai_vs_hum_event, select_n_fastest_humans=[3, 10, 50, None]
    ),
    "is_ai_solved_vs_median_human_time_ca": lambda: plot_is_ai_solved_vs_median_human_time(
        ca_event
    ),
    "is_ai_solved_vs_median_human_time_ca_detailed": lambda: plot_is_ai_solved_vs_median_human_time(
        ca_event, select_n_fastest_humans=[10, 100, 500, None]
    ),
    # Regression plots
    "is_ai_solved_vs_median_human_time_regression_aivshum": lambda show_title=True: plot_is_ai_solved_vs_median_human_time_regression(
        ai_vs_hum_event, show_title=show_title
    ),
    "is_ai_solved_vs_median_human_time_regression_aivshum_detailed": lambda show_title=True: plot_is_ai_solved_vs_median_human_time_regression(
        ai_vs_hum_event,
        select_n_fastest_humans=[0.01, 0.1, 0.5, None],
        show_title=show_title,
    ),
    "is_ai_solved_vs_median_human_time_regression_ca": lambda show_title=True: plot_is_ai_solved_vs_median_human_time_regression(
        ca_event, select_n_fastest_humans=[0.01], show_title=show_title
    ),
    "is_ai_solved_vs_median_human_time_regression_ca_detailed": lambda show_title=True: plot_is_ai_solved_vs_median_human_time_regression(
        ca_event,
        select_n_fastest_humans=[0.005, 0.01, 0.1, None],
        show_title=show_title,
    ),
}


def main():
    parser = argparse.ArgumentParser(
        description="Generate time horizon plots for CTF analysis"
    )
    parser.add_argument(
        "figure_name",
        help=f"Name of the figure to generate. Available figures: {', '.join(FIGURE_FUNCTIONS.keys())}",
    )
    parser.add_argument(
        "--no-title",
        action="store_true",
        help="Hide the title of the plot (currently only affects 'is_ai_solved_vs_median_human_time_regression_ca').",
    )

    args = parser.parse_args()

    if args.figure_name not in FIGURE_FUNCTIONS:
        logger.error(f"Unknown figure name '{args.figure_name}'")
        logger.error(f"Available figures: {', '.join(FIGURE_FUNCTIONS.keys())}")
        sys.exit(1)

    show_title = not args.no_title

    figure_func = FIGURE_FUNCTIONS[args.figure_name]

    # Try to pass the show_title flag. If the function doesn't accept it, fall back.
    try:
        figure_func(show_title=show_title)
    except TypeError:
        figure_func()

    # Save the figure to stdout
    plt.savefig(sys.stdout.buffer, format="svg", bbox_inches="tight")
    plt.close()


if __name__ == "__main__":
    main()

# %%
