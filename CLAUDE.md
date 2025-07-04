# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PromptEngine is an **Elixir library** (not a standalone application) designed as a Phoenix/Ecto plugin similar to Oban Web. It provides a LiveView interface for managing prompts within Phoenix applications, with features for versioning, publishing, and executing prompts through LangChain LLM integrations.

**Installation Method**: Uses Igniter for automated installation via `mix igniter.install prompt_engine`

## Development Commands

### Core Development
- `mix deps.get` - Install/update dependencies
- `mix test` - Run test suite
- `mix test test/specific_test.exs` - Run specific test file
- `mix test test/specific_test.exs:42` - Run test at specific line

### Code Quality (Custom Aliases)
- `mix lint` - Development linting (formats code, runs Credo strict)
- `mix lint.ci` - CI/CD strict linting (checks formatting, runs Credo strict)
- `mix format` - Format code
- `mix credo --strict` - Static code analysis

### Igniter Integration
- `mix igniter.install prompt_engine` - Install this library into a Phoenix app
- Available Igniter tasks can be found with `mix help | grep igniter`

## Architecture

### Library Structure
This is a **library package** that gets installed into existing Phoenix applications, not a standalone app. Key architectural decisions:

- **Phoenix LiveView Integration**: Uses LiveView for real-time prompt management interface
- **Database Integration**: Ecto/SQLite for prompt storage and versioning (PostgreSQL support planned)
- **LLM Integration**: LangChain for executing prompts with various LLM providers  
- **MCP Tools Support**: Allows specifying Model Context Protocol tools that prompts can access
- **Installation Automation**: Igniter handles automatic setup and database migrations

### Data Model Architecture

**Prompt Management:**
- **Prompts**: Top-level containers with name and description
- **Prompt Versions**: Versioned instances with LLM configuration and state management
- **Messages**: Embedded schemas for conversation structure (system, user, assistant, tool roles)

**State Management:**
- Draft → Published → Archived workflow
- Only one published version per prompt allowed
- Automatic version numbering

**Provider Support:**
- OpenAI, Anthropic, Google, Azure, HuggingFace
- Flexible model settings as JSON maps
- Provider-specific optimizations

**Database Schema:**
- UUID primary keys for all entities
- Proper foreign key constraints and indexes
- Embedded JSON for messages and model settings
- Unique constraints for business rules (one published version per prompt)

### Key Dependencies
- **Phoenix LiveView 1.0+**: Real-time UI framework
- **Ecto SQL 3.12+**: Database toolkit and adapters
- **LangChain 0.3+**: LLM provider integrations
- **Igniter 0.6+**: Installation automation and project patching
- **Jason**: JSON handling
- **Telemetry**: Application monitoring
- **Ecto SQLite3**: SQLite adapter for testing (PostgreSQL for production)

### Configuration Notes
- **Test Environment**: Lint commands run in `:test` environment
- **Elixir Version**: Requires Elixir ~> 1.16
- **Database Support**: Currently SQLite for testing, PostgreSQL support planned

## Required Practices

### Code Quality Enforcement
**CRITICAL**: Always run `mix lint` before completing any task. All changes must pass:
- ALWAYS TRIM TRAILING WHITESPACE!!!
- Code formatting (`mix format --check-formatted`)
- Static analysis (`mix credo --strict`)

### Elixir Anti-Patterns to Avoid

#### Code Anti-Patterns
- **No Dynamic Atom Creation**: Never create atoms from untrusted user input
- **Assertive Code**: Use pattern matching that crashes on unexpected inputs rather than generic catch-alls
- **Map Access**: Use `map.key` for required keys, `map[:key]` for optional keys
- **Boolean Operations**: Use `and`, `or`, `not` for boolean logic, not `&&`, `||`, `!`
- **Namespace Respect**: Always prefix modules with library name (`PromptEngine.*`)
- **Struct Size Limit**: Keep structs under 32 fields for performance
- **Parameter Lists**: Use maps/structs to group related parameters instead of long parameter lists

#### Design Anti-Patterns
- **Single-Purpose Functions**: Create separate functions for different return types instead of option-driven behavior
- **Structured Data**: Use structs/maps instead of primitive obsession (strings for everything)
- **Exception Usage**: Use `{:ok, result}` / `{:error, reason}` tuples, not exceptions for control flow
- **State Representation**: Use atoms or composite types instead of boolean obsession
- **Function Responsibility**: Split unrelated multi-clause functions into separate, clearly named functions
- **Library Configuration**: Pass options as function parameters, avoid global application config

#### Process Anti-Patterns
- **Process Purpose**: Use processes for concurrency/error isolation, not code organization
- **Supervision**: All long-running processes must be supervised
- **Message Efficiency**: Send minimal data in messages, let receivers fetch additional data
- **Interface Centralization**: Centralize process interactions in single modules

#### Macro Anti-Patterns
- **Macro Necessity**: Only use macros when absolutely necessary, prefer functions
- **Code Generation**: Keep generated code minimal, delegate to functions
- **Compile Dependencies**: Use `Macro.expand_literals()` to limit compile-time dependencies
- **Clear Documentation**: Document what `use` macros inject into modules
