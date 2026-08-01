### `pnp-decision.sty` implementation notes

This document is for maintainers of `tex/latex/pnpprep/pnp-decision.sty` and for authors of similar template packages.

User-facing usage is intentionally documented in `doc/pnpprep/decision.tex`; this file focuses on internal architecture and design decisions.

### Scope split with `decision.tex`

`doc/pnpprep/decision.tex` already covers user-level behavior and examples, including:

- required structure (`condition`, `pass`, `fail`),
- optional entry titles,
- output order,
- typical usage snippets.

To avoid duplication, this file describes *how* the implementation enforces and renders these rules.

### Source files and integration points

- Main implementation: `tex/latex/pnpprep/pnp-decision.sty`
- Shared internals: `tex/latex/pnpprep/pnp-structuredbox.sty`
- Package loading: `tex/latex/pnpprep/pnpprep.cls`
- End-user documentation: `doc/pnpprep/decision.tex`

### Maintenance update rule

When implementation changes are made to `pnp-decision.sty` or its shared helper layer, update this file in the same change set.

Minimum update scope each time:

- list any new/removed internal helper APIs,
- describe behavior-impacting validation/rendering changes,
- record integration changes (e.g. added `\RequirePackage` dependencies).

### High-level architecture

The package is implemented with `expl3` + `xparse` and follows a two-phase model:

1. **Collect phase**: `decision` children store content into internal state.
2. **Render phase**: at `\end{decision}`, validation runs and one composed `tcolorbox` is emitted.

Why this model:

- allows deterministic section ordering independent of source order,
- allows width calculations for multi-entry title columns,
- centralizes validation before any visible output is finalized.

### Internal state model

Per open `decision` block, the implementation tracks:

- one token list for `condition` body,
- one sequence/list of `pass` entries (`title`, `body`),
- one sequence/list of `fail` entries (`title`, `body`),
- structural counters/flags (e.g. number of `condition` blocks),
- context flags for error detection (child-outside-parent, illegal nesting).

Entry representation is effectively a tuple:

- `title`: optional (blank allowed),
- `body`: captured verbatim token content.

### Environment lifecycle

#### `decision`

- resets all decision-local state,
- enables child-capture mode,
- ignores plain text between children,
- on close: validates state, then renders outer + inner section boxes.

#### `condition`

- allowed only as direct child of `decision`,
- increments `condition` count,
- stores body in the condition slot.

#### `pass` / `fail`

- allowed only as direct child of `decision`,
- capture optional title argument + body,
- append entry to the corresponding sequence, preserving insertion order.

### Validation pipeline

Validation executes before final rendering and raises hard LaTeX errors for:

- child environment used outside `decision`,
- nested child environment usage,
- missing `condition`,
- multiple `condition` blocks,
- missing `pass` entries,
- missing `fail` entries.

Design intent:

- fail fast with explicit diagnostics,
- keep output deterministic by rejecting malformed trees,
- prevent partially rendered invalid decision boxes.

Current helper split:

- decision-specific validation orchestration is in `pnp-decision.sty`,
- generic cardinality checks are delegated to `pnp-structuredbox.sty`:
  - `\pnp_struct_require_exactly_one:nnnn`
  - `\pnp_struct_require_at_least_one:nnn`

### Rendering pipeline

Render order is always fixed:

1. `condition` section
2. `pass` section
3. `fail` section

Current style behavior implemented in `pnp-decision.sty`:

- one breakable outer `tcolorbox` (`0.9\linewidth`, centered),
- colored section blocks for condition/pass/fail,
- thick separators between section blocks,
- no uncolored padding gaps at section/border joins,
- condition body rendered bold,
- pass/fail titles right-aligned.

Pass/fail layout branches:

- **single entry**: optional title above content,
- **multiple entries**:
  - compute max title width for that section,
  - render title column + content column,
  - insert thin separators between entries.

Current helper split:

- thin separator rendering is delegated to `pnp-structuredbox.sty` via
  `\pnp_struct_render_thin_separator:`.

### Why `expl3` is used

`expl3` provides robust primitives for this pattern:

- token-list and sequence storage,
- predictable scoped state handling,
- explicit booleans/counters for structural checks,
- clearer separation of parse, validate, and render phases.

This is preferable to ad-hoc macro chains when implementing collect-first box components with validation.

### Extension points for similar templates

For a new template with similar semantics, reuse this blueprint:

1. define child environments that only capture data,
2. store normalized entry tuples in sequences,
3. validate cardinality and parent/child constraints centrally,
4. render in a deterministic post-parse pass,
5. keep visual concerns localized to render helpers.

Typical modifications:

- change section palette and separator styles,
- rename semantic sections (`pass`/`fail` to domain names),
- alter tuple fields (e.g. add icon, tag, numeric threshold),
- adjust single-vs-multi entry rendering policy.

### Maintenance checklist

When changing `pnp-decision.sty`, verify at minimum:

- all structural errors still fail with clear messages,
- fixed section order remains intact,
- title alignment and width computation still work for multiple entries,
- outer/inner spacing changes do not reintroduce white gaps,
- `doc/pnpprep/decision.tex` remains consistent with externally visible behavior.

### Quick debug strategy

If rendering/structure breaks:

1. test one minimal valid decision block,
2. test each structural error case independently,
3. test one section with multiple titled + untitled entries,
4. inspect whether issue is in capture, validation, or rendering phase,
5. only then adjust style-level `tcolorbox` keys.
