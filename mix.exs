defmodule PromptEngine.MixProject do
  use Mix.Project

  def project do
    [
      app: :prompt_engine,
      version: "0.1.0",
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      preferred_cli_env: [
        lint: :dev,
        "lint.ci": :test,
        "test.lite": :test,
        "test.postgres": :test
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

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
      {:phoenix_live_view, "~> 1.0"},
      {:tailwind, "~> 0.2", runtime: false},

      # Installation automation
      {:igniter, "~> 0.6"},

      # Core dependencies
      {:jason, "~> 1.4"},
      {:telemetry, "~> 1.0"},
      {:langchain, "~> 0.3"},

      # Development and testing tools
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},

      # Database adapters
      {:ecto_sql, "~> 3.12"},
      {:phoenix_ecto, "~> 4.6"},
      {:postgrex, "~> 0.19", only: [:test], runtime: false},
      {:ecto_sqlite3, "~> 0.17", only: [:test], runtime: false}
    ]
  end

  # Run "mix help compile.aliases" to learn about aliases.
  defp aliases do
    [
      # Local development - more lenient
      lint: [
        "compile --warnings-as-errors",
        "format",
        "credo --strict"
      ],
      # CI/CD - strict checks
      "lint.ci": [
        "compile --warnings-as-errors",
        "format --check-formatted",
        "credo --strict"
      ],
      # Database-specific test commands
      "test.lite": ["test --only lite"],
      "test.postgres": ["test --only postgres"]
    ]
  end
end
