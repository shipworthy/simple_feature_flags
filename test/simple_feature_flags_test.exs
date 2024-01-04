defmodule SimpleFeatureFlagsTest do
  use ExUnit.Case
  doctest SimpleFeatureFlags

  describe "enabled?" do
    test "[:all]" do
      assert SimpleFeatureFlags.enabled?(:test_feature_1) == true
    end

    test ":all" do
      assert SimpleFeatureFlags.enabled?(:test_feature_2) == true
    end

    test "[:test] while running in :test" do
      assert SimpleFeatureFlags.enabled?(:test_feature_3) == true
    end

    test "[:staging, :test, :production] while running in :test" do
      assert SimpleFeatureFlags.enabled?(:test_feature_4) == true
    end

    test "[:staging, :production] while running in :test" do
      assert SimpleFeatureFlags.enabled?(:test_feature_5) == false
    end

    test "[] while running in :test" do
      assert SimpleFeatureFlags.enabled?(:test_feature_6) == false
    end
  end

  describe "configuration to string" do
    test "current_configuration_to_string/0" do
      assert SimpleFeatureFlags.current_configuration_to_string() ==
               """
               Current Deployment Environment: :test
               Features:
                - test_feature_1, enabled in [:all]
                - test_feature_2, enabled in :all
                - test_feature_3, enabled in [:test]
                - test_feature_4, enabled in [:staging, :test, :production]
                - test_feature_5, enabled in [:staging, :production]
                - test_feature_6, enabled in []
               """
    end

    test "configuration_to_string/1" do
      configuration = Application.get_env(:simple_feature_flags, :flags)

      assert SimpleFeatureFlags.configuration_to_string(configuration) ==
               """
               Current Deployment Environment: :test
               Features:
                - test_feature_1, enabled in [:all]
                - test_feature_2, enabled in :all
                - test_feature_3, enabled in [:test]
                - test_feature_4, enabled in [:staging, :test, :production]
                - test_feature_5, enabled in [:staging, :production]
                - test_feature_6, enabled in []
               """
    end
  end
end
