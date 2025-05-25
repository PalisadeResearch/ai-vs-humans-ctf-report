# %%
import argparse
import sys
from itertools import chain
from typing import Literal

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
from loguru import logger

from src.data import Event, ai_vs_hum_event, ca_event

# %%


def plot_challenge_stats(event: Event, outlier_threshold=60 * 60 * 6):
    difficulty_order = {
        "very easy": 0,
        "easy": 1,
        "medium": 2,
        "hard": 3,
    }

    challenge_names = list(
        sorted(
            event.challenges_data["name"],
            key=lambda x: (
                difficulty_order[
                    event.challenges_data[event.challenges_data["name"] == x][
                        "difficulty"
                    ].values[0]
                ],
                x,
            ),
        )
    )

    # These challenges do not seem to have files or docker
    # (They are osint - and require only googling)
    if "The Poisoned Scroll" in challenge_names:
        challenge_names.remove("The Poisoned Scroll")
        challenge_names.remove("The Shadowed Sigil")

    all_solve_times = {}
    for challenge_name in challenge_names:
        solve_times = [
            team.challenge_interactions[challenge_name].get_solve_time()
            for team in event.teams_data.values()
            if team.challenge_interactions[challenge_name].first_challenge_solved
            is not None
        ]
        solve_times = [t for t in solve_times if 0 < t < outlier_threshold]
        if len(solve_times) == 0:
            logger.warning(f"Challenge {challenge_name} has no solve times")
        if min(solve_times) < 0:
            logger.warning(f"Challenge {challenge_name} has negative solve time")
        all_solve_times[challenge_name] = solve_times

    challenge_difficulties = {
        row["name"]: row["difficulty"] for _, row in event.challenges_data.iterrows()
    }

    # Convert the dictionary to a format suitable for seaborn
    plot_data = []
    for challenge_name in challenge_names:
        is_solved_by_ai = (
            event.teams_data["[AI] CAI"]
            .challenge_interactions[challenge_name]
            .first_challenge_solved
            is not None
        )
        plot_data.extend(
            [
                (
                    f"{challenge_name} ({challenge_difficulties[challenge_name]}) "
                    f"(solves:  {len(all_solve_times[challenge_name])})"
                    f"{is_solved_by_ai}",
                    t,
                )
                for t in all_solve_times[challenge_name]
            ]
        )

    df = pd.DataFrame(plot_data, columns=["Challenge", "Solve Time (seconds)"])

    # Create color palette
    palette = {
        "very easy": "green",
        "easy": "lightgreen",
        "medium": "orange",
        "hard": "red",
    }
    colors = [
        palette[challenge_difficulties[challenge_name]]
        for challenge_name in challenge_names
    ]

    # Create the plot
    plt.figure(figsize=(10, max(8, len(all_solve_times) * 0.8)))
    # sns.stripplot(
    #     data=df,
    #     x="Solve Time (seconds)",
    #     y="Challenge",
    #     orient="h",
    #     # cut=0,
    #     order=challenge_order,
    #     palette=colors,
    #     # log_scale=True,
    # )

    sns.violinplot(
        data=df,
        x="Solve Time (seconds)",
        y="Challenge",
        orient="h",
        cut=0,
        palette=colors,
        # log_scale=True,
    )

    plt.title(f"Challenge Solve Times Distribution - {event.event_name}")
    plt.tight_layout()

    # Count solve times under 30 seconds:
    tiny_threshold = 30
    logger.info(
        f"Number of solve times under {tiny_threshold} seconds: "
        f"{len([t for t in chain(*all_solve_times.values()) if t < tiny_threshold])}"
    )


# %%

AI_COLOR = "red"
HUMAN_COLOR = "blue"


def get_team_flags_sequence(_interactions_data: pd.DataFrame, team_name: str):
    return _interactions_data[
        (_interactions_data["team_name"] == team_name)
        & (_interactions_data["interaction_type"] == "challenge solved")
    ].sort_values(by="created_at")


