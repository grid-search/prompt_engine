defmodule PromptEngine.Prompts.PromptVersion.Message do
  @moduledoc """
  Embedded schema for storing individual messages within a prompt version.

  Messages represent individual parts of a conversation or prompt structure,
  each with a specific role (system, assistant, user, tool) and content.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type role :: :system | :assistant | :user | :tool
  @type t :: %__MODULE__{
          role: role(),
          content: String.t()
        }

  @roles ~w(system assistant user tool)a

  @derive {Jason.Encoder, only: [:role, :content]}

  embedded_schema do
    field :role, Ecto.Enum, values: @roles
    field :content, :string
  end

  @doc """
  Creates a changeset for a message.
  """
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:role, :content])
    |> validate_required([:role, :content])
    |> validate_length(:content, min: 1)
  end
end
