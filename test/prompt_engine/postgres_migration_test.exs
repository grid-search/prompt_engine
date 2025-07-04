defmodule PromptEngine.MigrationPostgresTest do
  use PromptEngine.Case, async: false

  alias PromptEngine.Test.PGMigrationRepo

  @moduletag :postgres
  @moduletag :migration

  setup do
    # Configure PromptEngine to use our PGMigrationRepo
    Application.put_env(PromptEngine, :repo, PGMigrationRepo)

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

  describe "PostgreSQL migration functionality" do
    test "migration up creates tables" do
      PGMigrationRepo.__adapter__().storage_up(PGMigrationRepo.config())

      Ecto.Migrator.down(PGMigrationRepo, 1, Migration)

      assert :ok = Ecto.Migrator.up(PGMigrationRepo, 1, Migration)
      assert prompts_table_exists?()
      assert prompt_versions_table_exists?()
    end

    test "migration down removes tables" do
      PGMigrationRepo.__adapter__().storage_up(PGMigrationRepo.config())

      Ecto.Migrator.up(PGMigrationRepo, 1, Migration)

      assert :ok = Ecto.Migrator.down(PGMigrationRepo, 1, Migration)
      refute prompts_table_exists?()
      refute prompt_versions_table_exists?()
    end

    test "migration is idempotent" do
      PGMigrationRepo.__adapter__().storage_up(PGMigrationRepo.config())

      # Ensure clean state
      Ecto.Migrator.down(PGMigrationRepo, 1, Migration)

      # Apply migration multiple times
      assert :ok = Ecto.Migrator.up(PGMigrationRepo, 1, Migration)
      assert :already_up = Ecto.Migrator.up(PGMigrationRepo, 1, Migration)
      assert :already_up = Ecto.Migrator.up(PGMigrationRepo, 1, Migration)

      # Should not cause errors and tables should still exist
      assert prompts_table_exists?()
      assert prompt_versions_table_exists?()
    end
  end

  defp prompts_table_exists? do
    query = """
    SELECT EXISTS (
      SELECT 1
      FROM information_schema.tables
      WHERE table_schema = 'public'
        AND table_name = 'prompts'
    )
    """

    {:ok, %{rows: [[exists]]}} = PGMigrationRepo.query(query)

    exists
  end

  defp prompt_versions_table_exists? do
    query = """
    SELECT EXISTS (
      SELECT 1
      FROM information_schema.tables
      WHERE table_schema = 'public'
        AND table_name = 'prompt_versions'
    )
    """

    {:ok, %{rows: [[exists]]}} = PGMigrationRepo.query(query)

    exists
  end
end
