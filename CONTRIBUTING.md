# Contributing

> **Scope:** Principles contributed here must be **established, widely recognized concepts** from the software engineering literature — named principles, published patterns, or documented practices backed by authoritative sources. They must not duplicate what is already in the catalog.
>
> If your principle is original, company-specific, domain-niche, or doesn't have an authoritative published source, **fork this repo** and add it in your own namespace (e.g., `principles/corp/`) rather than submitting a PR.

## Requirements

Start with the [principle template](principles/TEMPLATE.md).

Every new principle must have:

- A clear principle description in your own words
- At least one verifiable published source (book with ISBN, paper with DOI, or authoritative URL)
- Correct layer assignment (1 = universal, 2 = contextual, 3 = risk-elevated)
- At least one "Violations to detect" entry
- No significant overlap with an existing principle in the catalog
- **Code auditability** — Every principle must have at least one violation identifiable by reading the codebase. Principles whose violations are entirely process-based (e.g., "do X before writing code"), runtime-observable, or dependent on external org/environment context are not accepted. Use `**Audit-scope:** limited` for principles that are partially auditable. See `principles/AUDIT-SCOPE.md` for examples of the boundary.
- **No redundancy** — Do not add a principle already covered by an existing one, even from a different angle or name. Review `catalog.yaml` before submitting. Redundant submissions will not be accepted.

## Process

1. Copy `principles/TEMPLATE.md` to the appropriate category directory
2. Fill in all sections — see [DESIGN.md Section 5](DESIGN.md#-5-principle-file-schema) for the full schema
3. Derive the ID from the file path — see [DESIGN.md Section 4](DESIGN.md#-4-id-derivation)
4. Add the principle to relevant groups in `groups/`
5. If the principle has grep-able violations, add an `## Inspection` section and update the namespace's `.context-inspect.md` — see [DESIGN.md "Inspection — When to Add"](DESIGN.md#-inspection--when-to-add) for guidance
6. Submit a pull request with:
   - The principle file
   - Group file updates (if any)
   - `.context-inspect.md` updates (if applicable)
   - A brief rationale for the source choice

## Source Requirements

Acceptable:

- Books: full citation with ISBN (e.g., *Effective Java* by Bloch, 3rd ed., ISBN 978-0134685991)
- Papers: DOI or stable URL
- Authoritative specifications: RFC, OWASP, IEEE standard with URL

Not acceptable:

- Blog posts without named authors
- Stack Overflow answers
- Undated sources
