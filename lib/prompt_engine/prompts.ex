defmodule PromptEngine.Prompts do
  @moduledoc """
  Context module for managing prompts and their versions.

  This module provides the main API for creating, updating, and managing
  prompts and their versions, including state transitions.
  """
  import Ecto.Query, warn: false

  alias PromptEngine.Prompts.{Prompt, PromptVersion}

  @doc """
  Returns the list of prompts.

  ## Examples

      iex> list_prompts()
      [%Prompt{}, ...]
  """
  def list_prompts(repo) do
    Prompt
    |> order_by([p], asc: p.name)
    |> repo.all()
  end

  @doc """
  Gets a single prompt by ID.

  Returns `nil` if the prompt does not exist.

  ## Examples

      iex> get_prompt(repo, 123)
      %Prompt{}
      
      iex> get_prompt(repo, 456)
      nil
  """
  def get_prompt(repo, id) do
    repo.get(Prompt, id)
  end

  @doc """
  Gets a single prompt by ID, raising if it does not exist.

  ## Examples

      iex> get_prompt!(repo, 123)
      %Prompt{}
      
      iex> get_prompt!(repo, 456)
      ** (Ecto.NoResultsError)
  """
  def get_prompt!(repo, id) do
    repo.get!(Prompt, id)
  end

  @doc """
  Gets a prompt by name.

  ## Examples

      iex> get_prompt_by_name(repo, "email_template")
      %Prompt{}
      
      iex> get_prompt_by_name(repo, "nonexistent")
      nil
  """
  def get_prompt_by_name(repo, name) do
    repo.get_by(Prompt, name: name)
  end

  @doc """
  Creates a prompt.

  ## Examples

      iex> create_prompt(repo, %{name: "test", provider: "openai"})
      {:ok, %Prompt{}}
      
      iex> create_prompt(repo, %{name: ""})
      {:error, %Ecto.Changeset{}}
  """
  def create_prompt(repo, attrs \\ %{}) do
    %Prompt{}
    |> Prompt.changeset(attrs)
    |> repo.insert()
  end

  @doc """
  Updates a prompt.

  ## Examples

      iex> update_prompt(repo, prompt, %{name: "new name"})
      {:ok, %Prompt{}}
      
      iex> update_prompt(repo, prompt, %{name: ""})
      {:error, %Ecto.Changeset{}}
  """
  def update_prompt(repo, %Prompt{} = prompt, attrs) do
    prompt
    |> Prompt.changeset(attrs)
    |> repo.update()
  end

  @doc """
  Deletes a prompt and all its versions.

  ## Examples

      iex> delete_prompt(repo, prompt)
      {:ok, %Prompt{}}
      
      iex> delete_prompt(repo, prompt)
      {:error, %Ecto.Changeset{}}
  """
  def delete_prompt(repo, %Prompt{} = prompt) do
    repo.delete(prompt)
  end

  @doc """
  Returns the list of versions for a prompt.

  ## Examples

      iex> list_prompt_versions(repo, prompt_id)
      [%PromptVersion{}, ...]
  """
  def list_prompt_versions(repo, prompt_id) do
    PromptVersion
    |> where([pv], pv.prompt_id == ^prompt_id)
    |> order_by([pv], desc: pv.version_number)
    |> repo.all()
  end

  @doc """
  Gets the published version of a prompt.

  ## Examples

      iex> get_published_version(repo, prompt_id)
      %PromptVersion{}
      
      iex> get_published_version(repo, prompt_id)
      nil
  """
  def get_published_version(repo, prompt_id) do
    repo.get_by(PromptVersion, prompt_id: prompt_id, state: :published)
  end

  @doc """
  Gets the latest version of a prompt (highest version number).

  ## Examples

      iex> get_latest_version(repo, prompt_id)
      %PromptVersion{}
      
      iex> get_latest_version(repo, prompt_id)
      nil
  """
  def get_latest_version(repo, prompt_id) do
    PromptVersion
    |> where([pv], pv.prompt_id == ^prompt_id)
    |> order_by([pv], desc: pv.version_number)
    |> limit(1)
    |> repo.one()
  end

  @doc """
  Gets a specific version of a prompt.

  ## Examples

      iex> get_prompt_version(repo, prompt_id, 1)
      %PromptVersion{}
      
      iex> get_prompt_version(repo, prompt_id, 999)
      nil
  """
  def get_prompt_version(repo, prompt_id, version_number) do
    repo.get_by(PromptVersion, prompt_id: prompt_id, version_number: version_number)
  end

  @doc """
  Creates a new version of a prompt.
  The version number is automatically set to the next available number.

  ## Examples

      iex> create_prompt_version(repo, prompt_id, %{provider: :openai, content: "Hello", model_name: "gpt-4"})
      {:ok, %PromptVersion{}}
  """
  def create_prompt_version(repo, prompt_id, attrs) do
    next_version = get_next_version_number(repo, prompt_id)

    attrs = Map.put(attrs, :version_number, next_version)

    %PromptVersion{}
    |> PromptVersion.changeset(Map.put(attrs, :prompt_id, prompt_id))
    |> repo.insert()
  end

  defp get_next_version_number(repo, prompt_id) do
    PromptVersion
    |> where([pv], pv.prompt_id == ^prompt_id)
    |> select([pv], max(pv.version_number))
    |> repo.one()
    |> case do
      nil -> 1
      max_version -> max_version + 1
    end
  end

  @doc """
  Publishes a prompt version, unpublishing any previously published version.

  ## Examples

      iex> publish_version(repo, prompt_version)
      {:ok, %PromptVersion{}}
  """
  def publish_version(repo, %PromptVersion{} = version) do
    repo.transaction(fn ->
      # Unpublish any currently published version
      PromptVersion
      |> where([pv], pv.prompt_id == ^version.prompt_id)
      |> where([pv], pv.state == :published)
      |> repo.update_all(set: [state: :archived, updated_at: DateTime.utc_now()])

      # Publish this version
      version
      |> PromptVersion.publish_changeset()
      |> repo.update()
      |> case do
        {:ok, updated_version} -> updated_version
        {:error, changeset} -> repo.rollback(changeset)
      end
    end)
  end

  @doc """
  Archives a prompt version.

  ## Examples

      iex> archive_version(repo, prompt_version)
      {:ok, %PromptVersion{}}
  """
  def archive_version(repo, %PromptVersion{} = version) do
    version
    |> PromptVersion.archive_changeset()
    |> repo.update()
  end

  @doc """
  Sets a prompt version to draft state.

  ## Examples

      iex> draft_version(repo, prompt_version)
      {:ok, %PromptVersion{}}
  """
  def draft_version(repo, %PromptVersion{} = version) do
    version
    |> PromptVersion.draft_changeset()
    |> repo.update()
  end
end
