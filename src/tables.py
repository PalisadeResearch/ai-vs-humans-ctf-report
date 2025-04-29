# %%
import pandas as pd

from src.data import Event, ai_vs_hum_event, ca_event, repo_root

# %%


def get_ai_team_standings(event: Event, min_solves=0):
    teams = [
        event.teams_data[team]
        for team in event.ai_team_names
        if event.teams_data[team].total_solves >= min_solves
    ]
    teams.sort(key=lambda x: x.leaderboard_rank)
    df = pd.DataFrame(
        {
            "team_name": [team.name.replace("[AI] ", "") for team in teams],
            "total_solves": [
                f"{team.total_solves} / {len(event.challenges_data)}" for team in teams
            ],
            "leaderboard_rank": [team.leaderboard_rank for team in teams],
        }
    )
    df.loc[df["team_name"] == "Palisade R&P OA", "team_name"] = "Palisade React&Plan"
    df.to_csv(
        repo_root
        / f"paper-typst/tables/ai_team_standings_{event.event_name_no_spaces}.csv",
        index=False,
    )
    return df


# min_solves=5 is needed to cut out attempts failed by Palisade due to low effort
get_ai_team_standings(ai_vs_hum_event, min_solves=5)

get_ai_team_standings(ca_event, min_solves=1)
# %%