def calculate_team_time_deltas(event: Event, team_name: str) -> list[int]:
    flags_sequence = get_team_flags_sequence(event.interactions_data, team_name)

    # Calculate time differences between consecutive flags
    times_per_flag = list(flags_sequence["created_at"].diff().dropna())

    # Calculate time from event start to first flag
    first_flag_time = flags_sequence["created_at"].min()
    time_to_first_flag = first_flag_time - event.event_start

    times_per_flag = [time_to_first_flag] + times_per_flag

    times_per_flag = [timedelta.seconds for timedelta in times_per_flag]

    return times_per_flag


# %%


def plot_histograms(
    event: Event,
    team_selection: Literal["top", "all"] = "top",
    log_scale=False,
    bins_count=100,
):
    if team_selection == "top":
        ai_teams = event.top_ai_teams
        human_teams = event.top_human_teams
    elif team_selection == "all":
        ai_teams = event.ai_team_names
        human_teams = event.human_team_names

    ai_times = list(
        chain(*[calculate_team_time_deltas(event, team) for team in ai_teams])
    )

    human_times = list(
        chain(*[calculate_team_time_deltas(event, team) for team in human_teams])
    )

    # Create log-spaced bins
    if log_scale:
        bins = np.logspace(
            np.log10(min(min(ai_times), min(human_times))),
            np.log10(max(max(ai_times), max(human_times))),
            bins_count,
        )
    else:
        bins = np.linspace(
            min(min(ai_times), min(human_times)),
            # max(max(ai_times), max(human_times)),
            3600 / 2,
            bins_count,
        )

    # Plot histograms with proper normalization for log scale
    plt.hist(
        ai_times,
        bins=bins,
        alpha=0.5,
        label=f"Top {len(ai_teams)} AI agents",
        weights=np.ones_like(ai_times) / len(ai_times),
    )
    plt.hist(
        human_times,
        bins=bins,
        alpha=0.5,
        label=f"Top {len(human_teams)} human teams",
        weights=np.ones_like(human_times) / len(human_times),
    )
    if log_scale:
        plt.xscale("log")
    plt.legend()
    # plt.ylabel("Normalized Count")
    plt.xlabel("Time per challenge (seconds)")
    plt.title(event.event_name)
    plt.tight_layout()


# %%


def get_team_score_progression(
    event: Event,
    team_name: str,
    aligned=False,
):
    team_flags = get_team_flags_sequence(event.interactions_data, team_name)

    solve_times = team_flags["created_at"].tolist()

    if len(solve_times) == 0:
        raise ValueError(f"Team {team_name} has no solves")

    # Choose reference time based on alignment mode
    reference_time = solve_times[0] if aligned else event.event_start

    # Calculate times relative to reference
    times = [(t - reference_time).total_seconds() for t in solve_times]
    scores = range(1, len(team_flags) + 1)

    return times, scores


def calculate_nth_solve_medians(
    event: Event,
    teams: list[str],
    aligned=False,
):
    solve_times_by_n: dict[int, list[int]] = {}

    for team in teams:
        times, scores = get_team_score_progression(event, team, aligned=aligned)

        # Record each nth solve time
        for n, time in enumerate(times, 1):
            if n not in solve_times_by_n:
                solve_times_by_n[n] = []
            solve_times_by_n[n].append(time)

    # Calculate medians for each n
    times = []
    scores = []
    for n in sorted(solve_times_by_n.keys()):
        times.append(np.median(solve_times_by_n[n]))
        scores.append(n)

    return times, scores


