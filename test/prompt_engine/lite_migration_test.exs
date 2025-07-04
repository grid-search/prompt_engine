defmodule PromptEngine.MigrationTest do
  use PromptEngine.Case, async: false

  alias PromptEngine.Test.LiteMigrationRepo

  @moduletag :lite

  setup do
    # Configure PromptEngine to use our LiteMigrationRepo
    Application.put_env(PromptEngine, :repo, LiteMigrationRepo)

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
      LiteMigrationRepo.__adapter__().storage_up(LiteMigrationRepo.config())

      Ecto.Migrator.down(LiteMigrationRepo, 1, Migration)

      assert :ok = Ecto.Migrator.up(LiteMigrationRepo, 1, Migration)
      assert prompts_table_exists?()
      assert prompt_versions_table_exists?()
    end

    test "migration down removes tables" do
      LiteMigrationRepo.__adapter__().storage_up(LiteMigrationRepo.config())

      Ecto.Migrator.up(LiteMigrationRepo, 1, Migration)

      assert :ok = Ecto.Migrator.down(LiteMigrationRepo, 1, Migration)
      refute prompts_table_exists?()
      refute prompt_versions_table_exists?()
    end

    test "migration is idempotent" do
      LiteMigrationRepo.__adapter__().storage_up(LiteMigrationRepo.config())

      # Ensure clean state
      Ecto.Migrator.down(LiteMigrationRepo, 1, Migration)

      # Apply migration multiple times
      assert :ok = Ecto.Migrator.up(LiteMigrationRepo, 1, Migration)
      assert :already_up = Ecto.Migrator.up(LiteMigrationRepo, 1, Migration)
      assert :already_up = Ecto.Migrator.up(LiteMigrationRepo, 1, Migration)

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

    {:ok, %{rows: [[exists]]}} = LiteMigrationRepo.query(query)

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

    {:ok, %{rows: [[exists]]}} = LiteMigrationRepo.query(query)

    exists != 0
  end
end
