# LatexTesting in PnP-Prep

This page describes how the main PnP-Prep repository integrates the
[`latextesting` gem](../gems/latextesting). For the gem's DSL and assertions,
see its [documentation contents](../gems/latextesting/doc/README.md).
For fixture design and visual review, see [Testing](Testing.md).

## Local Gem Prerequisite

The LatexTesting repository must be present at `gems/latextesting/` in the
PnP-Prep checkout. The root `Gemfile` evaluates every `gems/*/Gemfile`, which
includes the gem and its development dependencies. After checking out the gem,
run `bundle install` from the PnP-Prep root.

The root `Rakefile` requires the gem directly. It uses `LatexTesting.scan` to
create `rake test:<suite>` and `rake test:<suite>:<test>` tasks, while
`rake test` runs the full test set. Task-name characters are normalized, and
colliding normalized names receive numeric suffixes.

## Running Repository Tests

Run the test task from the PnP-Prep root:

```sh
rake test
```

The runner scans `test/` for Ruby files named `*tests.rb`, `*test.rb`,
`test.rb`, or `tests.rb`, then evaluates them as test definitions. The main
repository provides `build_raw` from `rakelib/basic.rake`; LatexTesting uses it
to compile each selected LaTeX fixture with `latexmk`.

Set `RAKE_VERBOSE=1` to show compiler output:

```sh
RAKE_VERBOSE=1 rake test
```

Set `MANUAL_TESTS` to enable interactive `user_assert` prompts for `rake test`
and its suite/test tasks:

```sh
MANUAL_TESTS=1 rake test
```

Each fixture is compiled in a temporary directory. Successful PDFs and failed
build logs are copied under `out/test/`, preserving the test-definition
directory structure. Temporary build files are removed afterward.

The runner prints `PASS`, `PASSED`, `FAIL`, or the yellow
`<count> MANUAL TESTS SKIPPED` per test. The root Rake task does not collect
individual failures into an aggregate process exit status.
