defmodule GithubActions.MixProject do
  use Mix.Project

  def project do
    [
      app: :github_actions,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      versioning: versioning()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:readmix, "~> 0.7"},
      {:yaml_elixir, "~> 2.0"}
    ]
  end

  defp versioning do
    [
      annotate: true,
      before_commit: [
        &readmix/1,
        {:add, "README.md"},
        &gen_changelog/1,
        {:add, "CHANGELOG.md"}
      ]
    ]
  end

  def readmix(vsn) do
    rdmx = Readmix.new(vars: %{app_vsn: vsn})
    :ok = Readmix.update_file(rdmx, "README.md")

    :ok =
      Enum.each(Path.wildcard("guides/**/*.md"), fn path ->
        :ok = Readmix.update_file(rdmx, path)
      end)
  end

  defp gen_changelog(vsn) do
    case System.cmd("git", ["cliff", "--tag", vsn, "-o", "CHANGELOG.md"], stderr_to_stdout: true) do
      {_, 0} -> IO.puts("Updated CHANGELOG.md with #{vsn}")
      {out, _} -> {:error, "Could not update CHANGELOG.md:\n\n #{out}"}
    end
  end
end
