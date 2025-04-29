# %%
import uuid

import pandas as pd


def anonymize_usernames(file_path: str):
    # replace username with a random string unique for each username
    df = pd.read_csv(file_path)
    username_to_random_id = {
        username: uuid.uuid4() for username in df["user_name"].unique()
    }
    df["user_name"] = df["user_name"].map(username_to_random_id)
    df.to_csv(file_path, index=False)


anonymize_usernames("AI vs Humans CTF - Owns .csv")
anonymize_usernames("CA challenge interactions - CA owns.csv")
