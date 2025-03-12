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
    enabled_in_these_environments =
      Application.get_env(:simple_feature_flags, :flags).features
      |> Map.fetch!(feature)
      |> Map.fetch!(:enabled_in)

    current_deployment_environment =
      Application.get_env(:simple_feature_flags, :flags).current_deployment_environment

    :all == enabled_in_these_environments or
      [:all] == enabled_in_these_environments or
      :all in enabled_in_these_environments or
      current_deployment_environment in enabled_in_these_environments
  end

  @doc """
  Return the current configuration as a human-friendly string.

  ## Examples

      iex> SimpleFeatureFlags.current_configuration_to_string()
      "Current Deployment Environment: :test\\nFeatures:\\n - test_feature_1 is ON. Enabled in [:all]\\n - test_feature_2 is ON. Enabled in :all\\n - test_feature_3 is ON. Enabled in [:test]\\n - test_feature_4 is ON. Enabled in [:staging, :test, :production]\\n - test_feature_5 is OFF. Enabled in [:staging, :production]\\n - test_feature_6 is OFF. Enabled in []\\n"

  """
  def current_configuration_to_string() do
    Application.get_env(:simple_feature_flags, :flags)
    |> configuration_to_string()
  end

  @doc false
  def configuration_to_string(%{
        current_deployment_environment: current_deployment_environment,
        features: features
      })
      when is_atom(current_deployment_environment) and
             current_deployment_environment != nil and
             is_map(features) do
    """
    Current Deployment Environment: #{inspect(current_deployment_environment)}
    Features:
    """ <>
      Enum.map_join(features, "", fn {feature_name, %{enabled_in: enabled_in}} ->
        on_or_off = if SimpleFeatureFlags.enabled?(feature_name), do: "ON", else: "OFF"

        """
         - #{feature_name} is #{on_or_off}. Enabled in #{inspect(enabled_in)}
        """
      end)
  end
end
