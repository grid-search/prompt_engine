defmodule PromptEngine.Test.LiteRepo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :prompt_engine,
    adapter: Ecto.Adapters.SQLite3
end

defmodule PromptEngine.Test.LiteMigrationRepo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :prompt_engine,
    adapter: Ecto.Adapters.SQLite3

  alias PromptEngine.Test.LiteRepo

  def init(_, _) do
    config = LiteRepo.config()
    {:ok, Keyword.put(config, :database, "priv/prompt_engine_migration_test.db")}
  end
end

defmodule PromptEngine.Test.PGRepo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :prompt_engine,
    adapter: Ecto.Adapters.Postgres
end

defmodule PromptEngine.Test.PGMigrationRepo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :prompt_engine,
    adapter: Ecto.Adapters.Postgres

  alias PromptEngine.Test.PGRepo

  def init(_, _) do
    config = PGRepo.config()
    {:ok, Keyword.put(config, :database, "prompt_engine_migration_test")}
  end
end

# Future MySQL repos for alternative production testing
# defmodule PromptEngine.Test.MySQLRepo do
#   @moduledoc false
#
#   use Ecto.Repo,
#     otp_app: :prompt_engine,
#     adapter: Ecto.Adapters.MyXQL
# end

# defmodule PromptEngine.Test.MySQLMigrationRepo do
#   @moduledoc false
#
#   use Ecto.Repo,
#     otp_app: :prompt_engine,
#     adapter: Ecto.Adapters.MyXQL
#
#   def init(_, _) do
#     config = PromptEngine.Test.MySQLRepo.config()
#     {:ok, Keyword.put(config, :database, "prompt_engine_migration_test")}
#   end
# end
