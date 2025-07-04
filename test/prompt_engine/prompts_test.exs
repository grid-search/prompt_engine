defmodule PromptEngine.PromptsTest do
  use PromptEngine.Case, async: true

  @moduletag :lite

  # Future tags for multi-database testing:
  # @moduletag :postgres
  # @moduletag :mysql

  alias PromptEngine.Prompts

  # Migrations are handled by the test case setup

  describe "prompt management with SQLite" do
    test "create, read, update, delete prompt" do
      # Create
      {:ok, prompt} =
        create_prompt(LiteRepo, %{name: "test_integration", description: "Integration test"})

      assert prompt.name == "test_integration"
      assert prompt.description == "Integration test"

      # Read
      found_prompt = Prompts.get_prompt(LiteRepo, prompt.id)
      assert found_prompt.id == prompt.id
      assert found_prompt.name == "test_integration"

      # Update
      {:ok, updated_prompt} =
        Prompts.update_prompt(LiteRepo, prompt, %{description: "Updated description"})

      assert updated_prompt.description == "Updated description"

      # Delete
      {:ok, _deleted_prompt} = Prompts.delete_prompt(LiteRepo, prompt)
      assert Prompts.get_prompt(LiteRepo, prompt.id) == nil
    end

    test "list prompts" do
      # Create multiple prompts
      {:ok, _prompt1} = create_prompt(LiteRepo, %{name: "prompt_1"})
      {:ok, _prompt2} = create_prompt(LiteRepo, %{name: "prompt_2"})
      {:ok, _prompt3} = create_prompt(LiteRepo, %{name: "prompt_3"})

      # Test list prompts
      prompts = Prompts.list_prompts(LiteRepo)
      assert length(prompts) == 3
      assert Enum.map(prompts, & &1.name) == ["prompt_1", "prompt_2", "prompt_3"]
    end
  end

  describe "prompt version management with SQLite" do
    setup do
      {:ok, prompt} = create_prompt(LiteRepo)
      %{prompt: prompt}
    end

    test "create and manage prompt versions", %{prompt: prompt} do
      # Create version
      {:ok, version} =
        create_prompt_version(LiteRepo, prompt.id, %{
          provider: :anthropic,
          content: "Test content",
          model_name: "claude-3",
          model_settings: %{temperature: 0.5}
        })

      assert version.prompt_id == prompt.id
      assert version.version_number == 1
      assert version.state == :draft
      assert version.provider == :anthropic

      # Get version
      found_version =
        Prompts.get_prompt_version(LiteRepo, version.prompt_id, version.version_number)

      assert found_version.id == version.id
      assert found_version.content == "Test content"
    end

    test "version state transitions", %{prompt: prompt} do
      {:ok, version} = create_prompt_version(LiteRepo, prompt.id)
      assert version.state == :draft

      # Publish version
      {:ok, published_version} = Prompts.publish_version(LiteRepo, version)
      assert published_version.state == :published

      # Archive version
      {:ok, archived_version} = Prompts.archive_version(LiteRepo, published_version)
      assert archived_version.state == :archived

      # Draft version
      {:ok, draft_version} = Prompts.draft_version(LiteRepo, archived_version)
      assert draft_version.state == :draft
    end

    test "only one published version per prompt", %{prompt: prompt} do
      # Create and publish first version
      {:ok, version1} = create_prompt_version(LiteRepo, prompt.id, %{content: "Version 1"})
      {:ok, published_v1} = Prompts.publish_version(LiteRepo, version1)

      # Create and publish second version
      {:ok, version2} = create_prompt_version(LiteRepo, prompt.id, %{content: "Version 2"})
      {:ok, published_v2} = Prompts.publish_version(LiteRepo, version2)

      # First version should be archived, second should be published
      reloaded_v1 =
        Prompts.get_prompt_version(LiteRepo, published_v1.prompt_id, published_v1.version_number)

      reloaded_v2 =
        Prompts.get_prompt_version(LiteRepo, published_v2.prompt_id, published_v2.version_number)

      assert reloaded_v1.state == :archived
      assert reloaded_v2.state == :published

      # Get published version should return version 2
      published = Prompts.get_published_version(LiteRepo, prompt.id)
      assert published.id == published_v2.id
    end

    test "automatic version numbering", %{prompt: prompt} do
      {:ok, version1} = create_prompt_version(LiteRepo, prompt.id)
      {:ok, version2} = create_prompt_version(LiteRepo, prompt.id)
      {:ok, version3} = create_prompt_version(LiteRepo, prompt.id)

      assert version1.version_number == 1
      assert version2.version_number == 2
      assert version3.version_number == 3
    end
  end

  describe "migration compatibility" do
    test "basic prompt operations work" do
      # Should work with migrations already run
      prompts = Prompts.list_prompts(LiteRepo)
      assert is_list(prompts)
    end
  end
end
