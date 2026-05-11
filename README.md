# Github Actions

A repository of reusable Github actions, mostly for the Elixir language.

## Actions

<!-- rdmx gha:list_actions -->
### Mix Dependencies

Restores deps and _build from cache, installs dependencies, compiles them, then immediately saves the cache. The cache is saved right after this step, not at the end of the workflow, so dependencies are cached even when a later step fails. Useful when iterating on a CI pipeline, as you avoid recompiling on every run.


**Inputs**

| Input | Required | Default | Description |
|-------|:--------:|---------|-------------|
| `elixir-version` | yes |  | Elixir version, typically from the outputs of setup-beam. |
| `otp-version` | yes |  | Erlang/OTP version, typically from the outputs of setup-beam. |
| `cache-version` | no | v1 | Cache key prefix. Bump this to invalidate the cache. |

### Run Dialyzer

Restores the Dialyzer PLT from cache, runs mix dialyzer, then immediately saves the PLT cache. The cache is saved right after this step, not at the end of the workflow, so the PLT is available on the next run regardless of whether later steps succeed. This matters because PLT generation can take several minutes.


**Inputs**

| Input | Required | Default | Description |
|-------|:--------:|---------|-------------|
| `elixir-version` | yes |  | Elixir version, typically from the outputs of setup-beam. |
| `otp-version` | yes |  | Erlang/OTP version, typically from the outputs of setup-beam. |
| `cache-version` | no | v1 | Cache key prefix. Bump this to invalidate the cache. |
<!-- rdmx /gha:list_actions -->

