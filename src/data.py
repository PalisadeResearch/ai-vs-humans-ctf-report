# %%
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import override

import pandas as pd
from loguru import logger

repo_root = Path(__file__).parent.parent

# AI vs Humans CTF event data
EVENT_START = pd.to_datetime("2025-03-14 15:00:00", utc=True)
interactions_data = pd.read_csv(
    repo_root / "data/AI vs Humans CTF - Challenge Interactions.csv"
)
rank_data = pd.read_csv(repo_root / "data/AI vs Humans CTF - Participants.csv")
rank_data = rank_data.drop(
    rank_data[
        (rank_data["team_name"] == "[AI] imperturbable") & (rank_data["rank"] == 379)
    ].index  # There is a duplicate entry for this team in the leaderboard
    # Probably because they manually registered the same team name
    # in addition to api-based team entry
)
# We confirmed over email that this team had 5 players competing
# with only 3 managing to register:
rank_data.loc[rank_data["team_name"] == "Heroes Cyber Security", "total_players"] = 5
user_owns_data = pd.read_csv(repo_root / "data/AI vs Humans CTF - Owns .csv")
challenges_data = pd.read_json(repo_root / "data/ic_ctf_clean.json")

# CyberApocalypse event data
CA_EVENT_START = pd.to_datetime("2025-03-21 13:00:00", utc=True)
ca_AI_interactions_data = pd.read_csv(
    repo_root / "data/CA AI teams interactions - CA - AI teams interactions (1).csv"
)
ca_interactions_data = pd.read_csv(
    repo_root
    / "data/CA challenge interactions - CA challenge interactions - all teams .csv"
).rename(columns={"challenge_interaction_type": "interaction_type"})
ca_rank_data = pd.read_csv(
    repo_root / "data/CA challenge interactions - CA rank - all teams.csv"
).rename(columns={"name": "team_name", "participation_count": "total_players"})
ca_user_owns_data = pd.read_csv(
    repo_root / "data/CA challenge interactions - CA owns.csv"
)
ca_challenges_data = pd.read_json(repo_root / "data/cyberapocalypse_ic_ctf_clean.json")


def rename_team(df: pd.DataFrame, old_name: str, new_name: str):
    df.loc[df["team_name"] == old_name, "team_name"] = new_name


def drop_team(df: pd.DataFrame, team_name: str):
    df.drop(df[df["team_name"] == team_name].index, inplace=True)


# We messed up the team name for the Aider team during the CA event:
for _df in [ca_rank_data, ca_interactions_data, ca_user_owns_data]:
    drop_team(_df, "[AI] Palisade Aider")
    rename_team(_df, "[AI] Palisade Research", "[AI] Palisade Aider")

# %%


@dataclass
class TeamChallengeInteraction:
    team_name: str
    challenge_name: str
    first_file_access: datetime | None = None
    first_docker_spawn: datetime | None = None
    first_challenge_solved: datetime | None = None
    user_who_solved_challenge: str | None = None

    def get_solve_time(self) -> float | None:
        if self.first_challenge_solved is None:
            return None
        if self.first_docker_spawn is None and self.first_file_access is None:
            # logger.info(
            #     f"Team {self.team_name} solved the challenge {self.challenge_name} "
            #     "but didn't spawn a docker container or download any files"
            # )
            return 0
        if self.first_docker_spawn is None:
            return (
                self.first_challenge_solved - self.first_file_access
            ).total_seconds()
        if self.first_file_access is None:
            return (
                self.first_challenge_solved - self.first_docker_spawn
            ).total_seconds()
        return (
            self.first_challenge_solved
            - min(self.first_file_access, self.first_docker_spawn)
        ).total_seconds()


@dataclass
class Team:
    name: str
    # solves_timestamps_sequence: list[datetime] | None = None
    # score_sequence: tuple[list[int], list[int]] | None = None
    challenge_interactions: dict[str, TeamChallengeInteraction]
    number_of_players: int
    leaderboard_rank: int | None = None
    total_solves: int = 0


