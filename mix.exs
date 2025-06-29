defmodule PromptEngine.MixProject do
  use Mix.Project

  def project do
    [
      app: :prompt_engine,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        plt_add_apps: [:mix]
      ],
      preferred_cli_env: [
        lint: :test,
        "lint.ci": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Phoenix LiveView for real-time interface
      {:ecto_sql, "~> 3.12"},
      {:phoenix_ecto, "~> 4.6"},
      {:phoenix_live_view, "~> 1.0"},
      {:postgrex, "~> 0.19"},

      # Installation automation
      {:igniter, "~> 0.6"},

      # Core dependencies
      {:jason, "~> 1.4"},
      {:telemetry, "~> 1.0"},
      {:langchain, "~> 0.3"},

      # Development and testing tools
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  # Run "mix help compile.aliases" to learn about aliases.
  defp aliases do
    [
      # Local development - more lenient
      lint: [
        "format",
        "credo --strict",
        "dialyzer --ignore-exit-status"
      ],
      # CI/CD - strict checks
      "lint.ci": [
        "format --check-formatted",
        "credo --strict",
        "dialyzer"
      ]
    ]
  end
end
