defmodule PromptEngine.Schema do
  @moduledoc """
  Base schema module for PromptEngine schemas.

  Provides common configuration for primary keys and foreign keys,
  ensuring consistency across all PromptEngine schemas.

  ## Usage

      defmodule MyApp.Schema do
        use PromptEngine.Schema
        
        schema "my_table" do
          # Schema definition here
        end
      end
  """

  defmacro __using__(_opts) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
    end
  end
end
