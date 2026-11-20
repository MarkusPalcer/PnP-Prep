# PnP-Prep

LaTeX classes and packages for Pen-and-Paper preparation.

## Getting Ready to Code

The recommended development environment is the included VS Code Dev Container.
Clone this repository with its LatexTesting submodule:

```sh
git clone --recurse-submodules https://github.com/MarkusPalcer/PnP-Prep.git
```

For an existing checkout, initialize the submodule before opening the container:

```sh
git submodule update --init --recursive
```

The root `Gemfile` discovers and evaluates Gemfiles under `gems/*/`.

You need Git, Docker (or a compatible container runtime), Visual Studio Code,
and the **Dev Containers** extension. Open this repository in VS Code and run
**Dev Containers: Reopen in Container**. The container installs the LaTeX and
Ruby toolchains and GitHub CLI (`gh`), configures the workspace extensions, and runs
`sudo bundle install` after creation to install the root bundle and local gem
dependencies. Authenticate separately with `gh auth login` if needed.

### Persisting Junie CLI data

The Dev Container bind-mounts the host's `~/.junie` at
`/home/texlive/.junie`. Before rebuilding the existing container, stop Junie
but keep the container running, then copy its data to the host so the mount
does not hide it. From a host shell, identify the running container with
`docker ps`, replace `CONTAINER_ID` below with its ID, and run:

```sh
mkdir -m 700 ~/.junie && \
  docker cp CONTAINER_ID:/home/texlive/.junie/. ~/.junie/
```

The `mkdir` command assumes the host directory does not already exist. If it
does, back up and reconcile its contents rather than overwriting them. The
directory may contain credentials, settings, session history, and logs; keep it
private and never commit it. The fallback credential file is
`secure_credentials.json`; credentials stored in an operating-system keychain
are not included, so reauthentication may still be necessary. The Junie CLI
installation under `~/.local` is separate and may need to be reinstalled after
rebuilding the container.

## Common Tasks

Run the repository's LaTeX fixture tests:

```sh
bundle exec rake test
```

Build the LaTeX documentation:

```sh
bundle exec rake doc
```

For framework DSL details and its RSpec suite, see the
[LatexTesting documentation](gems/latextesting/doc/README.md).
For the main repository's framework integration, see
[LatexTesting in PnP-Prep](doc/latextesting-integration.md).
