# PromptEngine

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/grid-search/prompt_engine/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/grid-search/prompt_engine/tree/main)

A Phoenix/Ecto plugin for managing prompts with versioning, publishing, and LLM execution capabilities.

## Overview

PromptEngine is similar to Oban Web in that it provides a LiveView interface for managing prompts within your Phoenix applications. It offers:

- **Prompt Management**: Create, update, and organize prompts with descriptive metadata
- **Versioning System**: Multiple versions per prompt with draft/published/archived states
- **LLM Integration**: Execute prompts through LangChain with support for multiple providers (OpenAI, Anthropic, Google, Azure, HuggingFace)
- **MCP Tools Support**: Specify Model Context Protocol tools that prompts can access
- **Database Storage**: Persistent storage with automatic migrations
- **Live Updates**: Real-time interface updates with Phoenix LiveView

## Installation

Install PromptEngine using Igniter for automated setup:

```bash
mix igniter.install prompt_engine
```

This will:
- Add `prompt_engine` to your `mix.exs` dependencies
- Set up the necessary configuration in your Phoenix application
- Create database migrations for prompt storage
- Configure LangChain integration

### Manual Installation

Alternatively, add `prompt_engine` to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:prompt_engine, "~> 0.1.0"}
  ]
end
```

## Usage

### Basic Prompt Management

```elixir
# Create a new prompt
{:ok, prompt} = PromptEngine.Prompts.create_prompt(repo, %{
  name: "email_template",
  description: "Customer email template"
})

# Create a version of the prompt
{:ok, version} = PromptEngine.Prompts.create_prompt_version(repo, prompt.id, %{
  provider: :openai,
  model_name: "gpt-4",
  messages: [
    %{role: :system, content: "You are a helpful assistant."},
    %{role: :user, content: "Write a professional email."}
  ],
  model_settings: %{temperature: 0.7}
})

# Publish the version
{:ok, published_version} = PromptEngine.Prompts.publish_version(repo, version)
```

### Version Management

```elixir
# Get the published version
published = PromptEngine.Prompts.get_published_version(repo, prompt.id)

# Get the latest version
latest = PromptEngine.Prompts.get_latest_version(repo, prompt.id)

# List all versions
versions = PromptEngine.Prompts.list_prompt_versions(repo, prompt.id)

# Archive a version
{:ok, archived} = PromptEngine.Prompts.archive_version(repo, version)
```

## Architecture

### Core Components

- **Prompts**: Top-level containers with name and description
- **Prompt Versions**: Versioned instances with LLM configuration
- **Messages**: Individual conversation parts (system, user, assistant, tool)
- **State Management**: Draft → Published → Archived workflow

### Database Schema

```elixir
# Prompts table
%Prompt{
  id: UUID,
  name: String,
  description: String,
  versions: [PromptVersion]
}

# Prompt Versions table
%PromptVersion{
  id: UUID,
  prompt_id: UUID,
  version_number: Integer,
  state: :draft | :published | :archived,
  provider: :openai | :anthropic | :google | :azure | :huggingface,
  messages: [Message],
  model_name: String,
  model_settings: Map
}
```

## License

This project is licensed under the Mozilla Public License 2.0. See the [LICENSE](LICENSE) file for details.

## Database Support

PromptEngine supports **SQLite** and **PostgreSQL** for all environments. Users can choose their preferred database based on their application needs.

## Database Roadmap

### Phase 1: SQLite Foundation (Current)
- ✅ SQLite adapter for all environments
- ✅ Core schema and migrations
- ✅ Full CRUD operations
- ✅ Version management and state transitions

### Phase 2: PostgreSQL Support (Current)
- ✅ PostgreSQL adapter support for all environments
- ✅ Production-ready migrations
- ✅ Identical behavior across database engines

### Phase 3: MySQL Support (Future)
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
