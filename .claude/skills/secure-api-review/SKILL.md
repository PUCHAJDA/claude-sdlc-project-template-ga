---
name: secure-api-review
description: Apply the project's API security rules when adding or changing an HTTP route, handler, endpoint, controller, middleware or anything that accepts external input. Use when writing a spec that adds an interface, when implementing one, and when reviewing a diff that touches one.
---

# Secure API review

<!--
EXAMPLE SKILL — this is the shape an org policy takes, with placeholder rules.
Replace the rules below with the ones this project actually has, and delete the rest.

Remember the division of labour: a skill is ADVISORY. Claude can be persuaded out of it,
and it does not run in CI. Anything genuinely non-negotiable needs a hook, a lint rule or
a PR check behind it — see .claude/hooks/ and REVIEW.md.
-->

## Rules

Apply to every route that accepts input from outside the trust boundary.

1. **Authz on every route.** Authentication answers who; authorization answers whether they
   may touch *this* record. A new route inherits neither by default — state which check
   applies, and fail closed when the subject is unknown.
2. **Validate at the edge.** Parse into a typed structure at the handler boundary and reject
   what does not fit. Do not pass raw request data further in.
3. **Parameterised queries only.** No string interpolation into SQL, shell, or template
   engines — including in logging and error messages.
4. **No secrets in the diff.** Credentials come from the config layer. A literal that looks
   like a key is a blocker even in a test fixture.
5. **Log without PII.** Identifiers yes, payloads no. Assume logs leave the trust boundary.
6. **Rate-limit anything unauthenticated**, and anything expensive regardless of auth.
7. **Errors reveal nothing.** Same response shape and timing for "not found" and "not
   yours", or the endpoint becomes an enumeration oracle.

## When writing a spec

Flag each rule the change cannot satisfy as a `> **CONCERN (security):**` block. Do not
narrow the spec to avoid the concern — surface the trade-off and let a human take it.

## When reviewing a diff

Check the rules above in order, then ask the question the rules do not cover: **what does
this endpoint let an untrusted caller reach that they could not reach before?** Answer it
explicitly, even when the answer is "nothing".

Report findings in the format `REVIEW.md` defines: `file:line`, one sentence, one concrete
failure scenario. A rule violation with no reachable scenario is a nit, not a blocker.
