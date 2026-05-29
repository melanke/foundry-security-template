# Known Issues

This file documents Slither warnings and vertigo mutation survivors that have been
reviewed and accepted. Every suppressed finding must have an entry here explaining
*why* it was accepted — not just *that* it was suppressed.

An auditor reading this file should come away with confidence that each entry
represents a deliberate decision, not noise left unaddressed.

---

## Format

Each entry should follow this pattern:

```
### [Tool] ContractName — detector-name or mutant description

**Location:** `src/ContractName.sol:LINE`
**Suppression:** `// slither-disable-next-line detector` or `// vertigo:skip`

One paragraph explaining: what the tool flagged, why it's not actionable in
this specific context, and what invariant or upstream constraint makes it safe.
```

---

<!-- Add entries below as findings are triaged. -->
