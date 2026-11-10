# Testing

This page is a short project overview. The detailed guides separate the
framework from repository-specific practices:

- [LaTeX Test Framework](../doc/testing-framework.md) explains the Ruby runner,
  test-definition DSL, assertions, and generated artifacts.
- [Repository Testing Practices](../doc/Testing.md) covers fixture design,
  expected output, negative tests, and visual review.

Run the registered tests from the repository root with:

```sh
rake test
```

Test definitions and LaTeX fixtures are kept together under `test/`, separated
into unit and integration test directories.

Custom assertions can use `pdf_path` to inspect the generated PDF while the
assertion runs. PDF geometry checks may rasterize pages with Ghostscript and
measure colored debug frames.

For temporary Ruby test experiments, add a `playground` task in
`rakelib/playground.rake`, run it through Rake, and delete the task when the
experiment is complete.
