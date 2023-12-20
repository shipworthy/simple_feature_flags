defmodule SimpleFeatureFlags do
  @moduledoc """
  This module includes functions for checking whether a feature is enabled (`enabled?/1`), and for introspecting configuration (`current_configuration_to_string/0`).
  """

  @doc """
  Is feature x enabled in the current deployment environment?

  ## Examples

      iex> SimpleFeatureFlags.enabled?(:test_feature_1)
      true

  """
  def enabled?(feature) do
    possible_deployment_environments =
      Application.get_env(:simple_feature_flags, :flags).features
      |> Map.fetch!(feature)
      |> Map.fetch!(:enabled_in)

    current_deployment_environment =
      Application.get_env(:simple_feature_flags, :flags).current_deployment_environment

    :all == possible_deployment_environments or
      [:all] == possible_deployment_environments or
      :all in possible_deployment_environments or
      current_deployment_environment in possible_deployment_environments
  end

  @doc """
  Return the current configuration as a human-friendly string.

  ## Examples

      iex> SimpleFeatureFlags.current_configuration_to_string()
      "Current Deployment Environment: :test\\nPossible Deployment Environments: [:test, :localhost, :staging, :production]\\nFeatures:\\n - test_feature_1, enabled in [:all]\\n - test_feature_2, enabled in :all\\n - test_feature_3, enabled in [:test]\\n - test_feature_4, enabled in [:staging, :test, :production]\\n - test_feature_5, enabled in [:staging, :production]\\n - test_feature_6, enabled in []\\n"

  """
  def current_configuration_to_string() do
    Application.get_env(:simple_feature_flags, :flags)
    |> configuration_to_string()
  end

  @doc false
  def configuration_to_string(%{
        current_deployment_environment: current_deployment_environment,
        possible_deployment_environments: possible_deployment_environments,
        features: features
      })
      when is_atom(current_deployment_environment) and
             current_deployment_environment != nil and
             is_list(possible_deployment_environments) and
             is_map(features) do
    """
    Current Deployment Environment: #{inspect(current_deployment_environment)}
    Possible Deployment Environments: #{inspect(possible_deployment_environments)}
    Features:
    """ <>
      (for {feature_name, %{enabled_in: enabled_in}} <- features do
         """
          - #{feature_name}, enabled in #{inspect(enabled_in)}
         """
       end
       |> Enum.join())
  end
end
