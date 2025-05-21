from loguru import logger
from src.data import Event, ai_vs_hum_event, ca_event


# %%
def count_teams_with_flags(event: Event):
    return len(
        [
            team
            for team in event.teams_data.values()
            if any(
                [
                    challenge_interaction.first_challenge_solved is not None
                    for challenge_interaction in team.challenge_interactions.values()
                ]
            )
        ]
    )


logger.info(f"Teams with flags in AI vs Humans CTF: {count_teams_with_flags(ai_vs_hum_event)}")
logger.info(f"Teams with flags in CyberApocalypse: {count_teams_with_flags(ca_event)}")
# %%


# %%
