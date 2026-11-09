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
