defmodule PromptEngine.Test.PGRepo.Postgres.Migrations.AddPromptEngineTables do
  @moduledoc false
  use Ecto.Migration

  def up do
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
      add :messages, :map, null: false, default: "{}"
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

  def down do
    drop_if_exists table(:prompt_versions)
    drop_if_exists table(:prompts)
  end
end
