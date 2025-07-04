# Configure PromptEngine for testing
Application.put_env(PromptEngine, :repo, PromptEngine.Test.LiteRepo)

# Ensure PostgreSQL driver is started
Application.ensure_all_started(:postgrex)

# Start all test repos
PromptEngine.Test.LiteRepo.start_link()
PromptEngine.Test.PGRepo.start_link()
PromptEngine.Test.LiteMigrationRepo.start_link()
PromptEngine.Test.PGMigrationRepo.start_link()

# Future MySQL repo startup:
# PromptEngine.Test.MySQLRepo.start_link()
# PromptEngine.Test.MySQLMigrationRepo.start_link()

# Run migrations for PostgreSQL repos BEFORE setting up sandbox
# This ensures tables exist before tests run
Application.put_env(PromptEngine, :repo, PromptEngine.Test.PGRepo)
Ecto.Migrator.run(PromptEngine.Test.PGRepo, :up, all: true)

# Configure SQL Sandbox for PostgreSQL repos AFTER migrations
Ecto.Adapters.SQL.Sandbox.mode(PromptEngine.Test.PGRepo, :manual)

# Use shared mode for migration repo since migration tests use Ecto.Migrator which runs in separate processes
Ecto.Adapters.SQL.Sandbox.mode(PromptEngine.Test.PGMigrationRepo, :auto)

ExUnit.start()
