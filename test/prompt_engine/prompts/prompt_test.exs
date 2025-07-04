defmodule PromptEngine.Prompts.PromptTest do
  use PromptEngine.Case, async: true

  alias PromptEngine.Prompts.Prompt

  describe "changeset/2" do
    test "valid changeset with required fields" do
      attrs = %{name: "test_prompt", description: "A test prompt"}
      changeset = Prompt.changeset(%Prompt{}, attrs)

      assert changeset.valid?
      assert changeset.changes.name == "test_prompt"
      assert changeset.changes.description == "A test prompt"
    end

    test "valid changeset with only name" do
      attrs = %{name: "minimal_prompt"}
      changeset = Prompt.changeset(%Prompt{}, attrs)

      assert changeset.valid?
      assert changeset.changes.name == "minimal_prompt"
    end

    test "invalid changeset without name" do
      attrs = %{description: "No name provided"}
      changeset = Prompt.changeset(%Prompt{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).name
    end

    test "invalid changeset with empty name" do
      attrs = %{name: ""}
      changeset = Prompt.changeset(%Prompt{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).name
    end

    test "invalid changeset with name too long" do
      attrs = %{name: String.duplicate("a", 256)}
      changeset = Prompt.changeset(%Prompt{}, attrs)

      refute changeset.valid?
      assert "should be at most 255 character(s)" in errors_on(changeset).name
    end

    test "invalid changeset with duplicate name" do
      # This would require database setup to test unique constraint
      # For now, we just verify the constraint exists
      changeset = Prompt.changeset(%Prompt{}, %{name: "test"})
      unique_constraint = List.first(changeset.constraints)
      assert unique_constraint.constraint == "prompts_name_index"
      assert unique_constraint.field == :name
      assert unique_constraint.type == :unique
    end
  end

  describe "Jason.Encoder" do
    test "encodes only specified fields" do
      prompt = %Prompt{
        id: "550e8400-e29b-41d4-a716-446655440000",
        name: "test_prompt",
        description: "A test prompt",
        inserted_at: ~U[2024-01-01 00:00:00.000000Z],
        updated_at: ~U[2024-01-01 00:00:00.000000Z],
        versions: []
      }

      encoded = Jason.encode!(prompt)
      decoded = Jason.decode!(encoded)

      assert decoded["id"] == "550e8400-e29b-41d4-a716-446655440000"
      assert decoded["name"] == "test_prompt"
      assert decoded["description"] == "A test prompt"
      assert decoded["inserted_at"] == "2024-01-01T00:00:00.000000Z"
      assert decoded["updated_at"] == "2024-01-01T00:00:00.000000Z"

      # Verify associations are not included
      refute Map.has_key?(decoded, "versions")
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
