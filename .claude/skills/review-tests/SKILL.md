---
name: review-tests
description: Review unit tests for redundancy. Finds tests already covered elsewhere, tests at the wrong layer, and redundant or irrelevant assertions inside tests. Use when tests are added or changed, or when asked to check/prune tests.
argument-hint: "[test file, directory, or git ref — defaults to tests in the current diff]"
---

# Review tests for redundancy

Report-only by default. Do not edit tests unless the user asks.

## 1. Pick the scope

- If the argument is a file or directory, review those tests.
- If the argument is a git ref, treat it as the base branch (see below).
- Otherwise review test files changed on the current branch only, i.e. the commits since it diverged from its base, plus any uncommitted changes.

### Finding the base (branches may be stacked)

Diffing against `main` would include parent branches' tests in a stack, so find the direct parent. Use the first that works:

1. A base ref passed as the argument.
2. The open PR's base: `gh pr view --json baseRefName -q .baseRefName`.
3. Branch parent metadata, if present (e.g. `git config branch.<name>.parent`, or a Graphite stack via `gt parent`).
4. Otherwise ask the user which branch is the parent. Only fall back to `main` if they say so.

Then list the changed test files with `git diff --name-only $(git merge-base HEAD <base>)...HEAD` (and `git diff --name-only HEAD` for uncommitted changes). Review only the changed/added tests in those files, not the whole file. State which base was used at the top of the report.

If there are no test changes, ask which tests to review.

## 2. Gather context

For each test file in scope:

- Read the test file and the module under test.
- Find sibling/related tests: grep the repo for the module's name, its exported functions, and the behaviours being asserted.
- Note which layer the module lives in (e.g. frontdoor/API, service, repository, util).

## 3. Check for redundant tests

Flag a test when:

- Another test already asserts the same behaviour with the same or equivalent inputs (in the same file or elsewhere, including a higher or lower layer that is the proper home for it).
- It only differs from another test by trivial input variation that exercises no new branch (suggest `it.each`/parametrising, or deleting).
- It re-tests a dependency's behaviour (e.g. a library, or a lower layer's logic) rather than this module's own.
- It tests the layer above or below the one the module lives in. Behaviour of a service belongs in the service's tests, not in the frontdoor/API package, and vice versa.

## 4. Check for redundant/irrelevant assertions

Within each test, flag assertions that:

- Duplicate another assertion in the same test.
- Are implied by an earlier assertion (e.g. `toHaveLength(1)` followed by checking the only element, or a `not.toBeNull()` before a stricter check on the same value).
- Are unrelated to the behaviour in the test's name (incidental fields, unrelated mock calls).
- Assert on mocks' setup rather than the module's behaviour (e.g. a mock returns X, then asserting the result is X with no logic in between).
- Assert implementation details that make the test brittle without protecting behaviour (call order, exact call counts that don't matter).
- Are tautologies or can never fail.

Do not flag an assertion if it is the only guard for a distinct branch or requirement. When unsure, say so rather than flagging.

## 5. Report

Group findings by file. For each finding give:

- `path:line` of the test/assertion
- Type: `duplicate-test`, `wrong-layer`, `redundant-assertion`, or `irrelevant-assertion`
- One line on why, and the evidence (path:line of the test that already covers it, or the earlier assertion that implies it)
- Suggested action (delete, merge, move to <layer/file>, parametrise)

Finish with a short summary count per type. If nothing is found, say so plainly.
Keep the report concise; no praise or restating of passing tests.
