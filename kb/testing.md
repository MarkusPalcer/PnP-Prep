# Testing

This page is a short project overview. Detailed instructions are maintained
alongside the code they describe:

- [LatexTesting documentation](../gems/latextesting/doc/README.md) separates
  black-box user guides from implementation-focused developer guides.
- [LatexTesting integration](../doc/latextesting-integration.md) describes how
  the main repository loads and runs the local gem.
- [Repository Testing Practices](../doc/Testing.md) covers fixture design,
  expected output, negative tests, and visual review.

The LatexTesting repository must be checked out at `gems/latextesting/`.
The root `Gemfile` evaluates nested `gems/*/Gemfile` files.
LatexTesting declares HexaPDF as a runtime dependency for PDF tests.

Definition files declare fixtures; they are loader inputs, not test grouping
units. Fixture names are unique across all definition files, and each fixture
selects one `.tex` file to compile once. Each fixture contains uniquely named
tests that check individual facts. `test` defines an automated test,
`manual_test` defines a manual visual test, and `requires_log` adds a named
log-check test.

Negative fixture tests declare their expected outcome with
`expect_compilation_failure`. A fixture-level build failure or unexpected
build result fails its selected tests; one failed test does not prevent later
tests from running.

Run registered tests from the repository root with:

```sh
rake test
```

Rake also defines `rake test:<fixture>` and
`rake test:<fixture>:<test>` tasks. Names are normalized for Rake and
disambiguated when normalization produces collisions.

The VS Code **Debug Tests** configuration runs the same task through Bundler
with `bundle exec rake test`.

Test definitions and LaTeX fixtures are kept together under `test/`,
separated into unit and integration test directories.

Visual expectations that require human inspection belong in the matching Ruby
fixture definition as `manual_test` calls, one fact per call, rather than as
`% Expected Output` comments in `.tex` fixtures. Prefer automated tests for
objective PDF facts that the available PDF, vector-content, or raster checks
can verify. Manual tests are skipped by default; use
`LatexTesting.run(user_interaction: true)` or `MANUAL_TESTS=1 rake test` for a
prompt with the persistent output PDF path. Accept `yes`/`y` or `no`/`n`,
case-insensitively. A yes response prints `PASSED`; a no response fails. Even
when skipped, a manual test fails if the generated PDF is missing.

PDF test helpers read the persistent copied PDF, while log tests continue to
read the temporary build log. Each root test task overwrites
`out/testresults.xml` with JUnit XML; fixture and individual-test tasks include
only selected tests. Skipped manual tests count as passed in the report.
Root test tasks exit with status 1 if any selected test fails.

Successful PDFs are stored beside the fixture-specific output directory and
named after the fixture, for example
`out/test/unit/pnpprep/pnpcards/tests/A6 Geometry.pdf`. Failure logs are stored
beside the PDF with the same fixture name and a `.log` extension.

For temporary Ruby test experiments, add a `playground` task in
`rakelib/playground.rake`, run it through Rake, and delete the task when the
experiment is complete.
