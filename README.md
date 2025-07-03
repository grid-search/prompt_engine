# PromptEngine

> [!WARNING]
>
> This is still experimental. Do not use or install.

## Project goal

This package is similar to Oban Web in that it is a plugin for phoenix and ecto
projects to provide a live view for managing prompts within your application.
Prompts will be versioned, publishable, and executable through the live view
and allow for specifying MCP tools that the prompt may access as well as
specifying variable values to make iteration easier. Install with

```
mix igniter.install prompt_engine
```

This will ensure that prompt engine is added to your mix.exs file and properly
setup in your phoenix application. Prompts will be executed using lang chain so
that you may integrate with your desired LLM providers. This will also create
the necessary database migration for storing prompts in your database.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `prompt_engine` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:prompt_engine, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/prompt_engine>.

## Database Support

### Current Implementation
PromptEngine currently supports **SQLite** for development and testing environments. This provides a lightweight, zero-configuration database solution that works well for:
- Local development and testing
- CI/CD pipelines
- Simple deployments

### Database Roadmap

**Phase 1: SQLite Foundation (Current)**
- ✅ SQLite adapter for testing
- ✅ Core schema and migrations
- ✅ Full CRUD operations
- ✅ Version management and state transitions

**Phase 2: PostgreSQL Support (Planned)**
- Primary production database support
- Advanced indexing and performance optimizations
- JSONB support for model settings
- Concurrent testing with SQL.Sandbox
- Production-ready migrations

**Phase 3: MySQL Support (Future)**
- Alternative production database option
- MySQL-specific optimizations
- Cross-database compatibility testing

### Testing Strategy

PromptEngine implements a multi-database testing architecture:

- **Context-based testing**: Use `@tag :lite` for SQLite-specific tests
- **Shared test modules**: Database-agnostic tests run against all supported databases
- **Migration compatibility**: Ensure identical behavior across database engines
- **Performance benchmarking**: Compare query performance across databases

### Migration Compatibility

All database migrations are designed to be compatible across supported databases:
- SQLite migrations delegate to shared migration modules
- PostgreSQL-specific optimizations (indexes, constraints) are conditionally applied
- MySQL compatibility ensured through careful schema design

This approach ensures that your prompts and their versions behave identically regardless of the underlying database engine.
