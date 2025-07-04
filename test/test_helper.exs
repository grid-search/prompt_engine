# Configure PromptEngine for testing
Application.put_env(PromptEngine, :repo, PromptEngine.Test.LiteRepo)

# Start SQLite repo for testing
PromptEngine.Test.LiteRepo.start_link()

# Future PostgreSQL repo startup:
# PromptEngine.Test.Repo.start_link()

# Future MySQL repo startup:
# PromptEngine.Test.MySQLRepo.start_link()

ExUnit.start()
