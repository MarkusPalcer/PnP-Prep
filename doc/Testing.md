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

The runner discovers Ruby definition files under `test/`, compiles each
fixture's LaTeX source with `latexmk` once, and writes generated PDFs and
failure logs under `out/test/`. Set `RAKE_VERBOSE=1` to show compiler output:

```sh
RAKE_VERBOSE=1 rake test
```

Set `MANUAL_TESTS` to enable interactive `manual_test` prompts. This applies
to the full test run, individual fixture tasks, and individual test tasks:

```sh
MANUAL_TESTS=1 rake test
```

Every root test task writes a JUnit XML report to `out/testresults.xml`,
overwriting the previous report. Fixture and individual-test tasks include
only the tests they execute; skipped manual tests count as passed in the XML.

The runner prints a result for each test. All root `rake test` tasks exit with
status 1 if any selected test fails; successful PDFs are useful for visual
review and are not compared automatically against expected output.

Use `rake clean` to remove generated build artifacts.

## Test Organization

Keep test definitions beside the `.tex` fixtures they use. Definition files
declare named fixtures and their tests; files do not create suite or
file-level test groups:

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

Fixture names must be unique across all definition files. Each fixture should
select one `.tex` file, whose output is compiled once. Test names must be
unique within that fixture. Each named test should check one fact about that
output.

## Fixture Expectations

For output that needs visual review, add `manual_test` declarations to the
fixture, one expected fact per test. Describe meaningful pages, text, layout,
and blank areas so a reviewer can compare the generated PDF with the intended
result. Keep these expectations out of the `.tex` fixture.

Compilation success alone does not establish that the rendered layout is
correct. By default, manual tests are skipped. To review them while running,
call `LatexTesting.run(user_interaction: true)`; the runner displays each fact
and the persistent PDF path, then accepts `yes`/`y` or `no`/`n` (`PASSED` on
yes). Even when skipped, a manual test fails if the generated PDF is missing.
Keep the fixture self-contained and use only the setup needed for the
scenario.

## Expected Compilation Failures

Use `expect_compilation_failure` on a fixture expected to fail compilation.
Define one or more `requires_log` tests or custom `test` blocks to assert the
expected diagnostic; otherwise, an unrelated compilation failure could
satisfy the fixture-level expectation.

Keep the expected message specific enough to distinguish the intended failure.
LaTeX may wrap messages across lines, so use multiple substring checks when
that makes the expectation more robust.

## Choosing Tests

Use `requires_log` for a straightforward substring check. Use a named `test`
block when the check needs custom logic or a clearer failure message. Tests
run after the fixture's expected build outcome, including when compilation
failure was expected. Their execution context provides the cached build `log`
and `fail(message)`. A failed test does not stop later tests in the fixture.

Configure the fixture with `file` before adding tests so the runner can
associate them with the correct build.

## Output and Troubleshooting

- Successful compilations produce one PDF per fixture under `out/test/`.
- Failed compilations save a `.log` file in the corresponding fixture output
  directory. Build failures mark the fixture's selected tests failed;
  individual test failures are reported separately.
- Use `RAKE_VERBOSE=1 rake test` to see `latexmk` output while diagnosing a
  build.
- Check that the selected fixture path is relative to its `tests.rb` file.
