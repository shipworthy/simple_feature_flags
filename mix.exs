defmodule SimpleFeatureFlags.MixProject do
  use Mix.Project

  def project do
    [
      app: :simple_feature_flags,
      description: "Simple feature flags",
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      name: "Simple Feature Flags",
      source_url: "https://github.com/shipworthy/simple_feature_flags",
      docs: [
        # main: "README.md",
        extras: ["README.md", "LICENSE"]
      ]
    ]
  end

  def package do
    [
      name: "journey",
      organization: "shipworthy",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/shipworthy/simple_feature_flags"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end
end