def plot_team_progression(
    event: Event,
    aligned=False,
    plot_medians=False,
    x_lim=10000,
    player_normalized=False,
    background_alpha=0.2,
    _human_teams: list[str] | None = None,
    all_human_teams: bool = False,
    _ai_teams: list[str] | None = None,
    ai_teams_alpha=None,
    human_teams_alpha=None,
):
    plt.figure(figsize=(12, 3))

    human_teams = event.top_human_teams if _human_teams is None else _human_teams

    ai_teams = event.top_ai_teams if _ai_teams is None else _ai_teams

    if ai_teams_alpha is None:
        ai_teams_alpha = background_alpha
    if human_teams_alpha is None:
        human_teams_alpha = background_alpha

    # Plot individual team lines
    for team in ai_teams:
        times, scores = get_team_score_progression(event, team, aligned=aligned)
        plt.plot(
            times,
            scores,
            "-o",
            markersize=4,
            linewidth=1,
            alpha=ai_teams_alpha,
            color=AI_COLOR,
            label="AI agents" if team == ai_teams[0] and not plot_medians else None,
        )

    for team in human_teams:
        times, scores = get_team_score_progression(event, team, aligned=aligned)

        if player_normalized:
            times = [t * event.teams_data[team].number_of_players for t in times]

        if all_human_teams:
            label = "Human teams"
        else:
            label = f"Top {len(human_teams)} human teams" + (
                " (Player-Normalized)" if player_normalized else ""
            )
        label = label if team == human_teams[0] and not plot_medians else None

        plt.plot(
            times,
            scores,
            "-o",
            markersize=4,
            linewidth=1,
            alpha=human_teams_alpha,
            color=HUMAN_COLOR,
            label=label,
        )

    if plot_medians:
        ai_times, ai_scores = calculate_nth_solve_medians(
            event, ai_teams, aligned=aligned
        )
        if player_normalized:
            human_times, human_scores = [], []
            solve_times_by_n = {}

            for team in human_teams:
                times, scores = get_team_score_progression(event, team, aligned=aligned)
                player_count = event.teams_data[team].number_of_players
                normalized_times = [t * player_count for t in times]

                for n, time in enumerate(normalized_times, 1):
                    if n not in solve_times_by_n:
                        solve_times_by_n[n] = []
                    solve_times_by_n[n].append(time)

            for n in sorted(solve_times_by_n.keys()):
                human_times.append(np.median(solve_times_by_n[n]))
                human_scores.append(n)

        else:
            human_times, human_scores = calculate_nth_solve_medians(
                event, human_teams, aligned=aligned
            )

        plt.plot(
            ai_times,
            ai_scores,
            "--",
            label=f"Top {len(ai_teams)} AI agents median",
            linewidth=3,
            color=AI_COLOR,
        )
        plt.plot(
            human_times,
            human_scores,
            "--",
            label=(
                f"Top {len(human_teams)} human teams median"
                + (" (Player-Normalized)" if player_normalized else "")
            ),
            linewidth=3,
            color=HUMAN_COLOR,
        )

    # plt.xscale("log")
    FONT_SIZE = 14
    plt.xlim(0, x_lim)
    plt.xticks(range(0, x_lim, 3600), [f"{t // 3600}h" for t in range(0, x_lim, 3600)])
    plt.xlabel(
        "Time since start" if not aligned else "Elapsed since team's first submission",
        fontsize=FONT_SIZE,
    )
    plt.ylabel("Challenges solved", fontsize=FONT_SIZE)
    max_y = max(
        [event.teams_data[team].total_solves for team in ai_teams + human_teams]
    )
    plt.yticks(range(0, max_y + 1, max_y // 5))
    plt.ylim(1, max_y + 0.1)
    # plt.title(
    #     "Top Teams Score Progression"
    #     if not aligned
    #     else "Team Score Progression After First Solve"
    # )
    plt.legend(loc="lower right", fontsize=FONT_SIZE)
    ax = plt.gca()
    ax.spines["right"].set_visible(False)
    ax.spines["top"].set_visible(False)
    plt.tight_layout()


def plot_team_progression_highlight_first(event: Event, aligned=False):
    plt.figure(figsize=(15, 8))
    plt.grid(True, alpha=0.3)

    # Plot individual team lines
    for team in event.top_ai_teams:
        times, scores = get_team_score_progression(event, team, aligned=aligned)
        plt.plot(
            times,
            scores,
            "-o",
            markersize=4,
            linewidth=1,
            alpha=1 if team == event.top_ai_teams[0] else 0.2,
            color=AI_COLOR,
            label="Best AI Team" if team == event.top_ai_teams[0] else None,
        )

    for team in event.top_human_teams:
        times, scores = get_team_score_progression(event, team, aligned=aligned)
        plt.plot(
            times,
            scores,
            "-o",
            markersize=4,
            linewidth=1,
            alpha=1 if team == event.top_human_teams[0] else 0.2,
            color=HUMAN_COLOR,
            label="Best Human Team" if team == event.top_human_teams[0] else None,
        )

    # plt.xscale("log")
    plt.xlim(0, 10000)
    plt.xlabel("Time since start" if not aligned else "Time since first solve")
    plt.ylabel("Flags owned")
    plt.title(
        f"{event.event_name} - Top Teams Score Progression"
        + (" After First Solve" if aligned else "")
    )
    plt.legend(bbox_to_anchor=(1.05, 1), loc="upper left")
    plt.tight_layout()


# Dictionary of available figure functions
FIGURE_FUNCTIONS = {
    # Challenge solve time plots
    "challenge_solve_times_aivshum": lambda: plot_challenge_stats(ai_vs_hum_event),
    "challenge_solve_times_ca": lambda: plot_challenge_stats(
        ca_event, outlier_threshold=60 * 60 * 24 * 4
    ),
    # Histogram plots
    "histogram_aivshum_top": lambda: plot_histograms(ai_vs_hum_event),
    "histogram_ca_top": lambda: plot_histograms(ca_event),
    "histogram_aivshum_all": lambda: plot_histograms(
        ai_vs_hum_event, team_selection="all"
    ),
    # Team progression plots - AI vs Humans CTF
    "team_progression_aivshum_unaligned": lambda: plot_team_progression(
        event=ai_vs_hum_event,
        aligned=False,
        plot_medians=False,
        background_alpha=0.8,
    ),
    "team_progression_aivshum_aligned": lambda: plot_team_progression(
        event=ai_vs_hum_event,
        aligned=True,
        plot_medians=True,
    ),
    "team_progression_aivshum_aligned_top7": lambda: plot_team_progression(
        event=ai_vs_hum_event,
        aligned=True,
        plot_medians=False,
        background_alpha=0.2,
        _human_teams=[
            team
            for team in ai_vs_hum_event.human_team_names
            if ai_vs_hum_event.teams_data[team].total_solves > 0
        ],
        all_human_teams=True,
        _ai_teams=[
            "[AI] CAI",
            "[AI] Palisade Claude Code",
            "[AI] Palisade R&P OA",
            "[AI] Project S1ngularity",
            "[AI] Cyagent",
            "[AI] imperturbable",
            "[AI] FCT",
        ],
        ai_teams_alpha=0.8,
        human_teams_alpha=0.1,
    ),
    "team_progression_aivshum_aligned_normalized": lambda: plot_team_progression(
        event=ai_vs_hum_event,
        aligned=True,
        plot_medians=True,
        player_normalized=True,
    ),
    # Team progression plots - CyberApocalypse
    "team_progression_ca_unaligned": lambda: plot_team_progression(
        event=ca_event, aligned=False, x_lim=100000, ai_teams_alpha=0.5
    ),
    "team_progression_ca_aligned": lambda: plot_team_progression(
        event=ca_event,
        aligned=True,
        x_lim=100000,
        ai_teams_alpha=0.5,
    ),
    "team_progression_ca_aligned_normalized": lambda: plot_team_progression(
        event=ca_event,
        aligned=True,
        x_lim=100000,
        player_normalized=True,
    ),
    # Team highlight first plots
    "team_highlight_aivshum_unaligned": lambda: plot_team_progression_highlight_first(
        event=ai_vs_hum_event,
        aligned=False,
    ),
    "team_highlight_aivshum_aligned": lambda: plot_team_progression_highlight_first(
        event=ai_vs_hum_event,
        aligned=True,
    ),
    # No 'all' option - we only support individual figures
}


# We no longer support the 'all' mode - each figure must be generated individually


def main():
    parser = argparse.ArgumentParser(
        description="Generate data visualization figures for CTF analysis"
    )
    parser.add_argument(
        "figure_name",
        nargs="?",
        default="all",
        help=f"""Name of the figure to generate.
        Available figures: {", ".join(FIGURE_FUNCTIONS.keys())}""",
    )

    args = parser.parse_args()

    figure_name = args.figure_name

    if figure_name not in FIGURE_FUNCTIONS:
        logger.error(f"Unknown figure name '{figure_name}'")
        logger.error(f"Available figures: {', '.join(FIGURE_FUNCTIONS.keys())}")
        sys.exit(1)

    # Call the appropriate function to generate the figure
    FIGURE_FUNCTIONS[figure_name]()

    # Save the figure to stdout
    plt.savefig(sys.stdout.buffer, format="svg", bbox_inches="tight")
    plt.close()


if __name__ == "__main__":
    main()
