# PnP-Prep

LaTeX classes and packages for Pen-and-Paper preparation.

## Getting Ready to Code

The recommended development environment is the included VS Code Dev Container.
Before opening it, make sure the LatexTesting repository is checked out at
`gems/latextesting/`; the root `Gemfile` discovers and evaluates Gemfiles under
`gems/*/`.

You need Git, Docker (or a compatible container runtime), Visual Studio Code,
and the **Dev Containers** extension. Open this repository in VS Code and run
**Dev Containers: Reopen in Container**. The container installs the LaTeX and
Ruby toolchains, configures the workspace extensions, and runs
`sudo bundle install` after creation to install the root bundle and local gem
dependencies.

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
