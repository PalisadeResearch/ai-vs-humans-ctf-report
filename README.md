# Evaluating AI Cyber Capabilities with Crowdsourced Elicitation

This repository contains the source code and data for the paper "Evaluating AI Cyber Capabilities with Crowdsourced Elicitation" by Artem Petrov and Dmitrii Volkov. (preprint link: https://arxiv.org/abs/2505.19915)

You can find the raw data in the `data` folder. 

You can find the code for drawing figures in the `src` folder.

You can find the paper sources in the various `paper-<...>` folders. `paper-haips` is the latest edit.

## Abstract

As AI systems become increasingly capable, understanding their offensive cyber potential is critical for informed governance and responsible deployment. However, it's hard to accurately bound their capabilities, and some prior evaluations dramatically underestimated them. The art of extracting maximum task-specific performance from AIs is called "AI elicitation", and today's safety organizations typically conduct it in-house. In this paper, we explore crowdsourcing elicitation efforts as an alternative to in-house elicitation work.

We host open-access AI tracks at two Capture The Flag (CTF) competitions: AI vs. Humans (400 teams) and Cyber Apocalypse (8000 teams). The AI teams achieve outstanding performance at both events, ranking top-5% and top-10% respectively for a total of $7500 in bounties. This impressive performance suggests that open-market elicitation may offer an effective complement to in-house elicitation. We propose elicitation bounties as a practical mechanism for maintaining timely, cost-effective situational awareness of emerging AI capabilities.

Another advantage of open elicitations is the option to collect human performance data at scale. Applying METR's methodology, we found that AI agents can reliably solve cyber challenges requiring one hour or less of effort from a median human CTF participant. 

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
