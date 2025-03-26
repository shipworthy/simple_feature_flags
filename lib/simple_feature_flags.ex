defmodule SimpleFeatureFlags do
  @moduledoc """
  This module includes functions for checking whether a feature is enabled (`enabled?/1`), and for introspecting configuration (`current_configuration_to_string/0`).
  """

  @doc """
  This function answers the question "Is feature X enabled in the current deployment environment?"

  If feature X is not mentioned in your configuration, the function raises an exception.

  ## Examples

      iex> SimpleFeatureFlags.enabled?(:test_feature_1)
      true
      iex> SimpleFeatureFlags.enabled?(:no_such_feature)
      ** (RuntimeError) Unknown feature 'no_such_feature'. Known features: test_feature_1, test_feature_2, test_feature_3, test_feature_4, test_feature_5, test_feature_6.
      
  """
  def enabled?(feature) do
    %{features: features, current_deployment_environment: current_deployment_environment} =
      Application.get_env(:simple_feature_flags, :flags)

    enabled_in_these_environments =
      features
      |> Map.fetch(feature)
      |> case do
        :error ->
          raise "Unknown feature '#{feature}'. Known features: #{Map.keys(features) |> Enum.join(", ")}."

        {:ok, %{enabled_in: enabled_in}} ->
          enabled_in
      end

    :all == enabled_in_these_environments or
      :all in enabled_in_these_environments or
      current_deployment_environment in enabled_in_these_environments
  end

  @doc """
  Return the current configuration as a human-friendly string.

  If the configuration appears invalid, the function raises an exception.

  ## Examples

      iex> SimpleFeatureFlags.current_configuration_to_string()
      "Current Deployment Environment: :test.\\nFeatures:\\n - test_feature_1 is ON. Enabled in [:all].\\n - test_feature_2 is ON. Enabled in :all.\\n - test_feature_3 is ON. Enabled in [:test].\\n - test_feature_4 is ON. Enabled in [:staging, :test, :production].\\n - test_feature_5 is OFF. Enabled in [:staging, :production].\\n - test_feature_6 is OFF. Enabled in [].\\n"

  """
  def current_configuration_to_string() do
    Application.get_env(:simple_feature_flags, :flags)
    |> configuration_to_string()
  end

  @doc false
  def configuration_to_string(
        %{
          current_deployment_environment: current_deployment_environment,
          features: features
        } = configuration
      )
      when current_deployment_environment != nil and is_map(features) do
    validate_deployment_environments(configuration)

    """
    Current Deployment Environment: #{inspect(current_deployment_environment)}.
    """ <>
      known_environments(configuration) <>
      """
      Features:
      """ <>
      Enum.map_join(features, "", fn {feature_name, %{enabled_in: enabled_in}} ->
        on_or_off = if SimpleFeatureFlags.enabled?(feature_name), do: "ON", else: "OFF"

        """
         - #{feature_name} is #{on_or_off}. Enabled in #{inspect(enabled_in)}.
        """
      end)
  end

  defp known_environments(%{known_deployment_environments: known_environments}) do
    """
    Known Deployment Environments: #{Enum.join(known_environments, ", ")}.
    """
  end

  defp known_environments(_), do: ""

  defp validate_deployment_environments(%{current_deployment_environment: :all}) do
    raise "Unexpected deployment environment, ':all'. This is a reserved name."
  end

  defp validate_deployment_environments(%{
         known_deployment_environments: known_deployment_environments,
         current_deployment_environment: current_deployment_environment,
         features: features
       }) do
    for known_env <- known_deployment_environments do
      if !is_atom(known_env) do
        raise "Expecting atoms in 'known_deployment_environments'. '#{known_env}' is not an atom."
      end
    end

    if current_deployment_environment not in known_deployment_environments do
      raise "Unknown deployment environment '#{current_deployment_environment}'. Known environments: #{Enum.join(known_deployment_environments, ", ")}."
    end

    for {feature_name, %{enabled_in: enabled_in}} <- features, enabled_in != :all do
      for feature_enabled_in_env <- enabled_in do
        if feature_enabled_in_env not in [:all | known_deployment_environments] do
          raise "Feature '#{feature_name}' is marked as 'enabled' in environment '#{feature_enabled_in_env}', which is not a known deployment environment. Known environments: #{Enum.join(known_deployment_environments, ", ")}."
        end
      end
    end

    :ok
  end

  defp validate_deployment_environments(%{
         current_deployment_environment: current_deployment_environment,
         features: features
       })
       when is_atom(current_deployment_environment) and current_deployment_environment != nil and
              is_map(features) do
    :ok
  end

  defp validate_deployment_environments(%{
         current_deployment_environment: current_deployment_environment
       })
       when not is_atom(current_deployment_environment) do
    raise "'current_deployment_environment' is expected to be an atom. '#{current_deployment_environment}' is not an atom."
  end
end
