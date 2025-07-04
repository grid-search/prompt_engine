defmodule PromptEngine.Case do
  @moduledoc false

  use ExUnit.CaseTemplate

  alias PromptEngine.{Migration, Prompts}
  alias PromptEngine.Test.LiteRepo

  # Future aliases for additional database repos when multi-database support is added:
  # alias PromptEngine.Test.{Repo, MySQLRepo}
  # alias Ecto.Adapters.SQL.Sandbox

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
      alias PromptEngine.Test.LiteRepo

      # Future aliases for multi-database testing:
      # alias PromptEngine.Test.{Repo, MySQLRepo}
    end
  end

  setup _context do
    create_tables_if_needed()

    on_exit(:cleanup, fn ->
      try do
        LiteRepo.delete_all(PromptEngine.Prompts.PromptVersion)
        LiteRepo.delete_all(PromptEngine.Prompts.Prompt)
      rescue
        # Tables might not exist
        _ -> :ok
      end
    end)

    # Future PostgreSQL setup with SQL.Sandbox:
    # When adding PostgreSQL support, add context check:
    # if context[:postgres] do
    #   pid = Sandbox.start_owner!(Repo, shared: not context[:async])
    #   on_exit(fn -> Sandbox.stop_owner(pid) end)
    # end

    # Future MySQL setup with SQL.Sandbox:
    # When adding MySQL support, add context check:
    # if context[:mysql] do
    #   pid = Sandbox.start_owner!(MySQLRepo, shared: not context[:async])
    #   on_exit(fn -> Sandbox.stop_owner(pid) end)
    # end

    :ok
  end

  defp create_tables_if_needed do
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
  Currently returns SQLite repo only.

  Future: Will support context-based repo selection:
  - context[:lite] -> LiteRepo
  - context[:postgres] -> Repo  
  - context[:mysql] -> MySQLRepo
  """
  def get_repo(_context), do: LiteRepo

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
      content: "Hello, world!",
      model_name: "gpt-4",
      model_settings: %{temperature: 0.7}
    }

    attrs = Map.merge(default_attrs, attrs)
    Prompts.create_prompt_version(repo, prompt_id, attrs)
  end
end
