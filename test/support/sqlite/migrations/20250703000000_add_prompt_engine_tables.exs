defmodule PromptEngine.Test.LiteRepo.SQLite.Migrations.AddPromptEngineTables do
  @moduledoc false
  use Ecto.Migration

  # Delegate to the main PromptEngine.Migration module to ensure
  # identical behavior across all supported database engines
  defdelegate up, to: PromptEngine.Migration
  defdelegate down, to: PromptEngine.Migration

  # Future PostgreSQL migration will be:
  # test/support/postgres/migrations/YYYYMMDDHHMMSS_add_prompt_engine_tables.exs
  # with identical defdelegate structure

  # Future MySQL migration will be:
  # test/support/mysql/migrations/YYYYMMDDHHMMSS_add_prompt_engine_tables.exs
  # with identical defdelegate structure
end
