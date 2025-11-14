# Evaluating AI Cyber Capabilities with Crowdsourced Elicitation

![50%-task-completion time horizon, Cyber Apocalypse (top 1% human teams)](paper-typst/plots/is_ai_solved_vs_median_human_time_regression_CyberApocalypse.svg)

*AI can solve challenges which require 1 hour of effort from the top human CTF participants*

---

This repository contains the source code and data for the paper "Evaluating AI Cyber Capabilities with Crowdsourced Elicitation" by Artem Petrov and Dmitrii Volkov. (preprint link: https://arxiv.org/abs/2505.19915)

You can find the raw data in the `data` folder. 

You can find the code for drawing figures in the `src` folder.

You can find the paper sources in the various `paper-<...>` folders. `paper-haips` is the latest edit.


## Abstract

As AI systems become increasingly capable, understanding their offensive cyber potential is critical for informed governance and responsible deployment. However, it's hard to accurately bound their capabilities, and some prior evaluations dramatically underestimated them. The art of extracting maximum task-specific performance from AIs is called "AI elicitation", and today's safety organizations typically conduct it in-house. In this paper, we explore crowdsourcing elicitation efforts as an alternative to in-house elicitation work.

We host open-access AI tracks at two Capture The Flag (CTF) competitions: AI vs. Humans (400 teams) and Cyber Apocalypse (8000 teams). The AI teams achieve outstanding performance at both events, ranking top-5% and top-10% respectively for a total of $7500 in bounties. This impressive performance suggests that open-market elicitation may offer an effective complement to in-house elicitation. We propose elicitation bounties as a practical mechanism for maintaining timely, cost-effective situational awareness of emerging AI capabilities.

Another advantage of open elicitations is the option to collect human performance data at scale. Applying METR's methodology, we found that AI agents can reliably solve cyber challenges requiring one hour or less of effort from a median human CTF participant. 

# Main Results

## AI vs. Humans CTF

The first event in our series was the _AI vs. Humans_ CTF, organized in collaboration with Hack The Box on 14-16 March 2025. This event was the first to publicly pit fully autonomous AI agents against experienced human teams in real-time, offering 20 cybersecurity challenges over 48 hours with a prize pool of $7500.

### Performance Summary

- **403 teams** registered for the event, of which **158 solved at least 1 challenge**: 152 human teams and 6 AI teams
- The **best AI team achieved top-5% performance** (top-13% among teams solving at least one challenge)
- **Four out of seven agents completed 19/20 challenges**
- AI teams performed on par with top multi-human teams in speed

### AI Team Standings

| Agent | Challenges Solved | Leaderboard Rank |
|-------|------------------|------------------|
| CAI | 19 / 20 | 20 |
| Palisade Claude Code | 19 / 20 | 21 |
| FCT | 19 / 20 | 30 |
| imperturbable | 19 / 20 | 33 |
| Cyagent | 18 / 20 | 34 |
| Project S1ngularity | 14 / 20 | 65 |
| Palisade React&Plan | 14 / 20 | 66 |

### Team Progression

![Challenges solved over time for all teams, AI vs. Humans CTF](paper-typst/plots/team_progression_AI_vs_Humans_CTF_aligned_top7_ai_top151_human.svg)

*Challenges solved over time for all teams, AI vs. Humans CTF*

![Challenges solved over time for top teams, AI vs. Humans CTF](paper-typst/plots/team_progression_AI_vs_Humans_CTF_aligned.svg)

*Challenges solved over time for top teams, AI vs. Humans CTF*

## Cyber Apocalypse CTF

On 21–26 March 2025 we hosted an AI track at _Cyber Apocalypse_, an annual Hack The Box competition that attracts a large number of human participants and offers a diverse set of challenges.

### Performance Summary

- **8,129 human teams** (18,369 players) registered for the event, and **3,994 teams solved at least one challenge**
- The **best AI agent achieved top-10% performance** (top-21% among teams solving at least one challenge)
- AI can solve challenges requiring **~1 hour of effort from a median CTF participant** (50%-task-completion time horizon)

### AI Team Standings

| Agent | Challenges Solved | Leaderboard Rank |
|-------|------------------|------------------|
| CAI | 20 / 62 | 859 |
| Palisade Claude Code | 5 / 62 | 2496 |
| Palisade Aider | 3 / 62 | 2953 |
| Palisade React&Plan | 2 / 62 | 3199 |


### Team Progression

![Challenges solved over time for top teams, Cyber Apocalypse CTF](paper-typst/plots/team_progression_CyberApocalypse_aligned.svg)

*Challenges solved over time for top teams, Cyber Apocalypse CTF*

## Key Findings

1. **Crowdsourcing elicitation works**: Top AI teams' performance exceeded our in-house efforts, with AIs saturating the _AI vs. Humans_ CTF for a prize pool of only $7500.

2. **Policy-relevant grounding**: Hosting head-to-head competitions with human teams provides a more interpretable and policy-relevant signal than traditional benchmark scores. In _Cyber Apocalypse_, the best AI outperforms 90% of humans.

3. **Time horizon metric**: Applying METR's methodology, we found that AI agents can reliably solve cyber challenges requiring one hour or less of effort from a median human CTF participant.

![50%-task-completion time horizon, Cyber Apocalypse (top 1% human teams)](paper-typst/plots/is_ai_solved_vs_median_human_time_regression_CyberApocalypse.svg)

*50%-task-completion time horizon, Cyber Apocalypse (top 1% human teams)*

4. **Speed advantage**: AI teams performed on par with top multi-human teams in terms of solving speed, demonstrating one of the core advantages AIs typically hold over humans.



## Development

### System setup

To set up your system for the first time, run:

```bash
# Pull the images from git lfs
git lfs pull
# Setup Nix
sh <(curl -L https://nixos.org/nix/install) --daemon
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
exit # the commands below need a fresh shell

# Install direnv
nix profile install nixpkgs#direnv nixpkgs#nix-direnv
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
echo 'source $HOME/.nix-profile/share/nix-direnv/direnvrc' >> ~/.config/direnv/direnvrc

# Install pre-commit
nix profile install nixpkgs#pre-commit
```

### Project setup

After cloning the repository, run:

```bash
# allow loading environment from flake.nix, pyproject.toml, and .env
direnv allow
# install linting and formatting hooks
pre-commit install && pre-commit run
```

### Daily workflow

Use Cursor to edit code. It will suggest extensions to install when you open the project.

```bash
cd template # automatically loads environment
ninja # builds figures and the paper
git commit # checks format and lints
```

### Files to know

- `flake.nix` defines system dependencies like `texlive`
- `pyproject.toml` defines Python dependencies like `matplotlib`
- `build.ninja` defines build targets like `paper` and `figures`
