# %%
from itertools import chain
from typing import Literal

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns

from src.data import (
    Event,
    ai_vs_hum_event,
    ca_event,
    repo_root,
)

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
            print(f"Challenge {challenge_name} has no solve times")
        if min(solve_times) < 0:
            print(f"Challenge {challenge_name} has negative solve time")
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
    plt.savefig(
        repo_root
        / f"paper-typst/plots/challenge_solve_times_{event.event_name_no_spaces}.png"
    )
    plt.show()

    # Count solve times under 30 seconds:
    tiny_threshold = 30
    print(
        f"Number of solve times under {tiny_threshold} seconds: "
        f"{len([t for t in chain(*all_solve_times.values()) if t < tiny_threshold])}"
    )


plot_challenge_stats(ai_vs_hum_event)

plot_challenge_stats(ca_event, outlier_threshold=60 * 60 * 24 * 4)


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
        label=f"Top {len(ai_teams)} AI Teams",
        weights=np.ones_like(ai_times) / len(ai_times),
    )
    plt.hist(
        human_times,
        bins=bins,
        alpha=0.5,
        label=f"Top {len(human_teams)} Human Teams",
        weights=np.ones_like(human_times) / len(human_times),
    )
    if log_scale:
        plt.xscale("log")
    plt.legend()
    # plt.ylabel("Normalized Count")
    plt.xlabel("Time per challenge (seconds)")
    plt.title(event.event_name)
    plt.savefig(
        repo_root / "paper-typst/plots/challenge_solve_times_histograms_"
        f"{event.event_name_no_spaces}_"
        f"{team_selection}.png"
    )
    plt.show()


# Todo these log plots are sus af
plot_histograms(ai_vs_hum_event)
plot_histograms(ca_event)
plot_histograms(ai_vs_hum_event, team_selection="all")
# plot_histograms(ca_event, team_selection="all")
# %%


def get_team_score_progression(
    event: Event,
    team_name: str,
    aligned=False,
):
    team_flags = get_team_flags_sequence(event.interactions_data, team_name)

    solve_times = team_flags["created_at"].tolist()

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
):
    plt.figure(figsize=(15, 8))
    plt.grid(True, alpha=0.3)

    background_alpha = 0.2
    # Plot individual team lines
    for team in event.top_ai_teams:
        times, scores = get_team_score_progression(event, team, aligned=aligned)
        plt.plot(
            times,
            scores,
            "-o",
            markersize=4,
            linewidth=1,
            alpha=background_alpha,
            color=AI_COLOR,
            label=f"Top {len(event.top_ai_teams)} AI Teams"
            if team == event.top_ai_teams[0] and not plot_medians
            else None,
        )

    for team in event.top_human_teams:
        times, scores = get_team_score_progression(event, team, aligned=aligned)

        if player_normalized:
            times = [t * event.teams_data[team].number_of_players for t in times]

        plt.plot(
            times,
            scores,
            "-o",
            markersize=4,
            linewidth=1,
            alpha=background_alpha,
            color=HUMAN_COLOR,
            label=f"Top {len(event.top_human_teams)} Human Teams"
            + (" (Player-Normalized)" if player_normalized else "")
            if team == event.top_human_teams[0] and not plot_medians
            else None,
        )

    if plot_medians:
        ai_times, ai_scores = calculate_nth_solve_medians(
            event, event.top_ai_teams, aligned=aligned
        )
        if player_normalized:
            human_times, human_scores = [], []
            solve_times_by_n = {}

            for team in event.top_human_teams:
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
                event, event.top_human_teams, aligned=aligned
            )

        plt.plot(
            ai_times,
            ai_scores,
            "--",
            label=f"Top {len(event.top_ai_teams)} AI Teams Median",
            linewidth=3,
            color=AI_COLOR,
        )
        plt.plot(
            human_times,
            human_scores,
            "--",
            label=(
                f"Top {len(event.top_human_teams)} Human Teams Median"
                + (" (Player-Normalized)" if player_normalized else "")
            ),
            linewidth=3,
            color=HUMAN_COLOR,
        )

    # plt.xscale("log")
    plt.xlim(0, x_lim)
    plt.xticks(range(0, x_lim, 3600), [f"{t // 3600}h" for t in range(0, x_lim, 3600)])
    plt.xlabel("Seconds since start" if not aligned else "Seconds since first solve")
    plt.ylabel("Challenges solved")
    # plt.yticks(range(2, 21, 2))
    plt.title(
        "Top Teams Score Progression"
        if not aligned
        else "Team Score Progression After First Solve"
    )
    plt.legend(loc="lower right", fontsize=18)
    plt.tight_layout()
    plt.savefig(
        repo_root / f"paper-typst/plots/team_progression_{event.event_name_no_spaces}_"
        f"{'aligned' if aligned else 'unaligned'}"
        f"{'_normalized' if player_normalized else ''}"
        ".png"
    )
    plt.show()


# Create the two plots using the shared function
plot_team_progression(
    event=ai_vs_hum_event,
    aligned=False,
    plot_medians=True,
)

plot_team_progression(
    event=ai_vs_hum_event,
    aligned=True,
    plot_medians=True,
)

plot_team_progression(
    event=ca_event,
    aligned=False,
    x_lim=100000,
)

plot_team_progression(
    event=ca_event,
    aligned=True,
    x_lim=100000,
)

# Same plots, but with the human team times normalized by player count

plot_team_progression(
    event=ai_vs_hum_event,
    aligned=True,
    plot_medians=True,
    player_normalized=True,
)

plot_team_progression(
    event=ca_event,
    aligned=True,
    x_lim=100000,
    player_normalized=True,
)

# %%


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
    plt.xlabel("Seconds since start" if not aligned else "Seconds since first flag")
    plt.ylabel("Flags owned")
    plt.title(
        f"{event.event_name} - Top Teams Score Progression"
        + (" After First Solve" if aligned else "")
    )
    plt.legend(bbox_to_anchor=(1.05, 1), loc="upper left")
    plt.tight_layout()
    plt.show()


plot_team_progression_highlight_first(
    event=ai_vs_hum_event,
    aligned=False,
)

plot_team_progression_highlight_first(
    event=ai_vs_hum_event,
    aligned=True,
)

# %%
