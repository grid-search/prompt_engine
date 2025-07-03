defmodule PromptEngine.Test.LiteRepo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :prompt_engine,
    adapter: Ecto.Adapters.SQLite3

  # Future PostgreSQL repo for production testing
  # defmodule PromptEngine.Test.Repo do
  #   @moduledoc false
  #
  #   use Ecto.Repo,
  #     otp_app: :prompt_engine,
  #     adapter: Ecto.Adapters.Postgres
  # end

  # Future MySQL repo for alternative production testing
  # defmodule PromptEngine.Test.MySQLRepo do
  #   @moduledoc false
  #
  #   use Ecto.Repo,
  #     otp_app: :prompt_engine,
  #     adapter: Ecto.Adapters.MyXQL
  # end
end
