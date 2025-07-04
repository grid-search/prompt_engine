defmodule PromptEngine.Migration do
  @moduledoc """
  Migration module for PromptEngine database tables.

  Users can call this from their application migrations:

      defmodule MyApp.Repo.Migrations.AddPromptEngineTables do
        use Ecto.Migration
      
        def up do
          PromptEngine.Migration.up(version: 1)
        end
      
        def down do
          PromptEngine.Migration.down(version: 0)
        end
      end
  """
  use Ecto.Migration

  alias PromptEngine.Config

  @initial_version 0
  @current_version 1

  def up(opts \\ []) do
    version = Keyword.get(opts, :version, @current_version)
    initial = migrated_version()

    if initial < version do
      change(initial, version, :up)
    end
  end

  def down(opts \\ []) do
    version = Keyword.get(opts, :version, @initial_version)
    current = migrated_version()

    if current > version do
      change(current, version, :down)
    end
  end

  defp migrated_version do
    repo = Config.repo!()
    adapter = Config.adapter()

    case adapter do
      :sqlite -> migrated_version_sqlite(repo)
      # TODO: Add support for other adapters
      # :postgres -> migrated_version_postgres(repo)
      # :mysql -> migrated_version_mysql(repo)
      _ -> @initial_version
    end
  end

  defp migrated_version_sqlite(repo) do
    result = repo.query("SELECT name FROM sqlite_master WHERE type='table' AND name='prompts'")

    case result do
      {:ok, %{rows: [["prompts"]]}} -> @current_version
      {:ok, %{rows: []}} -> @initial_version
      _ -> @initial_version
    end
  end

  defp change(from, to, direction) when from < to and direction == :up do
    for version <- (from + 1)..to do
      apply(__MODULE__, :"change_v#{version}", [direction])
    end
  end

  defp change(from, to, direction) when from > to and direction == :down do
    for version <- from..(to + 1)//-1 do
      apply(__MODULE__, :"change_v#{version}", [direction])
    end
  end

  defp change(from, to, direction) do
    # Catch-all for debugging
    IO.puts("Migration change called with from=#{from}, to=#{to}, direction=#{direction}")
    :ok
  end

  def change_v1(:up) do
    create_if_not_exists table(:prompts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text

      timestamps type: :utc_datetime_usec
    end

    create_if_not_exists unique_index(:prompts, [:name])

    create_if_not_exists table(:prompt_versions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :prompt_id, references(:prompts, type: :binary_id, on_delete: :delete_all), null: false
      add :version_number, :integer, null: false
      add :state, :string, null: false, default: "draft"
      add :provider, :string, null: false
      add :messages, :map, null: false, default: []
      add :model_name, :string, null: false
      add :model_settings, :map, default: %{}

      timestamps type: :utc_datetime_usec
    end

    create_if_not_exists unique_index(:prompt_versions, [:prompt_id, :version_number])
    create_if_not_exists index(:prompt_versions, [:prompt_id])
    create_if_not_exists index(:prompt_versions, [:state])

    create_if_not_exists(
      unique_index(:prompt_versions, [:prompt_id],
        where: "state = 'published'",
        name: :prompt_versions_unique_published_per_prompt
      )
    )
  end

  def change_v1(:down) do
    drop_if_exists table(:prompt_versions)
    drop_if_exists table(:prompts)
  end
end
