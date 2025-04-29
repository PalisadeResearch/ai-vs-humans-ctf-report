# template

A template repository implementing Palisade's coding guide. Features:

- Nix + uv + direnv environment for development and CI
- Figures and the paper build in CI
- Lint and format pre-commit hooks
- VSCode settings and extensions

## Development

### System setup

To set up your system for the first time, run:

```bash
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
