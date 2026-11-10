# LatexTesting in PnP-Prep

This page describes how the main PnP-Prep repository integrates the
[`latextesting` gem](../gems/latextesting). For its fixture/test DSL, see the
[LatexTesting documentation](../gems/latextesting/doc/README.md). For fixture
design and visual review, see [Testing](Testing.md).

## Local Gem Prerequisite

The LatexTesting repository must be present at `gems/latextesting/` in the
PnP-Prep checkout. The root `Gemfile` evaluates every `gems/*/Gemfile`, which
includes the gem and its development dependencies. After checking out the gem,
run `bundle install` from the PnP-Prep root.

The root `Rakefile` requires the gem directly. It uses `LatexTesting.scan` to
create `rake test:<fixture>` and `rake test:<fixture>:<test>` tasks, while
`rake test` runs all registered tests. Task-name characters are normalized,
and colliding normalized names receive numeric suffixes.

## Running Repository Tests

Run the test task from the PnP-Prep root:

```sh
rake test
```

The runner scans `test/` for Ruby files named `*tests.rb`, `*test.rb`,
`test.rb`, or `tests.rb`, then evaluates them as fixture definitions. The main
repository provides `build_raw` from `rakelib/basic.rake`; LatexTesting uses it
to compile each fixture's selected LaTeX source with `latexmk` once.

Set `RAKE_VERBOSE=1` to show compiler output:

```sh
RAKE_VERBOSE=1 rake test
```

Set `MANUAL_TESTS` to enable interactive `manual_test` prompts for `rake test`
and its fixture/test tasks:

```sh
MANUAL_TESTS=1 rake test
```

All root test tasks write JUnit XML results to `out/testresults.xml`,
replacing the file on each invocation. A full run includes the full test set,
while fixture and individual-test tasks report only tests selected by that
task. Skipped manual tests count as passed in the report.

Each fixture is compiled in a temporary directory. Its successful PDF and
failed build log are copied under `out/test/`, preserving the definition-file
structure. Temporary build files are removed afterward. A fixture-level build
failure or unexpected result fails its selected tests; an individual test
failure does not stop later tests in that fixture.

The runner prints `PASS`, `PASSED`, `FAIL`, or `MANUAL TEST SKIPPED` per test.
All root `rake test` tasks exit with status 1 if any selected test fails.
