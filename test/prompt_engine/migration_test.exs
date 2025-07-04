defmodule PromptEngine.MigrationTest do
  use PromptEngine.Case, async: false

  defmodule MigrationRepo do
    @moduledoc false

    use Ecto.Repo, otp_app: :prompt_engine, adapter: Ecto.Adapters.SQLite3

    alias PromptEngine.Test.LiteRepo

    def init(_, _) do
      {:ok, Keyword.put(LiteRepo.config(), :database, "priv/migration_test.db")}
    end
  end

  @moduletag :lite

  # Future tags for multi-database testing:
  # @moduletag :postgres
  # @moduletag :mysql

  setup do
    # Configure PromptEngine to use our MigrationRepo
    Application.put_env(PromptEngine, :repo, MigrationRepo)

    on_exit(fn ->
      # Clean up the configuration
      Application.delete_env(PromptEngine, :repo)
    end)

    :ok
  end

  defmodule Migration do
    use Ecto.Migration

    def up do
      PromptEngine.Migration.up()
    end

    def down do
      PromptEngine.Migration.down()
    end
  end

  describe "SQLite migration functionality" do
    test "migration up creates tables" do
      start_supervised!(MigrationRepo)

      MigrationRepo.__adapter__().storage_up(MigrationRepo.config())

      Ecto.Migrator.down(MigrationRepo, 1, Migration)

      assert :ok = Ecto.Migrator.up(MigrationRepo, 1, Migration)
      assert prompts_table_exists?()
      assert prompt_versions_table_exists?()
    end

    test "migration down removes tables" do
      start_supervised!(MigrationRepo)

      MigrationRepo.__adapter__().storage_up(MigrationRepo.config())

      Ecto.Migrator.up(MigrationRepo, 1, Migration)

      assert :ok = Ecto.Migrator.down(MigrationRepo, 1, Migration)
      refute prompts_table_exists?()
      refute prompt_versions_table_exists?()
    end

    test "migration is idempotent" do
      start_supervised!(MigrationRepo)

      MigrationRepo.__adapter__().storage_up(MigrationRepo.config())

      # Ensure clean state
      Ecto.Migrator.down(MigrationRepo, 1, Migration)

      # Apply migration multiple times
      assert :ok = Ecto.Migrator.up(MigrationRepo, 1, Migration)
      assert :already_up = Ecto.Migrator.up(MigrationRepo, 1, Migration)
      assert :already_up = Ecto.Migrator.up(MigrationRepo, 1, Migration)

      # Should not cause errors and tables should still exist
      assert prompts_table_exists?()
      assert prompt_versions_table_exists?()
    end
  end

  defp prompts_table_exists? do
    query = """
    SELECT EXISTS (
      SELECT 1
      FROM sqlite_master
      WHERE type='table'
        AND name='prompts'
    )
    """

    {:ok, %{rows: [[exists]]}} = MigrationRepo.query(query)

    exists != 0
  end

  defp prompt_versions_table_exists? do
    query = """
    SELECT EXISTS (
      SELECT 1
      FROM sqlite_master
      WHERE type='table'
        AND name='prompt_versions'
    )
    """

    {:ok, %{rows: [[exists]]}} = MigrationRepo.query(query)

    exists != 0
  end
end
