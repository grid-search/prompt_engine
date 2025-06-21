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
