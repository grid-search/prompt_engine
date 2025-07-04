import Config

# Configure SQLite for testing
config :prompt_engine, PromptEngine.Test.LiteRepo,
  database: "priv/prompt_engine_test.db",
  priv: "test/support/sqlite",
  stacktrace: true,
  temp_store: :memory

# Future PostgreSQL configuration for production testing
# config :prompt_engine, PromptEngine.Test.Repo,
#   pool: Ecto.Adapters.SQL.Sandbox,
#   pool_size: System.schedulers_online() * 2,
#   priv: "test/support/postgres",
#   show_sensitive_data_on_connection_error: true,
#   stacktrace: true,
#   url: System.get_env("POSTGRES_URL") || "postgres://localhost:5432/prompt_engine_test"

# Future MySQL configuration for alternative production testing
# config :prompt_engine, PromptEngine.Test.MySQLRepo,
#   pool: Ecto.Adapters.SQL.Sandbox,
#   pool_size: System.schedulers_online() * 2,
#   priv: "test/support/mysql",
#   show_sensitive_data_on_connection_error: true,
#   stacktrace: true,
#   url: System.get_env("MYSQL_URL") || "mysql://root@localhost:3306/prompt_engine_test"

# List of configured repos (currently SQLite only)
config :prompt_engine,
  ecto_repos: [PromptEngine.Test.LiteRepo]

# Future multi-database configuration
# config :prompt_engine,
#   ecto_repos: [PromptEngine.Test.LiteRepo, PromptEngine.Test.Repo, PromptEngine.Test.MySQLRepo]

# Import environment specific config
env_config = "#{Mix.env()}.exs"

if File.exists?(Path.join(__DIR__, env_config)) do
  import_config env_config
end
