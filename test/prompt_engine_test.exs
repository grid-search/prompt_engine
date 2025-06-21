defmodule PromptEngineTest do
  use ExUnit.Case
  doctest PromptEngine

  test "greets the world" do
    assert PromptEngine.hello() == :world
  end
end
