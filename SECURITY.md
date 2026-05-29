# Security Policy

## Reporting a Vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

Please report security issues by emailing **[security@yourprotocol.com]** with the subject line `[SECURITY] <brief description>`.

Include:
- A description of the vulnerability and its potential impact
- Steps to reproduce or a proof-of-concept
- Affected contracts and versions
- Any suggested mitigations

We will acknowledge receipt within **48 hours** and provide a more detailed response within **5 business days**, including a timeline for a fix.

---

## Scope

In scope:
- Contracts in `src/`
- Deployed protocol contracts at the addresses listed in `broadcast/`

Out of scope:
- Third-party dependencies in `lib/`
- Front-end and off-chain infrastructure
- Issues requiring compromised admin keys or social engineering

---

## Disclosure Policy

We follow coordinated disclosure. Please allow us reasonable time to investigate and patch before public disclosure. We will credit researchers who report valid vulnerabilities unless they prefer to remain anonymous.

---

## Known Issues

See `KNOWN_ISSUES.md` for documented trade-offs and accepted risks in the current codebase.