@dataclass
class Event:
    interactions_data: pd.DataFrame
    rank_data: pd.DataFrame
    challenges_data: pd.DataFrame
    user_owns_data: pd.DataFrame

    event_start: datetime
    event_name: str

    humans_top_n: int = 10
    ai_top_n: int = 3

    def __post_init__(self):
        # Remove duplicate rows
        self.interactions_data = self.interactions_data.copy().drop_duplicates(
            subset=["team_name", "challenge_name", "interaction_type"], keep="first"
        )
        self.interactions_data["created_at"] = pd.to_datetime(
            self.interactions_data["created_at"], utc=True
        )

        self._init_AI_teams()
        self._init_human_teams()
        self._init_teams_data()

    def _init_AI_teams(self):
        # Filter AI teams directly and sort deterministically
        ai_teams_df = self.rank_data[
            self.rank_data["team_name"].str.startswith("[AI]")
            & (self.rank_data["team_name"] != "[AI] Palisade Ensemble")
        ].sort_values(by="team_name")  # Sort by name for deterministic ordering

        self.ai_team_names = ai_teams_df["team_name"].tolist()

        self.top_ai_teams = ai_teams_df.sort_values(
            by=["rank", "team_name"], ascending=True
        )[: self.ai_top_n]["team_name"].tolist()

    def _init_human_teams(self):
        self.human_team_names = (
            self.rank_data[~self.rank_data["team_name"].str.startswith("[AI]")]
            .sort_values(by=["rank", "team_name"], ascending=True)["team_name"]
            .tolist()
        )
        self.top_human_teams = self.human_team_names[: self.humans_top_n]

    def _init_teams_data(self):
        # self.teams_data = {
        #     team_name: Team(
        #         name=team_name,
        #         solves_timestamps_sequence=self.get_team_flags_sequence(team_name),
        #         score_sequence=self.get_team_score_progression(team_name),
        #     )
        #     for team_name in self.rank_data["team_name"]
        # }

        self.teams_data = {
            row["team_name"]: Team(
                name=row["team_name"],
                challenge_interactions={
                    challenge_name: TeamChallengeInteraction(
                        team_name=row["team_name"],
                        challenge_name=challenge_name,
                    )
                    for challenge_name in self.challenges_data["name"]
                },
                number_of_players=row["total_players"],
            )
            for _, row in self.rank_data.iterrows()
        }

        for _, row in self.interactions_data.iterrows():
            if row["team_name"] not in self.teams_data:
                # We have some interactions from teams that were
                # removed from the leaderboard
                # TODO: investigate why exactly a team can be removed
                # from the leaderboard
                continue
            team_name = row["team_name"]
            challenge_name = row["challenge_name"]
            if row["interaction_type"] == "challenge solved":
                self.teams_data[team_name].challenge_interactions[
                    challenge_name
                ].first_challenge_solved = row["created_at"]
                self.teams_data[team_name].total_solves += 1
            elif row["interaction_type"] == "files downloaded":
                self.teams_data[team_name].challenge_interactions[
                    challenge_name
                ].first_file_access = row["created_at"]
            elif row["interaction_type"] == "docker spawned":
                self.teams_data[team_name].challenge_interactions[
                    challenge_name
                ].first_docker_spawn = row["created_at"]

        for _, row in self.user_owns_data.iterrows():
            if row["team_name"] not in self.teams_data:
                # We have some interactions from teams that were
                # removed from the leaderboard
                # TODO: investigate why exactly a team can be removed
                # from the leaderboard
                continue
            self.teams_data[row["team_name"]].challenge_interactions[
                row["challenge_name"]
            ].user_who_solved_challenge = row["user_name"]

        for _, row in self.rank_data.iterrows():
            # if row["team_name"] not in self.teams_data:
            #     continue
            self.teams_data[row["team_name"]].leaderboard_rank = row["rank"]

    # def get_team_flags_sequence(self, team_name: str):
    #     return self.interactions_data[
    #         (self.interactions_data["team_name"] == team_name)
    #         & (self.interactions_data["interaction_type"] == "challenge solved")
    #     ].sort_values(by="created_at")

    # def get_team_score_progression(
    #     self,
    #     team_name: str,
    #     aligned=False,
    # ):
    #     team_flags = self.get_team_flags_sequence(team_name)

    #     solve_times = team_flags["created_at"].tolist()

    #     # Choose reference time based on alignment mode
    #     reference_time = solve_times[0] if aligned else self.event_start

    #     # Calculate times relative to reference
    #     times = [(t - reference_time).total_seconds() for t in solve_times]
    #     scores = range(1, len(team_flags) + 1)

    #     return times, scores

    @property
    def event_name_no_spaces(self):
        return self.event_name.replace(" ", "_")


class AIvsHumansEvent(Event):
    @override
    def _init_human_teams(self):
        # These guys look like flag hoarders, so they mess up the plots
        bad_teams = ["La Plateforme_"]

        self.human_team_names = (
            self.rank_data[
                ~self.rank_data["team_name"].str.startswith("[AI]")
                & ~self.rank_data["team_name"].isin(bad_teams)
            ]
            .sort_values(by=["rank", "team_name"], ascending=True)["team_name"]
            .tolist()
        )
        self.top_human_teams = self.human_team_names[: self.humans_top_n]


ai_vs_hum_event = AIvsHumansEvent(
    interactions_data=interactions_data,
    rank_data=rank_data,
    challenges_data=challenges_data,
    user_owns_data=user_owns_data,
    event_start=EVENT_START,
    event_name="AI vs Humans CTF",
)
ca_event = Event(
    interactions_data=ca_interactions_data,
    rank_data=ca_rank_data,
    challenges_data=ca_challenges_data,
    user_owns_data=ca_user_owns_data,
    event_start=CA_EVENT_START,
    ai_top_n=2,
    event_name="CyberApocalypse",
)

interactions_data = ai_vs_hum_event.interactions_data
ca_interactions_data = ca_event.interactions_data
AI_team_names = ai_vs_hum_event.ai_team_names
top_AI_teams = ai_vs_hum_event.top_ai_teams
top_human_teams = ai_vs_hum_event.top_human_teams
ca_AI_team_names = ca_event.ai_team_names
ca_top_AI_teams = ca_event.top_ai_teams
ca_top_human_teams = ca_event.top_human_teams


logger.info(f"Top AI teams: {top_AI_teams}")
logger.info(f"Top human teams: {top_human_teams}")
logger.info(f"CA top AI teams: {ca_top_AI_teams}")
logger.info(f"CA top human teams: {ca_top_human_teams}")


# %%

# %%
interactions_data.head()
# %%
ca_interactions_data.head()
# %%
ca_interactions_data["interaction_type"].value_counts()
# %%
interactions_data["interaction_type"].value_counts()
# %%

# TODO: add data sanity checks
