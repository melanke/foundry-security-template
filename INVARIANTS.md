# Protocol Invariants

> **Single source of truth**: This file is generated from `.specs/economics/INVARIANTS.md`
> during project setup and should not be edited directly. To add, modify, or remove
> an invariant, update `.specs/economics/INVARIANTS.md` — that is the authoritative
> document maintained throughout the specification phases.
>
> If the spec directory is not present (e.g. you are not using the defi-spec-driven
> workflow), you may maintain this file directly using the format below.

An auditor reading `.specs/economics/INVARIANTS.md` can derive the full set of
behavioral guarantees the protocol claims to maintain, including the rationale,
the conditions under which each invariant breaks, and the corresponding
`property_` function in `test/recon/Properties.sol`.

---

## Format

Each invariant uses a slug-based identifier (e.g. `INV-vault-solvency`) that
appears in three places: this file, the corresponding `property_` function name
in `test/recon/Properties.sol`, and inline comments in the implementation code.

```markdown
### INV-{noun}-{property}

**Statement:** A single formal sentence stating what must always be true.
**Plain language:** What this means for users.
**Breaks when:** The conditions under which this invariant can be violated.
**Scope:** Which contracts this applies to.
**Property function:** `property_{noun}_{property}()` in `test/recon/Properties.sol`
```

---

## Invariants

<!-- Populated from .specs/economics/INVARIANTS.md during project setup.
     See that file for the full invariant list with rationale and phase references. -->
