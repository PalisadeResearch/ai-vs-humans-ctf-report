# %%
from loguru import logger

from src.data import ca_AI_interactions_data, ca_challenges_data

# %%
CAI_interactions_data = ca_AI_interactions_data[
    ca_AI_interactions_data["team_name"] == "[AI] CAI"
]
CAI_interactions_data["challenge_interaction_type"].unique()
# %%

ca_ai_team_names = list(ca_AI_interactions_data["team_name"].unique())


def count_solves_per_category(interactions_data, challenges_data, team_name):
    solves = {
        category: {"total": 0, "solved": 0}
        for category in challenges_data["category"].unique()
    }
    for _, row in interactions_data[
        (interactions_data["challenge_interaction_type"] == "challenge solved")
        & (interactions_data["team_name"] == team_name)
    ].iterrows():
        solves[row["category_name"]]["solved"] += 1

    for _, row in challenges_data.iterrows():
        solves[row["category"]]["total"] += 1

    return solves


def count_solves_per_difficulty(interactions_data, challenges_data, team_name):
    solves = {
        difficulty: {"total": 0, "solved": 0}
        for difficulty in challenges_data["difficulty"].unique()
    }
    challenge_name_to_difficulty = dict(
        zip(challenges_data["name"], challenges_data["difficulty"], strict=False)
    )

    for _, row in interactions_data[
        (interactions_data["challenge_interaction_type"] == "challenge solved")
        & (interactions_data["team_name"] == team_name)
    ].iterrows():
        solves[challenge_name_to_difficulty[row["challenge_name"]]]["solved"] += 1

    for _, row in challenges_data.iterrows():
        solves[row["difficulty"]]["total"] += 1

    return solves


def count_solves_per_has_docker(interactions_data, challenges_data, team_name):
    solves = {
        "has_docker": {
            "total": len(challenges_data[challenges_data["has_docker"] == True]),  # noqa: E712
            "solved": 0,
        },
        "no_docker": {
            "total": len(challenges_data[challenges_data["has_docker"] == False]),  # noqa: E712
            "solved": 0,
        },
    }
    challenge_name_to_has_docker = dict(
        zip(challenges_data["name"], challenges_data["has_docker"], strict=False)
    )
    challenge_name_to_has_docker = {
        k: "has_docker" if v else "no_docker"
        for k, v in challenge_name_to_has_docker.items()
    }

    for _, row in interactions_data[
        (interactions_data["challenge_interaction_type"] == "challenge solved")
        & (interactions_data["team_name"] == team_name)
    ].iterrows():
        solves[challenge_name_to_has_docker[row["challenge_name"]]]["solved"] += 1

    return solves


def count_tasks_per_category_and_difficulty(
    interactions_data, challenges_data, team_name
):
    solves = {
        category: {
            difficulty: {"total": 0, "solved": 0}
            for difficulty in challenges_data[challenges_data["category"] == category][
                "difficulty"
            ].unique()
        }
        for category in challenges_data["category"].unique()
    }
    challenge_name_to_difficulty = dict(
        zip(challenges_data["name"], challenges_data["difficulty"], strict=False)
    )

    for _, row in interactions_data[
        (interactions_data["challenge_interaction_type"] == "challenge solved")
        & (interactions_data["team_name"] == team_name)
    ].iterrows():
        solves[row["category_name"]][
            challenge_name_to_difficulty[row["challenge_name"]]
        ]["solved"] += 1

    for _, row in challenges_data.iterrows():
        solves[row["category"]][row["difficulty"]]["total"] += 1

    return solves


def pretty_print_solves(solves: dict[str, dict[str, int]]):
    for category, data in solves.items():
        logger.info(f"{category:<20}: {data['solved']}/{data['total']}")


def pretty_print_tasks_per_category_and_difficulty(
    solves: dict[str, dict[str, dict[str, int]]],
):
    for category, difficulty_data in solves.items():
        logger.info(f"### {category}")
        for difficulty, data in difficulty_data.items():
            logger.info(f"{difficulty:<20}: {data['solved']}/{data['total']}")


# %%
for team in ca_AI_interactions_data["team_name"].unique():
    logger.info(team)
    pretty_print_solves(
        count_solves_per_category(ca_AI_interactions_data, ca_challenges_data, team)
    )

# %%
for team in ca_AI_interactions_data["team_name"].unique():
    logger.info(team)
    pretty_print_solves(
        count_solves_per_difficulty(ca_AI_interactions_data, ca_challenges_data, team)
    )

# %%
for team in ca_AI_interactions_data["team_name"].unique():
    logger.info(team)
    pretty_print_solves(
        count_solves_per_has_docker(ca_AI_interactions_data, ca_challenges_data, team)
    )

# %%
for team in ca_AI_interactions_data["team_name"].unique():
    logger.info(team)
    pretty_print_tasks_per_category_and_difficulty(
        count_tasks_per_category_and_difficulty(
            ca_AI_interactions_data, ca_challenges_data, team
        )
    )

# %%
