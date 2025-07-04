defmodule PromptEngine.Prompts.PromptVersion.MessageTest do
  use PromptEngine.Case, async: true

  alias PromptEngine.Prompts.PromptVersion.Message

  describe "changeset/2" do
    test "valid changeset with system role" do
      attrs = %{role: :system, content: "You are a helpful assistant."}
      changeset = Message.changeset(%Message{}, attrs)

      assert changeset.valid?
      assert changeset.changes.role == :system
      assert changeset.changes.content == "You are a helpful assistant."
    end

    test "valid changeset with assistant role" do
      attrs = %{role: :assistant, content: "Hello! How can I help you today?"}
      changeset = Message.changeset(%Message{}, attrs)

      assert changeset.valid?
      assert changeset.changes.role == :assistant
      assert changeset.changes.content == "Hello! How can I help you today?"
    end

    test "valid changeset with user role" do
      attrs = %{role: :user, content: "What is the weather like?"}
      changeset = Message.changeset(%Message{}, attrs)

      assert changeset.valid?
      assert changeset.changes.role == :user
      assert changeset.changes.content == "What is the weather like?"
    end

    test "valid changeset with tool role" do
      attrs = %{role: :tool, content: "Weather data retrieved successfully."}
      changeset = Message.changeset(%Message{}, attrs)

      assert changeset.valid?
      assert changeset.changes.role == :tool
      assert changeset.changes.content == "Weather data retrieved successfully."
    end

    test "invalid changeset without role" do
      attrs = %{content: "Hello, world!"}
      changeset = Message.changeset(%Message{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).role
    end

    test "invalid changeset without content" do
      attrs = %{role: :user}
      changeset = Message.changeset(%Message{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).content
    end

    test "invalid changeset with empty content" do
      attrs = %{role: :user, content: ""}
      changeset = Message.changeset(%Message{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).content
    end

    test "invalid changeset with invalid role" do
      attrs = %{role: :invalid_role, content: "Hello, world!"}
      changeset = Message.changeset(%Message{}, attrs)

      refute changeset.valid?
      assert "is invalid" in errors_on(changeset).role
    end

    test "valid role values" do
      roles = [:system, :assistant, :user, :tool]

      for role <- roles do
        attrs = %{role: role, content: "Test content"}
        changeset = Message.changeset(%Message{}, attrs)
        assert changeset.valid?, "Role #{role} should be valid"
      end
    end
  end

  describe "Jason.Encoder" do
    test "encodes role and content fields" do
      message = %Message{role: :user, content: "Hello, world!"}
      encoded = Jason.encode!(message)
      decoded = Jason.decode!(encoded)

      assert decoded["role"] == "user"
      assert decoded["content"] == "Hello, world!"
    end

    test "encodes all role types correctly" do
      messages = [
        %Message{role: :system, content: "System message"},
        %Message{role: :assistant, content: "Assistant message"},
        %Message{role: :user, content: "User message"},
        %Message{role: :tool, content: "Tool message"}
      ]

      for message <- messages do
        encoded = Jason.encode!(message)
        decoded = Jason.decode!(encoded)

        assert decoded["role"] == to_string(message.role)
        assert decoded["content"] == message.content
      end
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
