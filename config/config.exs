import Config

config :simple_feature_flags, :flags, %{
  current_deployment_environment: :test,
  possible_deployment_environments: [:test, :localhost, :staging, :production],
  features: %{
    test_feature_1: %{enabled_in: [:all]},
    test_feature_2: %{enabled_in: :all},
    test_feature_3: %{enabled_in: [:test]},
    test_feature_4: %{enabled_in: [:staging, :test, :production]},
    test_feature_5: %{enabled_in: [:staging, :production]},
    test_feature_6: %{enabled_in: []}
  }
}
