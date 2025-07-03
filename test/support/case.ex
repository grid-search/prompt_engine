defmodule PromptEngine.Case do
  @moduledoc false

  use ExUnit.CaseTemplate

  alias PromptEngine.{Migration, Prompts}
  alias PromptEngine.Test.LiteRepo

  # Future imports for additional database repos when multi-database support is added:
  # alias PromptEngine.Test.{Repo, MySQLRepo}
  # alias Ecto.Adapters.SQL.Sandbox

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
    # SQLite cleanup - simple delete_all since no connection pooling
    on_exit(fn ->
      LiteRepo.delete_all(PromptEngine.Prompts.PromptVersion)
      LiteRepo.delete_all(PromptEngine.Prompts.Prompt)
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
