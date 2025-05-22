# %%
import json

from loguru import logger

from data import challenge_data, participants_data

# Create standings list for all teams
standings = []
pos = 1

# Get all teams that found at least 1 flag
all_teams = [team for team in participants_data["team_name"]]

# Sort teams by number of flags
all_teams.sort(
    key=lambda team: len(
        challenge_data[
            (challenge_data["team_name"] == team)
            & (challenge_data["interaction_type"] == "flag owned")
        ]
    ),
    reverse=True,
)

# Add all teams to standings
for team in all_teams:
    team_flags = len(
        challenge_data[
            (challenge_data["team_name"] == team)
            & (challenge_data["interaction_type"] == "flag owned")
        ]
    )
    standings.append({"pos": pos, "team": team, "score": team_flags})
    pos += 1

# Create final JSON structure
rankings_json = {"standings": standings}

save_path = "../data/ctftime_rankings.json"
with open(save_path, "w") as f:
    json.dump(rankings_json, f)

logger.info(f"Rankings saved to {save_path}")

# %%
