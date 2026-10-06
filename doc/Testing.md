# Testing Concept for Card Unit Tests

## Goal

This document is the shared guide for the unit tests of the card class. It explains how individual test fixtures are written and executed, how PDFs are accepted manually, and which rules apply to expected compilation errors.

This document is not a central aggregate test. Each feature ticket defines its own fixtures and concrete expected outputs.

## Location and Structure of a Single Fixture

The card unit tests live under:

- `test/unit/pnpprep/pnpcards/`

A single fixture is a regular LaTeX file with a clear, unique name, for example:

- `01-page-splitting-prototype.tex`
- `02-...tex`

This follows the style of the existing blueprint tests under:

- `test/unit/pnpprep/pnp-blueprint/`

A core part of this style is the small, focused test file: it targets exactly one scenario, uses only minimal helper commands, and contains a short section at the end describing the expected output.

The file itself is the test object. The LaTeX run must complete without errors; afterward, the user manually compares the generated PDF against the expectation documented in the fixture.

## `% Expected Output` Convention

At the end of a test file there is a short comment section describing the expected output. This is the documented acceptance requirement for the user.

Example from the existing style:

```tex
\documentclass[12pt]{pnpprep}

\begin{document}

\begin{blueprint}{simple}
    \begin{render}
        BEGIN SIMPLE
        END SIMPLE
    \end{render}
\end{blueprint}

\begin{simple}
\end{simple}

\end{document}

% Expected output
% BEGIN SIMPLE END SIMPLE
```

The same convention applies to the card tests. A typical example from this project is:

```tex
% Expected Output
% Page 1: The front-page title area is visible above a short body containing
%         SHORT CONTENT FITS ON FRONT.
% Page 2: Blank back page.
% Page 3: Front title "Natural overflow" and NATURAL LINE 01 through 09.
% Page 4: NATURAL LINE 10 through 12, continuing in order and without a title
%         area.
% Page 5: Front title "Explicit page break", CONTENT BEFORE NEWPAGE, and the
%         status "Explicit break marker detected".
% Page 6: CONTENT AFTER NEWPAGE, without a title area.
```

The line `% Expected Output` (or `% Exptected output`) in the comment section is the key convention: comparing the PDF output with the stated expectation is the formal acceptance step.

## Running a Single Fixture

A single fixture is compiled in its own directory:

```bash
make test/unit/pnpprep/pnpcards/01-page-splitting-prototype.pdf
```

This will compile the file `test/unit/pnpprep/pnpcards/01-page-splitting-prototype.tex` to `make test/unit/pnpprep/pnpcards/01-page-splitting-prototype.pdf`.

Additional artifacts such as `.log`, `.aux`, and `.synctex.gz` are also created in the same directory. The PDF is the visible test output; the log is only used for debugging errors.

They can be removed via `make clean` which removes _all_ output (including pdf files)

## Running All Existing Tests

The existing unit tests are run via the current Make target:

```bash
make test
```

The `make test` target finds all `.tex` fixtures under `test/` and compiles them to PDFs. The generated PDFs remain next to the fixture that produced them; for the card tests, that means they are stored under `test/unit/pnpprep/pnpcards/`.

Currently this will always fail because of the negativetests which tests that the fixture fails the build.
See the chapter about the future for more details on how this should be tackled.

## Manual Visual Acceptance

A successful LaTeX run alone is not acceptance.

The user must compare each successful test PDF visually to the matching `% Expected Output`. This means:

- The PDF must reflect the structure described in the comment section.
- The user checks page order, titles, content, and blank areas manually.
- Only once the visual review matches the expected output is the fixture considered accepted.

This rule applies to all successful PDF tests for the card class.

So if a test is conducted by an AI agent, it must show the PDF to the user (by copying it to the out/ folder as only the workspace can be displayed) and ask if the PDF meets the requirements by quoting the Expected output section to the user.

## Checking Expected Compilation Errors

Negative tests are not treated like normal successful PDF tests. If a fixture is intended to produce an expected error, the affected document is compiled separately. The user then checks the log for the error message defined in the corresponding ticket.

Principles:

- Such a run is not a "green PDF test".
- The result is not a successful output but proof that the defined error occurs.
- The check is done manually in the log by examining the relevant error message.

These negative cases are therefore intentionally separated from normal PDF acceptance checks.

## Test Style and De Facto Rules

The test style for the card class follows the existing blueprint tests under `test/unit/pnpprep/pnp-blueprint/`:

- each test is small and focused
- each fixture covers exactly one statement or one concrete problem
- the result is easy to understand and visually check
- the expected text is placed directly in the fixture so the reviewer can quickly see the intent
- the test is documented as an individual case, not as a generic aggregate test

## Future: Automated Negative Tests

The following ideas describe how test automation could be extended in the future without losing the manual PDF review for positive cases.

### Switching from make to rake

A next step would be switching from `make` to `rake`, so that test runs can be better structured and parameterized. This makes it easier to manage fixtures with different expectations and error conditions cleanly.

### A Custom Ruby Test Framework

A longer-term solution would be a custom Ruby test framework that describes test cases declaratively. In that model, a test case would no longer be hidden only in the `.tex` file, but would be described in a dedicated test-case file.

Example:

```ruby
testcase "only needs to compile" do
    file "00-only-needs-to-compile.tex"
end

testcase "page splitting prototype" do
    file "01-page-splitting-prototype.tex"

    expected_output """
    Page 1: The front-page title area is visible above a short body containing
            SHORT CONTENT FITS ON FRONT.
    Page 2: Blank back page.
    Page 3: Front title "Natural overflow" and NATURAL LINE 01 through 09.
    Page 4: NATURAL LINE 10 through 12, continuing in order and without a title
            area.
    Page 5: Front title "Explicit page break", CONTENT BEFORE NEWPAGE, and the
            status "Explicit break marker detected".
    Page 6: CONTENT AFTER NEWPAGE, without a title area.
    """
end

testcase "negative test case" do 
    file "02-negative-test-case.tex"
    compile_succeeds false
    expect_message "Too many pages for a card"
    expect_message /You are using \d+ pages but only 2 are allowed/
end
```

Advantages of this approach:

- The test case name no longer needs to appear fully in the filename.
- A test case explicitly identifies which `.tex` file should be compiled.
- A test case can optionally say whether compilation should succeed (default: yes).
- A test case can check strings or regexes in the log.
- A test case can optionally state whether a user must review the PDF and what visual expectation should be seen.

This would keep the current `% Expected Output` mechanism available as the human acceptance step even as automation continues to evolve.

### Even Further in the Future: Comparing PDF Content

A later stage would be automatic comparison of PDF content against the expected result. In that model, a person would no longer need to inspect every PDF manually; an automated check could compare the visual semantics against a predefined expectation. That would be a true replacement for manual acceptance, but only at a much more advanced stage.

## Conclusion

This testing concept is the shared foundation for all card unit tests. The rules are intentionally simple:

- individual `.tex` fixtures in the test folder
- short `% Expected Output` statements at the end of each file
- `make test` as the overall run
- manual visual acceptance of PDFs
- separate verification of expected compilation errors in the log
- shared guidance, but no central aggregate test suite

This keeps the tests understandable, reproducible, and easy to extend.
