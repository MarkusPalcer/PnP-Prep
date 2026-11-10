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
LatexTesting declares HexaPDF as a runtime dependency for PDF assertions.
Negative fixture tests declare their expected outcome with
`expect_compilation_failure`.

Run the registered tests from the repository root with:

```sh
rake test
```

Rake also defines `rake test:<suite>` for one suite and
`rake test:<suite>:<test>` for one test. Names are normalized for Rake and
disambiguated when normalization produces collisions.

The VS Code **Debug Tests** configuration runs the same task through Bundler
with `bundle exec rake test`.

Test definitions and LaTeX fixtures are kept together under `test/`, separated
into unit and integration test directories.

Visual expectations belong in the matching Ruby test definition as
`user_assert` calls, one fact per call, rather than as `% Expected Output`
comments in `.tex` fixtures. They are skipped by default and print the skipped
assertion count in yellow before `MANUAL TESTS SKIPPED`; use
`LatexTesting.run(user_interaction: true)` for a prompt with the persistent
output PDF path. Accept `yes`/`y` or `no`/`n`, case-insensitively. A yes
response prints `PASSED`; a no response fails. Even when skipped, a manual
assertion fails if the generated PDF is missing. PDF assertion helpers read the
persistent copied PDF, while log assertions continue to read the temporary
build log.

The root Rakefile enables those prompts for full, suite, and individual test
tasks whenever `MANUAL_TESTS` is present in the environment. For example,
`MANUAL_TESTS=1 rake test` runs the full suite interactively.

Every root test task also overwrites `out/testresults.xml` with JUnit XML for
the tests run by that invocation. Skipped manual assertions are counted as
passed in the report; suite and single-test tasks include only their selected
tests.

For temporary Ruby test experiments, add a `playground` task in
`rakelib/playground.rake`, run it through Rake, and delete the task when the
experiment is complete.
