# Project Guidelines

## Knowledge Base

- At the start of every task, read `kb/index.md` and use it as the project's
  knowledge-base entry point.
- Before changing project files or answering project-specific questions, read
  the relevant linked knowledge-base pages.
- Keep the knowledge base in sync with lasting changes to code, tests,
  documentation, build configuration, architecture, or behavior. Record lasting
  product requirements even when implementation is deferred, and put unresolved
  details in `kb/open-questions.md` rather than guessing.
- Update `kb/index.md` when knowledge-base pages are added, removed, renamed,
  or their scope changes. Keep entries focused on durable project knowledge,
  not one-off instructions or routine task details.
- The knowledge-base may contain skills in its `skills` folder. If so, the file `kb/skills/index.md` contains a table of skills and when to use them

## Development and Testing

- For development or test tasks, read and apply [TDD](kb/semantic-anchors.md#tdd)
  and [Red-Green-Refactor](kb/semantic-anchors.md#red-green-refactor).

## Dependencies

- If a change requires `bundle install`, ask the user to run it and wait for
  confirmation; do not run it yourself.