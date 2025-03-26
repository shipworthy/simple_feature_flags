# README

SimpleFeatureFlags provides basic, simple feature flag functionality. You can use application configuration (`config/runtime.exs`) to select the deployment environments in which a feature is enabled

This approach is useful when you want to roll out a feature to only a subset of your environments. Here are a couple of examples:
1. You want to try a feature in your localhost and staging environments, before rolling it out to production.
2. You want to use a feature in a subset of your production environments (based on a region, or some other grouping).

The example below describes switching to a new, exciting algorithm (`:new_algorithm`) for computing `𝝿` in `:localhost` and `:staging` deployment environments, before rolling it out to `:production` (or not).

## Installation

The package can be installed by adding `simple_feature_flags` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:simple_feature_flags, "~> 0.1"}
  ]
end
```

The docs can be found at <https://hexdocs.pm/simple_feature_flags>.


## Configuration

Determine the name of the deployment environment you are running in, and list the environments in which your feature is enabled.

In this example, the name of the deployment environment is loaded from an environment variable, and the `new_algorithm` feature is enabled in `localhost` and `staging`:


`config/runtime.exs`
```elixir

# Determine the current environment.
# Is the service running on localhost? In the staging environment? In production?
current_deployment_environment =
  System.get_env("DEPLOYMENT_ENVIRONMENT")
  |> case do
    nil -> raise "DEPLOYMENT_ENVIRONMENT is not defined"
    env -> String.to_atom(env)
  end


config :simple_feature_flags, :flags, %{
  # In which deployment environment (e.g., :production, :staging, :localhost, :test) is
  # the code currently running?
  current_deployment_environment: current_deployment_environment,

  # Optional: list possible deployment environments, for additional validation and
  # protection against typos.
  known_deployment_environments: [:test, :staging, :production],

  # In which of the environments do you want to enable each feature?
  features: %{
    new_algorithm: %{enabled_in: [:localhost, :staging]},
    new_ui: %{enabled_in: [:staging]}
  }
}
```

## Using Feature Flags in Your Code

Wrap your feature logic in `SimpleFeatureFlags.enabled?/1`:

```elixir
defmodule MyApp.Pi do
  def compute_pi() do
    if SimpleFeatureFlags.enabled?(:new_algorithm) do
      # Use the new, exciting algorithm.
      compute_pi_new_algorithm()
    else
      # Use the old, boring algorithm.
      3.14
    end
  end
end
```

## Optional: Log Configuration on Startup

`lib/myapp/application.ex`

```elixir
defmodule MyApp.Application do

  require Logger
  use Application

  @impl true
  def start(_type, _args) do
    Logger.info(SimpleFeatureFlags.current_configuration_to_string())
    ...
```

Here is an example of the output:

```text
  Current Deployment Environment: :localhost
  Features:
  - new_algorithm is ON. Enabled in [:localhost, :staging].
  - new_ui is OFF. Enabled in [:staging].
```


## Completing the Experiment: Retiring `:new_algorithm` or Rolling it Out to `:production`

If, after experiencing `:new_algorithm` is `:localhost` and `:staging`, you decided that the world is not ready for its genius, you can simply remove `new_algorithm` and its implementation from configs and the codebase.

If you are now confident that this `new_algorithm` for computing `𝝿` will make the world and your product better, and you want to roll it out to production, you have a couple of options:

1. Remove the feature flag completely. The new feature is now part of your codebase.
2. Add your production environment to the `enabled_in:` list, or replace the list with `:all`:
   * `new_algorithm: %{enabled_in: [:localhost, :staging: :production]},` OR
   * `new_algorithm: %{enabled_in: :all},`.


## A/B, Regional Testing

The example above alluded to the existence of `:localhost`, `:staging`, and `:production` deployment environments.

The configuration approach of choosing the environments in which your changes are live remains the same, regardless of how many production or staging environments you have: simply detect `current_deployment_environment` in which the code is running, and include all environments of interest in the `enabled_in` list.

For example, to roll `:new_algorithm` out to your production environment running in Singapore, but not to the US or Japan, you might do something like this:  

`config/runtime.exs`
```elixir
# e.g. :localhost, :staging, :production_us, :production_sg, :production_jp
# Detect this in runtime.
current_deployment_environment = ... 

config :simple_feature_flags, :flags, %{
  current_deployment_environment: current_deployment_environment,
  features: %{
    # enabled in production in Singapore.
    new_algorithm: %{enabled_in: [:localhost, :staging, :production_sg]},
  }
}
```
