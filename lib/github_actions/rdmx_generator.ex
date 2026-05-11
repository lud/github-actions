defmodule GithubActions.RdmxGenerator do
  use Readmix.Generator

  @ignored_dirs ~w[config deps lib .github _build .git]

  action(:list_actions, params: [])

  def list_actions(_, _) do
    root = File.cwd!()

    actions =
      root
      |> File.ls!()
      |> Enum.filter(&File.dir?(Path.join(root, &1)))
      |> Enum.reject(&(&1 in @ignored_dirs))
      |> Enum.sort()

    content =
      Enum.map(actions, fn dir ->
        action_yml = Path.join([root, dir, "action.yml"])

        unless File.exists?(action_yml) do
          raise "Missing action.yml in #{dir}/"
        end

        action_yml |> YamlElixir.read_from_file!() |> format_action()
      end)

    {:ok, Enum.intersperse(content, "\n")}
  end

  defp format_action(%{"name" => name, "description" => description} = data) do
    "### #{name}\n\n#{description}\n#{format_inputs(data["inputs"])}"
  end

  defp format_inputs(nil), do: ""
  defp format_inputs(inputs) when map_size(inputs) == 0, do: ""

  defp format_inputs(inputs) do
    rows =
      inputs
      |> Enum.sort_by(fn {key, spec} -> {!spec["required"], key} end)
      |> Enum.map(fn {key, spec} ->
        required = if spec["required"], do: "yes", else: "no"
        default = spec["default"] || ""
        description = spec["description"] || ""
        "| `#{key}` | #{required} | #{default} | #{description} |"
      end)

    header = "| Input | Required | Default | Description |\n|-------|:--------:|---------|-------------|\n"
    "\n**Inputs**\n\n#{header}#{Enum.join(rows, "\n")}\n"
  end
end
