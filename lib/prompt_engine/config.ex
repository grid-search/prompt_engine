defmodule PromptEngine.Config do
  @moduledoc """
  Configuration module for PromptEngine.

  This module provides configuration management for the PromptEngine library.
  Configuration is read from the application environment using the standard
  Elixir pattern:

      # In config/config.exs
      config PromptEngine, repo: MyApp.Repo

  The adapter type is automatically detected from your repository's configuration.
  """

  @doc """
  Gets the configured repository module.

  Returns the repo module if configured, or raises an error if not found.
  """
  @spec repo!() :: module()
  def repo! do
    case repo() do
      {:ok, repo} -> repo
      {:error, reason} -> raise ArgumentError, reason
    end
  end

  @doc """
  Gets the configured repository module.

  Returns `{:ok, repo}` if configured, `{:error, reason}` if not found.
  """
  @spec repo() :: {:ok, module()} | {:error, String.t()}
  def repo do
    case Application.get_env(PromptEngine, :repo) do
      nil -> {:error, "PromptEngine repo not configured"}
      repo when is_atom(repo) -> {:ok, repo}
      _ -> {:error, "PromptEngine repo must be a module"}
    end
  end

  @doc """
  Detects the adapter type from the configured repository.

  Returns the adapter type (`:sqlite`, `:postgres`, `:mysql`) or `:unknown`.
  """
  @spec adapter() :: atom()
  def adapter do
    case repo() do
      {:ok, repo_module} -> detect_adapter_from_repo(repo_module)
      {:error, _} -> :unknown
    end
  end

  defp detect_adapter_from_repo(repo) do
    case repo.__adapter__() do
      Ecto.Adapters.SQLite3 -> :sqlite
      # TODO: Add support for additional adapters
      # Ecto.Adapters.Postgres -> :postgres
      # Ecto.Adapters.MyXQL -> :mysql
      _ -> :unknown
    end
  end
end
