# %%
import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np

from data import challenge_data, participants_data


# %%
def create_leaderboard_visualization():
    # Increase default font sizes
    default_font_size = 80
    mpl.rcParams["font.size"] = default_font_size
    mpl.rcParams["axes.titlesize"] = default_font_size * 1.2
    mpl.rcParams["axes.labelsize"] = default_font_size
    mpl.rcParams["xtick.labelsize"] = default_font_size * 0.8
    mpl.rcParams["ytick.labelsize"] = default_font_size * 0.8
    mpl.rcParams["legend.fontsize"] = default_font_size * 0.8

    # Set high DPI for high resolution
    mpl.rcParams["figure.dpi"] = 300

    # Get all team scores and ranks
    team_data = {}
    palisade_teams = {}

    # Process all teams from participants data
    for _, row in participants_data.iterrows():
        team_name = row["team_name"]
        team_rank = row["rank"]
        flags_count = len(
            challenge_data[
                (challenge_data["team_name"] == team_name)
                & (challenge_data["interaction_type"] == "flag owned")
            ]
        )

        # Handle Palisade teams separately
        if team_name.startswith("[AI] Palisade"):
            if flags_count > 0:
                palisade_teams[team_name] = (flags_count, team_rank)
        # Process other teams normally
        elif flags_count > 0:
            team_data[team_name] = (flags_count, team_rank)

    # Add only the best Palisade team
    if palisade_teams:
        # Sort by flags first, then by rank
        best_palisade = sorted(
            palisade_teams.items(), key=lambda x: (x[1][0], -x[1][1]), reverse=True
        )[0]
        team_data["[AI] Palisade (best)"] = best_palisade[1]

    # Sort teams by flags first, then by rank (lower rank is better)
    sorted_teams = sorted(
        team_data.items(), key=lambda x: (x[1][0], -x[1][1]), reverse=True
    )

    # Extract just the team names and flag counts for visualization
    sorted_team_names = [team for team, _ in sorted_teams]
    sorted_flag_counts = [data[0] for _, data in sorted_teams]

    # Create visualization with minimal spacing between bars
    fig, ax = plt.subplots(figsize=(30, max(20, len(sorted_teams) * 0.3)))

    # Define colors
    ai_color = "#FF5555"  # Red
    human_color = "#5555FF"  # Blue
    bar_height = 0.1  # Make bars thinner

    # Draw rectangles for each team with minimal spacing
    # Reverse the order of teams so highest score is at the top
    for i, (team, score) in enumerate(
        zip(reversed(sorted_team_names), reversed(sorted_flag_counts), strict=False)
    ):
        is_ai = team.startswith("[AI]")
        color = ai_color if is_ai else human_color

        # Draw rectangle
        ax.barh(i * 0.2, score, color=color, alpha=0.7, height=bar_height)

    # Set y-ticks and labels
    ax.set_yticks(range(len(sorted_teams)))
    ax.set_yticklabels([""] * len(sorted_teams))

    # Set x-ticks with interval of 2
    max_score = max(sorted_flag_counts)
    x_ticks = np.arange(0, max_score + 2, 2)  # +2 to ensure we include the max score
    ax.set_xticks(x_ticks)
    ax.set_xlim(0, max_score + 1)  # Add some padding to the right

    # Reduce spacing between bars to absolute minimum
    ax.margins(y=0.0001)  # Minimal vertical margin

    # Remove all padding
    plt.subplots_adjust(left=0.05, right=0.95, top=0.95, bottom=0.05)

    # Add legend with larger font in bottom right
    ai_patch = plt.Rectangle((0, 0), 1, 1, color=ai_color, alpha=0.7)
    human_patch = plt.Rectangle((0, 0), 1, 1, color=human_color, alpha=0.7)
    ax.legend(
        [ai_patch, human_patch],
        ["AI Teams", "Human Teams"],
        loc="lower right",  # Changed to lower right
        fontsize=default_font_size,
    )

    # Set labels and title with larger font
    ax.set_xlabel("Number of Flags Captured", fontsize=default_font_size)
    ax.set_title("CTF Leaderboard: AI vs Human Teams", fontsize=default_font_size * 1.2)
    ax.grid(axis="x", linestyle="--", alpha=0.3)

    # Increase tick label size
    ax.tick_params(axis="both", which="major", labelsize=default_font_size * 0.8)

    # Adjust layout and display
    plt.tight_layout()
    plt.show()


create_leaderboard_visualization()

# %%
