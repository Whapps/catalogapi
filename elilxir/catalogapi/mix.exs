defmodule Catalogapi.MixProject do
  use Mix.Project

  def project do
    [
      app: :catalogapi,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Catalogapi.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # TODO coveralls, ex_doc, inch_ex
      # https://github.com/teamon/tesla/blob/52d3a3be6787b72b43c1c12bd6152ed2e7f8009e/mix.exs#L73
      {:credo, "~> 1.1"},
      {:hackney, "~> 1.14.0"}, # optional, but recommended adapter
      {:tesla, "~> 1.2.0"},
      {:uuid, "~> 1.1"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
