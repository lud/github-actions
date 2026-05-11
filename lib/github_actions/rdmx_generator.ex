defmodule GithubActions.RdmxGenerator do
  use Readmix.Generator

  @ignored_dirs ~w[config deps lib .github _build .git]
  @repo_slug "lud/github-actions"

  action(:list_actions, params: [])

  def list_actions(_, context) do
    root = File.cwd!()
    app_vsn = context.readmix.vars.app_vsn
    git_ref = "v" <> (app_vsn |> Version.parse!() |> Map.fetch!(:major) |> to_string())

    actions =
      root
      |> File.ls!()
      |> Enum.filter(&File.dir?(Path.join(root, &1)))
      |> Enum.reject(&(&1 in @ignored_dirs))
      |> Enum.sort()

    content =
      Enum.map(actions, fn dir ->
        action_yml = Path.join([root, dir, "action.yml"])

        if not File.exists?(action_yml) do
          raise "Missing action.yml in #{dir}/"
        end

        usage_yml = Path.join([root, dir, "usage.yml"])

        if not File.exists?(usage_yml) do
          raise "Missing usage.yml in #{dir}/"
        end

        usage = usage_yml |> YamlElixir.read_from_file!() |> validate_usage!(dir)

        action_yml
        |> YamlElixir.read_from_file!()
        |> format_action(dir, usage, @repo_slug, git_ref)
      end)

    {:ok, Enum.intersperse(content, "\n")}
  end

  defp format_action(%{"name" => name, "description" => description} = data, dir, usage, repo_slug, git_ref) do
    inputs = data["inputs"] || %{}

    inputs_order =
      inputs
      |> Enum.sort_by(fn {key, spec} -> {!spec["required"], key} end)
      |> Enum.with_index()
      |> Map.new(fn {{key, _spec}, idx} -> {key, idx} end)

    [
      "### ",
      name,
      "\n\n",
      description,
      "\n",
      format_inputs(inputs, inputs_order),
      format_snippet(name, dir, usage, repo_slug, git_ref, inputs_order)
    ]
  end

  defp validate_usage!(%{"with" => with_inputs} = usage, _dir) when is_map(with_inputs) do
    usage
  end

  defp validate_usage!(_, dir) do
    raise("usage.yml in #{dir}/ must have a 'with' key containing a map")
  end

  defp format_snippet(name, dir, usage, repo_slug, git_ref, inputs_order) do
    with_lines =
      usage
      |> Map.fetch!("with")
      |> Enum.sort_by(fn {key, _value} -> Map.get(inputs_order, key, 9_999_999) end)
      |> Enum.map(fn {key, value} -> ["    ", key, ": ", value, "\n"] end)

    [
      "\n**Usage**\n\n```yaml\n- name: ",
      name,
      "\n  uses: ",
      repo_slug,
      "/",
      dir,
      "@",
      git_ref,
      "\n  with:\n",
      with_lines,
      "```\n"
    ]
  end

  defp format_inputs(inputs, _inputs_order) when map_size(inputs) == 0 do
    []
  end

  defp format_inputs(inputs, inputs_order) do
    rows =
      inputs
      |> Enum.sort_by(fn {key, _spec} -> Map.fetch!(inputs_order, key) end)
      |> Enum.map(fn {key, spec} ->
        required =
          if spec["required"] do
            "yes"
          else
            "no"
          end

        default = spec["default"] || ""
        description = spec["description"] || ""
        ["| `", key, "` | ", required, " | ", default, " | ", description, " |\n"]
      end)

    [
      "\n**Inputs**\n\n| Input | Required | Default | Description |\n|-------|:--------:|---------|-------------|\n",
      rows,
      "\n"
    ]
  end
end
