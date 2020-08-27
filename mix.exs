defmodule CrawlyElixirJobs.MixProject do
  use Mix.Project

  def project do
    [
      app: :crawly_elixir_jobs,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {CrawlyElixirJobs.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:crawly, "~> 0.10.0"},
      {:floki, "~> 0.26.0"},
      {:erlang_node_discovery, git: "https://github.com/oltarasenko/erlang-node-discovery"}
    ]
  end
end
