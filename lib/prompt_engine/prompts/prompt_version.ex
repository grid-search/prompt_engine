defmodule PromptEngine.Prompts.PromptVersion do
  @moduledoc """
  Schema for storing versions of prompts.

  Each prompt can have multiple versions, but only one can be published at a time.
  Versions can be in draft, published, or archived state.
  """
  use PromptEngine.Schema

  alias PromptEngine.Prompts.Prompt
  alias PromptEngine.Prompts.PromptVersion.Message

  @type state :: :draft | :published | :archived
  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          prompt_id: Ecto.UUID.t(),
          prompt: Prompt.t(),
          version_number: pos_integer(),
          state: state(),
          provider: atom(),
          messages: [Message.t()],
          model_name: String.t(),
          model_settings: map(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @states ~w(draft published archived)a
  @providers ~w(openai anthropic google azure huggingface)a

  @derive {Jason.Encoder,
           only: [
             :id,
             :prompt_id,
             :version_number,
             :state,
             :provider,
             :messages,
             :model_name,
             :model_settings,
             :inserted_at,
             :updated_at
           ]}

  schema "prompt_versions" do
    field :version_number, :integer
    field :state, Ecto.Enum, values: @states, default: :draft
    field :provider, Ecto.Enum, values: @providers
    embeds_many :messages, Message
    field :model_name, :string
    field :model_settings, :map, default: %{}

    belongs_to :prompt, Prompt, foreign_key: :prompt_id

    timestamps type: :utc_datetime_usec
  end

  @doc """
  Creates a changeset for a prompt version.
  """
  def changeset(prompt_version, attrs) do
    prompt_version
    |> cast(attrs, [
      :prompt_id,
      :version_number,
      :state,
      :provider,
      :model_name,
      :model_settings
    ])
    |> cast_embed(:messages, required: true)
    |> validate_required([:prompt_id, :version_number, :provider, :model_name])
    |> validate_number(:version_number, greater_than: 0)
    |> validate_length(:messages, min: 1)
    |> validate_length(:model_name, min: 1, max: 255)
    |> unique_constraint([:prompt_id, :version_number])
    |> foreign_key_constraint(:prompt_id)
  end

  @doc """
  Creates a changeset for publishing a version.
  This ensures only one version per prompt can be published.
  """
  def publish_changeset(prompt_version) do
    prompt_version
    |> change(state: :published)
    |> unique_constraint(:prompt_id,
      name: :prompt_versions_unique_published_per_prompt,
      message: "only one version per prompt can be published"
    )
  end

  @doc """
  Creates a changeset for archiving a version.
  """
  def archive_changeset(prompt_version) do
    change(prompt_version, state: :archived)
  end

  @doc """
  Creates a changeset for setting a version to draft.
  """
  def draft_changeset(prompt_version) do
    change(prompt_version, state: :draft)
  end
end
