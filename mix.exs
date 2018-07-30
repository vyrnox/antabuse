defmodule Abuse.MixProject do
  use Mix.Project

  def project do
    [
      app: :antabuse,
      version: "0.1.0",
      elixir: "~> 1.6.4",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Antabuse.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  def deps do
    [
      {:nostrum, git: "https://github.com/Kraigie/nostrum.git"},
      {:redix, ">= 0.0.0"},
      {:uuid, "~> 1.1" }
    ]
  end
end
