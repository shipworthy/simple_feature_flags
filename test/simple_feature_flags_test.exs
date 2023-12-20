defmodule SimpleFeatureFlagsTest do
  use ExUnit.Case
  doctest SimpleFeatureFlags

  test "greets the world" do
    assert SimpleFeatureFlags.hello() == :world
  end
end
