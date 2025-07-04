defmodule PromptEngine.Case do
  @moduledoc false

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox
  alias PromptEngine.{Migration, Prompts}
  alias PromptEngine.Test.{LiteRepo, PGRepo}

  # Future aliases for additional database repos when multi-database support is added:
  # alias PromptEngine.Test.MySQLRepo

  defmodule TestMigration do
    @moduledoc false
    use Ecto.Migration

    def up do
      PromptEngine.Migration.up()
    end
  end

  using do
    quote do
      import PromptEngine.Case

      alias PromptEngine.{Migration, Prompts}
      alias PromptEngine.Test.{LiteRepo, PGRepo}

      # Future aliases for multi-database testing:
      # alias PromptEngine.Test.MySQLRepo
    end
  end

  setup context do
    # Set up SQL Sandbox for PostgreSQL repos in manual mode
    if context[:postgres] do
      :ok = Sandbox.checkout(PGRepo)
      # Migration repo uses auto mode globally, no need to checkout
    end

    create_tables_if_needed(context)

    on_exit(:cleanup, fn ->
      try do
        if context[:postgres] do
          PGRepo.delete_all(PromptEngine.Prompts.PromptVersion)
          PGRepo.delete_all(PromptEngine.Prompts.Prompt)
        else
          LiteRepo.delete_all(PromptEngine.Prompts.PromptVersion)
          LiteRepo.delete_all(PromptEngine.Prompts.Prompt)
        end
      rescue
        # Tables might not exist
        _ -> :ok
      end
    end)

    :ok
  end

  defp create_tables_if_needed(context) do
    if context[:lite] do
      create_sqlite_tables_if_needed()
    end
  end

  defp create_sqlite_tables_if_needed do
    result =
      LiteRepo.query!("SELECT name FROM sqlite_master WHERE type='table' AND name='prompts'")

    if Enum.empty?(result.rows) do
      Ecto.Migrator.up(LiteRepo, 1, TestMigration)
    end
  rescue
    # Tables might already exist or other error
    _ -> :ok
  end

  @doc """
  Helper to get the appropriate repo based on test context.

  Supports context-based repo selection:
  - context[:lite] -> LiteRepo
  - context[:postgres] -> PGRepo
  - context[:mysql] -> MySQLRepo (future)
  """
  def get_repo(context) do
    cond do
      context[:postgres] -> PGRepo
      context[:lite] -> LiteRepo
      # Default to SQLite
      true -> LiteRepo
    end
  end

  @doc """
  Create a test prompt with default values.
  """
  def create_prompt(repo \\ LiteRepo, attrs \\ %{}) do
    default_attrs = %{
      name: "test_prompt_#{System.unique_integer([:positive])}",
      description: "A test prompt"
    }

    attrs = Map.merge(default_attrs, attrs)
    Prompts.create_prompt(repo, attrs)
  end

  @doc """
  Create a test prompt version with default values.
  """
  def create_prompt_version(repo \\ LiteRepo, prompt_id, attrs \\ %{}) do
    default_attrs = %{
      provider: :openai,
      messages: [%{role: :user, content: "Hello, world!"}],
      model_name: "gpt-4",
      model_settings: %{temperature: 0.7}
    }

    attrs = Map.merge(default_attrs, attrs)
    Prompts.create_prompt_version(repo, prompt_id, attrs)
  end
end
