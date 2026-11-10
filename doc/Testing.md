# Repository Testing Practices

This guide describes how to design, organize, and review tests for this
repository. For the Ruby test runner's API and test-definition syntax, see the
[LatexTesting documentation](../gems/latextesting/doc/README.md).
For its integration with the main repository, see
[LatexTesting in PnP-Prep](latextesting-integration.md).

## Running the Tests

Run all registered tests from the repository root:

```sh
rake test
```

The runner discovers Ruby test-definition files under `test/`, compiles their
LaTeX fixtures with `latexmk`, and writes generated PDFs and failure logs under
`out/test/`. Set `RAKE_VERBOSE=1` to show the compiler output:

```sh
RAKE_VERBOSE=1 rake test
```

Set `MANUAL_TESTS` to enable interactive `user_assert` prompts. This applies
to the full suite and the individual suite/test Rake tasks:

```sh
MANUAL_TESTS=1 rake test
```

Every root test task writes a JUnit XML report to `out/testresults.xml`,
overwriting the previous report. Suite and individual-test tasks include only
the tests they execute; skipped manual assertions count as passed in the XML.

The runner prints a result for each test. Review that output; the current Rake
task does not aggregate individual failures into its process exit status.
Successful PDFs are useful for visual review and are not compared automatically
against expected output.

Use `rake clean` to remove generated build artifacts.

## Test Organization

Keep test definitions beside the fixtures they use. The current structure
separates unit tests from integration tests:

```text
test/
├── unit/pnpprep/
│   ├── pnpcards/
│   │   ├── tests.rb
│   │   └── *.tex
│   └── pnp-blueprint/
│       ├── tests.rb
│       └── *.tex
└── integration/pnpprep/
    └── blueprint-panel/
        ├── tests.rb
        └── *.tex
```

Each `.tex` fixture should focus on one behavior or failure condition. Give it
a descriptive, unique filename and define its test in the directory's
`tests.rb` file.

## Fixture Expectations

For fixtures whose output needs visual review, add `user_assert` calls to the
matching test in `tests.rb`, with one expected fact per call. Describe
meaningful pages, text, layout, and blank areas so a reviewer can compare the
generated PDF with the intended result. Keep these expectations out of the
`.tex` fixture.

Compilation success alone does not establish that the rendered layout is
correct. By default, manual assertions are skipped and their count is printed
in yellow before `MANUAL TESTS SKIPPED`. To review them while running, call
`LatexTesting.run(user_interaction: true)`; the runner displays each fact and
the persistent PDF path, then accepts `yes`/`y` or `no`/`n` (`PASSED` on yes).
Even when skipped, a manual assertion fails if the generated PDF is missing.
Keep the fixture self-contained and use only the setup needed for the scenario.

## Expected Compilation Failures

Use `expect_compilation_failure` when a fixture is supposed to fail compilation. Also
assert the expected diagnostic with `requires_log` or a custom `assert` block;
otherwise, an unrelated compilation failure could satisfy the expectation.

Keep the expected message specific enough to distinguish the intended failure.
LaTeX may wrap messages across lines, so use multiple substring checks when
that makes the expectation more robust.

## Choosing Assertions

Use `requires_log` for a straightforward substring check. Use a named `assert`
block when the check needs custom logic or a clearer failure message. Assertions
run after the fixture's build, including when a compilation failure was
expected. Their execution context provides the cached build `log` and
`fail(message)`.

Configure the fixture with `file` before adding assertions so the runner can
associate the assertions with the correct build log.

## Output and Troubleshooting

- Successful compilations produce PDFs under `out/test/`.
- Failed compilations save a `.log` file in the corresponding test output
  directory. Assertion failures are reported in the test output.
- Use `RAKE_VERBOSE=1 rake test` to see `latexmk` output while diagnosing a
  build.
- Check that the selected fixture path is relative to its `tests.rb` file.
