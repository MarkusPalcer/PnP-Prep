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

The VS Code **Debug Tests** configuration runs the same task through Bundler
with `bundle exec rake test`.

Test definitions and LaTeX fixtures are kept together under `test/`, separated
into unit and integration test directories.

For temporary Ruby test experiments, add a `playground` task in
`rakelib/playground.rake`, run it through Rake, and delete the task when the
experiment is complete.
