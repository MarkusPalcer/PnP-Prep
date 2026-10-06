# Testing Concept for Card Unit Tests

This document is the shared guide for the unit tests of the card class.

For the full version, see [../../../doc/Testing.md](../../../doc/Testing.md).

The key rules are:

- Fixtures live under `test/unit/pnpprep/pnpcards/`
- a fixture is a single `.tex` file with a clear purpose
- a short `% Expected Output` section appears at the end of each file
- successful tests are reviewed visually against the expected output
- expected compilation errors are checked separately in the log
- the full run is performed via `make test`
- each feature ticket has its own fixtures and expected outputs

The complete written guidance with examples and the future section can be found in [../../../doc/Testing.md](../../../doc/Testing.md).
