# LaTeX Test Framework

This guide documents the Ruby test framework implemented in
[`rakelib/test.rake`](../rakelib/test.rake). It covers how to define test suites,
compile LaTeX fixtures, and assert on build logs. For repository test design
and visual-review practices, see [Testing](Testing.md).

## Running Tests

The root `Rakefile` defines the `test` task:

```sh
rake test
```

It scans `test/` for Ruby files named `*tests.rb`, `*test.rb`, `test.rb`, or
`tests.rb`, loads each definition, and runs its tests. The task uses
`latexmk` through `build_raw` from `rakelib/basic.rake`. Set `RAKE_VERBOSE=1`
to show compiler output:

```sh
RAKE_VERBOSE=1 rake test
```

Each fixture is compiled into a temporary directory. A successful build's PDF
is copied under `out/test/`, preserving the test-definition directory
structure. A failed build's log is saved in the corresponding output directory.
The temporary build directory is removed after the test, so inspect logs or
PDFs in `out/`.

The runner prints `PASS` or `FAIL` per test. The current task does not collect
these results into an aggregate process exit status.

## Defining Tests

Each test-definition file is evaluated as a DSL context. Named suites organize
related tests:

```ruby
testsuite "Blueprint unit tests" do
  test "Basic blueprint" do
    file "01-basic.tex"
  end
end
```

Within a `testsuite` block, `test` creates a test. A test-definition file can also call `test` directly;
those tests are placed in an implicit file-level suite.

The fixture path passed to `file` is relative to the directory containing the
Ruby test-definition file. Set it before declaring assertions.

## Test DSL

### `file filename`

Selects the `.tex` fixture to compile. A test must select a fixture; otherwise
it fails with `no .tex file given`. The file must exist relative to the
definition file's directory.

### `expect_failure`

Marks a failed LaTeX build as the expected outcome. If the build succeeds, the
test fails. This only checks whether the build failed; pair it with a log
assertion to verify the intended reason.

### `requires_log substring`

Adds a built-in assertion that the LaTeX log contains the specified substring.
Use multiple calls to check separate parts of a diagnostic, including when a
message is split across log lines.

### `assert(name = nil) { ... }`

Adds a custom assertion to run after the build. Its block runs with an
assertion execution object as `self`:

```ruby
test "Child environment conflicts with a field" do
  file "09-field-child-field-conflict-failure.tex"
  expect_failure

  assert "Reports the conflicting field" do
    expected = "existing field name."
    fail "Expected diagnostic was not found" unless log.include?(expected)
  end
end
```

The execution object provides:

- `log` — reads and caches the current fixture's LaTeX log as a string.
- `pdf_path` — returns the generated PDF's path while the assertion is running.
- `fail(message)` — raises an error to mark the assertion as failed.

Assertions run whether compilation succeeded or failed as expected. Thus a
negative test can inspect the log produced by its failed build.

## Definition Contexts

The framework's public DSL and runner methods are:

| Context | Method | Purpose |
|---|---|---|
| `TestFile` | `testsuite(name) { ... }` | Defines or reopens a named suite. |
| `TestFile` | `test(name) { ... }` | Defines a test in the implicit file-level suite. |
| `TestFile`, `TestSuite`, `Test` | `execute(options = {})` | Runs the contained file, tests, or individual test. |
| `TestSuite` | `test(name) { ... }` | Defines a test in the suite. |
| `Test` | `file(filename)` | Selects the fixture. |
| `Test` | `expect_failure` | Expects compilation to fail. |
| `Test` | `requires_log(substring)` | Checks for a substring in the log. |
| `Test` | `assert(name = nil) { ... }` | Defines a custom post-build assertion. |
| `Assertion` | `execute(temp_dir)` | Runs the custom assertion in its execution context. |
| `Assertion::Execution` | `log` | Reads the fixture log. |
| `Assertion::Execution` | `pdf_path` | Returns the generated fixture PDF path. |
| `Assertion::Execution` | `fail(message)` | Fails the assertion. |

`TestFile#filename`, `TestSuite#name`, and `Test#name` return the corresponding
definition labels or path.

The module-level runner methods are:

| Method | Purpose |
|---|---|
| `LatexTesting.parse_file(filename)` | Loads and caches one definition file. |
| `LatexTesting.scan(base_dir)` | Recursively discovers and loads definition files. |
| `LatexTesting.run(options = {})` | Runs definitions loaded by `scan` or `parse_file`. |

`TestFile`, `TestSuite`, `Test`, `Assertion`, and `Assertion::Execution` can be
constructed directly, but normal test definitions should use the DSL and
module-level runner.
