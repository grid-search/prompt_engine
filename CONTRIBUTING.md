# Contributing to PromptEngine

Thank you for your interest in contributing to PromptEngine! This document outlines the guidelines and processes for contributing to this project.

## Overview

PromptEngine is an Elixir library that provides a Phoenix/Ecto plugin for managing prompts with LiveView interface, versioning, and LLM integrations. It's designed to be installed into existing Phoenix applications via Igniter.

## Development Setup

### Prerequisites

- Elixir ~> 1.16
- Erlang/OTP 25+
- Git
- Docker (optional, for PostgreSQL testing)

### Getting Started

1. **Fork and clone the repository**
   ```bash
   git clone https://github.com/samcdavid/prompt_engine.git
   cd prompt_engine
   ```

2. **Install dependencies**
   ```bash
   mix deps.get
   ```

3. **Start PostgreSQL (optional, for database testing)**
   ```bash
   docker-compose up
   ```

## Development Workflow

### Code Quality Requirements

**CRITICAL**: All contributions must pass strict code quality checks:

- **Formatting**: Code must be properly formatted with `mix format`
- **Static Analysis**: Must pass `mix credo --strict` with no violations
- **Trailing Whitespace**: Must be trimmed from all files
- **Compile Warnings**: No compilation warnings allowed

### Development Commands

```bash
# Install/update dependencies
mix deps.get

# Run tests
mix test                    # All tests
mix test.lite              # SQLite tests only
mix test.postgres          # PostgreSQL tests only
mix test test/specific_test.exs:42  # Specific test

# Code quality (run before every commit)
mix lint                   # Development linting (formats + analyzes)
mix lint.ci               # CI-style strict checking
mix format                # Format code only
mix credo --strict        # Static analysis only
```

### Testing Strategy

- **SQLite**: Primary testing database for speed
- **PostgreSQL**: Additional testing for production compatibility
- **Test Coverage**: All new features must include comprehensive tests
- **Test Environment**: Lint commands run in `:test` environment

## Coding Standards

### Elixir Best Practices

#### Required Patterns
- **Namespace**: All modules must be prefixed with `PromptEngine.*`
- **Pattern Matching**: Use assertive pattern matching that crashes on unexpected inputs
- **Error Handling**: Use `{:ok, result}` / `{:error, reason}` tuples, not exceptions
- **Map Access**: Use `map.key` for required keys, `map[:key]` for optional keys
- **Boolean Logic**: Use `and`, `or`, `not` instead of `&&`, `||`, `!`

#### Anti-Patterns to Avoid
- **Dynamic Atom Creation**: Never create atoms from untrusted input
- **Primitive Obsession**: Use structs/maps instead of strings for everything
- **Large Structs**: Keep structs under 32 fields for performance
- **Long Parameter Lists**: Group related parameters in maps/structs
- **Global Config**: Pass options as function parameters, avoid application config
- **Unnecessary Macros**: Only use macros when absolutely necessary

### Process Guidelines
- **Supervision**: All long-running processes must be supervised
- **Message Efficiency**: Send minimal data in messages
- **Interface Centralization**: Centralize process interactions in single modules

## Contribution Process

### 1. Issue Discussion
- Check existing issues before creating new ones
- For major features, create an issue for discussion first
- For bugs, provide reproduction steps and environment details

### 2. Branch Strategy
- Create feature branches from `main`
- Use descriptive branch names: `feature/prompt-versioning`, `fix/memory-leak`
- Keep branches focused on single features/fixes

### 3. Commit Guidelines
- Write clear, descriptive commit messages
- Use conventional commit format when possible
- Keep commits atomic and focused

### 4. Pull Request Process

#### Before Submitting
1. **Run Quality Checks**
   ```bash
   mix lint.ci  # Must pass completely
   mix test     # All tests must pass
   ```

2. **Code Review Checklist**
   - [ ] All tests pass (`mix test`)
   - [ ] Code quality checks pass (`mix lint.ci`)
   - [ ] No trailing whitespace
   - [ ] Documentation updated if needed
   - [ ] Follows Elixir coding standards
   - [ ] No new compilation warnings

#### Pull Request Requirements
- **Title**: Clear, descriptive summary
- **Description**: Explain the change, why it's needed, and how it works
- **Testing**: Describe how the change was tested
- **Breaking Changes**: Clearly document any breaking changes
- **Documentation**: Update relevant documentation

### 5. Review Process
- All PRs require review from maintainers
- Address all feedback before merge
- Maintain a respectful, collaborative tone
- Be open to suggestions and improvements

## Architecture Guidelines

### Library Structure
- This is a **library package**, not a standalone application
- Must integrate cleanly with existing Phoenix applications
- Use Igniter for automated installation and setup

### Database Considerations
- Support both SQLite and PostgreSQL
- Use proper foreign key constraints and indexes
- UUID primary keys for all entities
- Embedded JSON for flexible configurations

### LLM Integration
- Support multiple providers (OpenAI, Anthropic, Google, Azure, HuggingFace)
- Use LangChain for provider abstraction
- Flexible model settings as JSON maps

## Release Process

1. **Version Bumping**: Follow semantic versioning
2. **Changelog**: Update CHANGELOG.md with notable changes
3. **Documentation**: Ensure all documentation is current
4. **Testing**: Full test suite must pass on all supported databases

## Getting Help

- **Issues**: Create GitHub issues for bugs or feature requests
- **Discussions**: Use GitHub Discussions for questions and ideas
- **Code Review**: Tag maintainers for urgent review needs

## License

By contributing to PromptEngine, you agree that your contributions will be licensed under the same license as the project.

---

Thank you for contributing to PromptEngine! Your efforts help make prompt management better for the entire Phoenix/Elixir community.