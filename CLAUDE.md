# Project: github-actions

A repository of reusable GitHub Actions, primarily for Elixir projects.

## Structure

Each action lives in its own top-level directory (e.g. `mix-deps/`, `run-dialyzer/`).
The following top-level directories are **not** actions and are ignored by the generator:
`config`, `deps`, `lib`, `.github`, `_build`, `.git`.

## Adding a new action

1. Create a directory for the action (e.g. `my-action/`).
2. Add `action.yml` — the standard GitHub Actions composite action definition.
3. Add `usage.yml` — **required** — a usage example for the README. Must contain a `with` key
   whose value is a map of input names to example values. Any subset of inputs is fine; only
   the ones listed will appear in the generated snippet.

```yaml
# usage.yml example
with:
  otp-version: "${{ steps.setup_beam.outputs.otp-version }}"
  elixir-version: "${{ steps.setup_beam.outputs.elixir-version }}"
```

## Maintaining usage examples

**Always keep `usage.yml` up to date when changing inputs in `action.yml`.**

- If you add a required input, add it to `usage.yml`.
- If you rename or remove an input, update `usage.yml` accordingly.
- The generator (`lib/github_actions/rdmx_generator.ex`) will raise at README generation time
  if `usage.yml` is missing or if its `with` key is not a map.

## README generation

The README is generated with [readmix](https://github.com/lud/readmix):

```
mix rdmx.update README.md
```

The `<!-- rdmx gha:list_actions -->` block is populated automatically from each action's
`action.yml` (name, description, inputs) and `usage.yml` (snippet). Do not edit directly.
