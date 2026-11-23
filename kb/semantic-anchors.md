# Semantic Anchors

## TDD

Test-driven development (TDD) uses tests to guide implementation. First express
the required behavior as a focused test, then implement only what is needed to
make it pass, and finally improve the design without changing that behavior.
The [Red-Green-Refactor cycle](#red-green-refactor) describes this iteration.

Do not manufacture a failing test when the behavior is already implemented. A
correct test for existing behavior may pass immediately and still provide
useful regression coverage. A test or infrastructure failure is not evidence
that the requested behavior is missing.

## Red-Green-Refactor

Red-Green-Refactor is the iterative TDD cycle:

1. **Red:** Add a test with a correct, observable expectation for missing or
   incorrect behavior. Run it against the unchanged implementation and confirm
   that it fails for the intended behavioral reason.
2. **Green:** Make the smallest correct change that satisfies the test, then
   rerun it and the relevant existing tests.
3. **Refactor:** Improve the implementation without changing its behavior, and
   rerun the tests to confirm they remain green.

If a test fails because of its fixture, assertion, or test infrastructure,
diagnose and correct that problem separately. Do not treat it as a behavioral
red result or change production code to hide it. Follow the repository's
[testing practices](testing.md) for test organization and execution.