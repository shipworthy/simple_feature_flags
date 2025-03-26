defmodule SimpleFeatureFlagsTest do
  use ExUnit.Case
  doctest SimpleFeatureFlags

  describe "bad environment defined_environments" do
  end

  describe "enabled?" do
    test ":no_such_feature" do
      assert_raise RuntimeError,
                   "Unknown feature 'no_such_feature'. Known features: test_feature_1, test_feature_2, test_feature_3, test_feature_4, test_feature_5, test_feature_6.",
                   fn -> SimpleFeatureFlags.enabled?(:no_such_feature) end
    end

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

  describe "current_configuration_to_string/0" do
    test "sunny day path" do
      assert SimpleFeatureFlags.current_configuration_to_string() ==
               """
               Current Deployment Environment: :test
               Features:
                - test_feature_1 is ON. Enabled in [:all].
                - test_feature_2 is ON. Enabled in :all.
                - test_feature_3 is ON. Enabled in [:test].
                - test_feature_4 is ON. Enabled in [:staging, :test, :production].
                - test_feature_5 is OFF. Enabled in [:staging, :production].
                - test_feature_6 is OFF. Enabled in [].
               """
    end
  end

  describe "configuration_to_string/1" do
    test "sunny day, no deployed environment validation" do
      configuration = %{
        current_deployment_environment: :test,
        features: %{
          test_feature_1: %{enabled_in: [:all]},
          test_feature_2: %{enabled_in: :all},
          test_feature_3: %{enabled_in: [:test]},
          test_feature_4: %{enabled_in: [:staging, :test, :production]},
          test_feature_5: %{enabled_in: [:staging, :production]},
          test_feature_6: %{enabled_in: []}
        }
      }

      assert SimpleFeatureFlags.configuration_to_string(configuration) ==
               """
               Current Deployment Environment: :test
               Features:
                - test_feature_1 is ON. Enabled in [:all].
                - test_feature_2 is ON. Enabled in :all.
                - test_feature_3 is ON. Enabled in [:test].
                - test_feature_4 is ON. Enabled in [:staging, :test, :production].
                - test_feature_5 is OFF. Enabled in [:staging, :production].
                - test_feature_6 is OFF. Enabled in [].
               """
    end

    test "sunny day, with deployed environment validation" do
      configuration = %{
        current_deployment_environment: :test,
        known_deployment_environments: [:test, :staging, :production],
        features: %{
          test_feature_1: %{enabled_in: [:all]},
          test_feature_2: %{enabled_in: :all},
          test_feature_3: %{enabled_in: [:test]},
          test_feature_4: %{enabled_in: [:staging, :test, :production]},
          test_feature_5: %{enabled_in: [:staging, :production]},
          test_feature_6: %{enabled_in: []}
        }
      }

      assert SimpleFeatureFlags.configuration_to_string(configuration) ==
               """
               Current Deployment Environment: :test
               Features:
                - test_feature_1 is ON. Enabled in [:all].
                - test_feature_2 is ON. Enabled in :all.
                - test_feature_3 is ON. Enabled in [:test].
                - test_feature_4 is ON. Enabled in [:staging, :test, :production].
                - test_feature_5 is OFF. Enabled in [:staging, :production].
                - test_feature_6 is OFF. Enabled in [].
               """
    end

    test "unexpected deployed environment, :all (reserved atom)" do
      configuration = %{
        current_deployment_environment: :all,
        features: %{
          test_feature_1: %{enabled_in: [:all]},
          test_feature_2: %{enabled_in: :all},
          test_feature_3: %{enabled_in: [:test]},
          test_feature_4: %{enabled_in: [:staging, :test, :production]},
          test_feature_5: %{enabled_in: [:staging, :production]},
          test_feature_6: %{enabled_in: []}
        }
      }

      assert_raise RuntimeError,
                   "Unexpected deployment environment, ':all'. This is a reserved name.",
                   fn -> SimpleFeatureFlags.configuration_to_string(configuration) end
    end

    test "unexpected deployed environment, current environment is unknown" do
      configuration = %{
        current_deployment_environment: :production_eu,
        known_deployment_environments: [:test, :staging, :production],
        features: %{
          test_feature_1: %{enabled_in: [:all]},
          test_feature_2: %{enabled_in: :all},
          test_feature_3: %{enabled_in: [:test]},
          test_feature_4: %{enabled_in: [:staging, :test, :production]},
          test_feature_5: %{enabled_in: [:staging, :production]},
          test_feature_6: %{enabled_in: []}
        }
      }

      assert_raise RuntimeError,
                   "Unknown deployment environment 'production_eu'. Known environments: test, staging, production.",
                   fn -> SimpleFeatureFlags.configuration_to_string(configuration) end
    end

    test "unexpected deployed environment, one of the features is configured for an unknown environment" do
      configuration = %{
        current_deployment_environment: :production,
        known_deployment_environments: [:test, :staging, :production],
        features: %{
          test_feature_1: %{enabled_in: [:all]},
          test_feature_2: %{enabled_in: :all},
          test_feature_3: %{enabled_in: [:test]},
          test_feature_4: %{enabled_in: [:staging, :test, :production_eu]},
          test_feature_5: %{enabled_in: [:staging, :production]},
          test_feature_6: %{enabled_in: []}
        }
      }

      assert_raise RuntimeError,
                   "Feature 'test_feature_4' is marked as enabled in 'production_eu', which is not a known deployment environment. Known environments: test, staging, production.",
                   fn -> SimpleFeatureFlags.configuration_to_string(configuration) end
    end
  end
end
