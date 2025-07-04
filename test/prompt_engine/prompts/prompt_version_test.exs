defmodule PromptEngine.Prompts.PromptVersionTest do
  use PromptEngine.Case, async: true

  alias PromptEngine.Prompts.PromptVersion

  describe "changeset/2" do
    test "valid changeset with all required fields" do
      attrs = %{
        prompt_id: "550e8400-e29b-41d4-a716-446655440000",
        version_number: 1,
        provider: :openai,
        content: "Hello, world!",
        model_name: "gpt-4",
        model_settings: %{temperature: 0.7}
      }

      changeset = PromptVersion.changeset(%PromptVersion{}, attrs)

      assert changeset.valid?
      assert changeset.changes.prompt_id == "550e8400-e29b-41d4-a716-446655440000"
      assert changeset.changes.version_number == 1
      assert changeset.changes.provider == :openai
      assert changeset.changes.content == "Hello, world!"
      assert changeset.changes.model_name == "gpt-4"
      assert changeset.changes.model_settings == %{temperature: 0.7}
    end

    test "valid changeset with minimal required fields" do
      attrs = %{
        prompt_id: "550e8400-e29b-41d4-a716-446655440000",
        version_number: 1,
        provider: :anthropic,
        content: "Test content",
        model_name: "claude-3-sonnet"
      }

      changeset = PromptVersion.changeset(%PromptVersion{}, attrs)

      assert changeset.valid?
      # Default values are set in the schema, not in changeset.changes
      # unless explicitly provided in attrs
    end

    test "invalid changeset without prompt_id" do
      attrs = %{version_number: 1, provider: :openai, content: "Test", model_name: "gpt-4"}
      changeset = PromptVersion.changeset(%PromptVersion{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).prompt_id
    end

    test "invalid changeset without version_number" do
      attrs = %{
        prompt_id: "550e8400-e29b-41d4-a716-446655440000",
        provider: :openai,
        content: "Test",
        model_name: "gpt-4"
      }

      changeset = PromptVersion.changeset(%PromptVersion{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).version_number
    end

    test "invalid changeset without provider" do
      attrs = %{
        prompt_id: "550e8400-e29b-41d4-a716-446655440000",
        version_number: 1,
        content: "Test",
        model_name: "gpt-4"
      }

      changeset = PromptVersion.changeset(%PromptVersion{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).provider
    end

    test "invalid changeset without content" do
      attrs = %{
        prompt_id: "550e8400-e29b-41d4-a716-446655440000",
        version_number: 1,
        provider: :openai,
        model_name: "gpt-4"
      }

      changeset = PromptVersion.changeset(%PromptVersion{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).content
    end

    test "invalid changeset without model_name" do
      attrs = %{
        prompt_id: "550e8400-e29b-41d4-a716-446655440000",
        version_number: 1,
        provider: :openai,
        content: "Test content"
      }

      changeset = PromptVersion.changeset(%PromptVersion{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).model_name
    end

    test "invalid changeset with zero version_number" do
      attrs = %{
        prompt_id: "550e8400-e29b-41d4-a716-446655440000",
        version_number: 0,
        provider: :openai,
        content: "Test",
        model_name: "gpt-4"
      }

      changeset = PromptVersion.changeset(%PromptVersion{}, attrs)

      refute changeset.valid?
      assert "must be greater than 0" in errors_on(changeset).version_number
    end

    test "invalid changeset with negative version_number" do
      attrs = %{
        prompt_id: "550e8400-e29b-41d4-a716-446655440000",
        version_number: -1,
        provider: :openai,
        content: "Test",
        model_name: "gpt-4"
      }

      changeset = PromptVersion.changeset(%PromptVersion{}, attrs)

      refute changeset.valid?
      assert "must be greater than 0" in errors_on(changeset).version_number
    end

    test "invalid changeset with empty content" do
      attrs = %{
        prompt_id: "550e8400-e29b-41d4-a716-446655440000",
        version_number: 1,
        provider: :openai,
        content: "",
        model_name: "gpt-4"
      }

      changeset = PromptVersion.changeset(%PromptVersion{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).content
    end

    test "invalid changeset with model_name too long" do
      attrs = %{
        prompt_id: "550e8400-e29b-41d4-a716-446655440000",
        version_number: 1,
        provider: :openai,
        content: "Test",
        model_name: String.duplicate("a", 256)
      }

      changeset = PromptVersion.changeset(%PromptVersion{}, attrs)

      refute changeset.valid?
      assert "should be at most 255 character(s)" in errors_on(changeset).model_name
    end

    test "invalid changeset with invalid provider" do
      attrs = %{
        prompt_id: "550e8400-e29b-41d4-a716-446655440000",
        version_number: 1,
        provider: :invalid_provider,
        content: "Test",
        model_name: "gpt-4"
      }

      changeset = PromptVersion.changeset(%PromptVersion{}, attrs)

      refute changeset.valid?
      assert "is invalid" in errors_on(changeset).provider
    end

    test "valid provider values" do
      providers = [:openai, :anthropic, :google, :azure, :huggingface]

      for provider <- providers do
        attrs = %{
          prompt_id: "550e8400-e29b-41d4-a716-446655440000",
          version_number: 1,
          provider: provider,
          content: "Test",
          model_name: "test-model"
        }

        changeset = PromptVersion.changeset(%PromptVersion{}, attrs)
        assert changeset.valid?, "Provider #{provider} should be valid"
      end
    end

    test "invalid changeset with invalid state" do
      attrs = %{
        prompt_id: "550e8400-e29b-41d4-a716-446655440000",
        version_number: 1,
        provider: :openai,
        content: "Test",
        model_name: "gpt-4",
        state: :invalid_state
      }

      changeset = PromptVersion.changeset(%PromptVersion{}, attrs)

      refute changeset.valid?
      assert "is invalid" in errors_on(changeset).state
    end

    test "valid state values" do
      states = [:draft, :published, :archived]

      for state <- states do
        attrs = %{
          prompt_id: "550e8400-e29b-41d4-a716-446655440000",
          version_number: 1,
          provider: :openai,
          content: "Test",
          model_name: "gpt-4",
          state: state
        }

        changeset = PromptVersion.changeset(%PromptVersion{}, attrs)
        assert changeset.valid?, "State #{state} should be valid"
      end
    end
  end

  describe "publish_changeset/1" do
    test "sets state to published" do
      version = %PromptVersion{state: :draft}
      changeset = PromptVersion.publish_changeset(version)

      assert changeset.changes.state == :published
    end

    test "includes unique constraint for published state" do
      version = %PromptVersion{state: :draft}
      changeset = PromptVersion.publish_changeset(version)

      unique_constraint = Enum.find(changeset.constraints, &(&1.type == :unique))
      assert unique_constraint.constraint == "prompt_versions_unique_published_per_prompt"
      assert unique_constraint.error_message == "only one version per prompt can be published"
    end
  end

  describe "archive_changeset/1" do
    test "sets state to archived" do
      version = %PromptVersion{state: :published}
      changeset = PromptVersion.archive_changeset(version)

      assert changeset.changes.state == :archived
    end
  end

  describe "draft_changeset/1" do
    test "sets state to draft" do
      version = %PromptVersion{state: :published}
      changeset = PromptVersion.draft_changeset(version)

      assert changeset.changes.state == :draft
    end
  end

  describe "Jason.Encoder" do
    test "encodes all specified fields including provider" do
      version = %PromptVersion{
        id: "550e8400-e29b-41d4-a716-446655440001",
        prompt_id: "550e8400-e29b-41d4-a716-446655440000",
        version_number: 1,
        state: :published,
        provider: :openai,
        content: "Hello, world!",
        model_name: "gpt-4",
        model_settings: %{temperature: 0.7},
        inserted_at: ~U[2024-01-01 00:00:00.000000Z],
        updated_at: ~U[2024-01-01 00:00:00.000000Z],
        prompt: nil
      }

      encoded = Jason.encode!(version)
      decoded = Jason.decode!(encoded)

      assert decoded["id"] == "550e8400-e29b-41d4-a716-446655440001"
      assert decoded["prompt_id"] == "550e8400-e29b-41d4-a716-446655440000"
      assert decoded["version_number"] == 1
      assert decoded["state"] == "published"
      assert decoded["provider"] == "openai"
      assert decoded["content"] == "Hello, world!"
      assert decoded["model_name"] == "gpt-4"
      assert decoded["model_settings"] == %{"temperature" => 0.7}
      assert decoded["inserted_at"] == "2024-01-01T00:00:00.000000Z"
      assert decoded["updated_at"] == "2024-01-01T00:00:00.000000Z"

      # Verify associations are not included
      refute Map.has_key?(decoded, "prompt")
    end
  end

  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
