defmodule PromptEngine.Prompts.Prompt do
  @moduledoc """
  Schema for storing prompt definitions.

  A prompt represents a template that can have multiple versions.
  Only one version can be published at a time.
  """
  use PromptEngine.Schema

  alias PromptEngine.Prompts.PromptVersion

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          name: String.t(),
          description: String.t() | nil,
          versions: [PromptVersion.t()],
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @derive {Jason.Encoder, only: [:id, :name, :description, :inserted_at, :updated_at]}

  schema "prompts" do
    field :name, :string
    field :description, :string

    has_many :versions, PromptVersion, foreign_key: :prompt_id

    timestamps type: :utc_datetime_usec
  end

  @doc """
  Creates a changeset for a prompt.
  """
  def changeset(prompt, attrs) do
    prompt
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 255)
    |> unique_constraint(:name)
  end
end
