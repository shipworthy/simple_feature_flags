# SimpleFeatureFlags

SimpleFeatureFlags provides a simple way to enable or disable features, per-environment, using application configuration.

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


## Code Example

### Configuration

Determine the name of the deployment environment you are running in, and list the environments in which your feature is enabled.

In this example, the name of the deployment environment is loaded from an environment variable, and the `new_algorithm` feature is enabled in `localhost` and `staging`:


`config/runtime.exs`
```elixir
current_deployment_environment =
  System.get_env("DEPLOYMENT_ENVIRONMENT")
  |> case do
    nil -> raise "DEPLOYMENT_ENVIRONMENT is not defined"
    env -> String.to_atom(env)
  end


config :simple_feature_flags, :flags, %{
  current_deployment_environment: current_deployment_environment,
  features: %{
    new_algorithm: %{enabled_in: [:localhost, :staging]},
    new_ui: %{enabled_in: [:localhost]}
  }
}
```

### Using Feature Flag in Your Code

Wrap your feature logic in `SimpleFeatureFlags.enabled?/1`:

```elixir
def compute_pi() do
  if SimpleFeatureFlags.enabled?(:new_algorithm) do
    # Use the new, better algorithm.
    compute_pi_new_algorithm()
  else
    # Use the old, boring algorithm.
    3.14
  end
end
```


### Optional: Log Configuration on Startup

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
  - new_algorithm is ON. Enabled in [:localhost, :staging]
  - new_ui is OFF. Enabled in [:localhost]
```
