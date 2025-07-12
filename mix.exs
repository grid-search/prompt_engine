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
      {:phoenix, "~> 1.7"},
      {:phoenix_html, "~> 3.3 or ~> 4.0"},
      {:phoenix_pubsub, "~> 2.1"},
      {:phoenix_live_view, "~> 1.0"},

      # Installation automation
      {:igniter, "~> 0.6"},

      # Core dependencies
      {:jason, "~> 1.4"},
      {:telemetry, "~> 1.0"},
      {:langchain, "~> 0.3"},

      # Development and testing tools
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:esbuild, "~> 0.8", only: :dev, runtime: false},
      {:tailwind, "~> 0.2", only: :dev, runtime: false},
      {:phoenix_live_reload, "~> 1.2", only: :dev},

      # Database adapters
      {:ecto_sql, "~> 3.12"},
      {:phoenix_ecto, "~> 4.6"},
      {:postgrex, "~> 0.19", only: :test, runtime: false},
      {:ecto_sqlite3, "~> 0.17", only: :test, runtime: false}
    ]
  end

  # Run "mix help compile.aliases" to learn about aliases.
  defp aliases do
    [
      # Assets
      "assets.compile": ["tailwind prompt_engine_web", "esbuild default"],
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
