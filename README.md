# README

SimpleFeatureFlags provides a simple way to enable or disable features, per-environment, using application configuration.

## Code Example


### Put your feature behind the "enabled?"

```elixir
def compute_pi() do
  if SimpleFeatureFlags.enabled?(:new_algorithm) do
    compute_pi_new_algorithm()
  else
    3.14
  end
end
```

### Enable the feature in some environments 

`config/runtime.exs`
```elixir
...
config :simple_feature_flags, :flags, %{
  ...
  features: %{
    new_algorithm: %{enabled_in: [:localhost, :staging]}
    ...
  }
  ...
}
...
```

### Optionally, include configuration information in application log

`lib/myapp/application.ex`

```elixir
defmodule MyApp.Application do

  require Logger
  use Application

  @impl true
  def start(_type, _args) do
    Logger.info(SimpleFeatureFlags.current_configuration_to_string())
    children =
    ...
```

Here is an example of the output:

```text
  Current Deployment Environment: :test
  Possible Deployment Environments: [:test, :localhost, :staging, :production]
  Features:
  - new_algorithm, enabled in [:localhost, :staging]
  - new_ui, enabled in [:localhost]
```

### A complete configuration example

`config/runtime.exs`
```elixir
...
config :simple_feature_flags, :flags, %{
  current_deployment_environment: :test,
  possible_deployment_environments: [:test, :localhost, :staging, :production],
  features: %{
    new_algorithm: %{enabled_in: [:localhost, :staging]},
    new_ui: %{enabled_in: [:localhost]}
  }
}
...
```

### Enabling or disabling a feature 

To turn a feature or or off, update configuration and restart your application. For example, to enable the `new_algorithm` feature in production, add `:production` to the list of `enabled_in`: 

```elixir
    ...
        new_algorithm: %{enabled_in: [:localhost, :staging, :production]}
    ...
```

## Installation

The package can be installed by adding `simple_feature_flags` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:simple_feature_flags, "~> 0.1.0"}
  ]
end
```

The docs can be found at <https://hexdocs.pm/simple_feature_flags>.