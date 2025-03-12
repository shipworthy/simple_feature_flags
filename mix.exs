defmodule SimpleFeatureFlags.MixProject do
  use Mix.Project

  def project do
    [
      app: :simple_feature_flags,
      description: "Simple feature flags",
      version: "0.1.3",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      name: "Simple Feature Flags",
      source_url: "https://github.com/shipworthy/simple_feature_flags",
      docs: [
        main: "readme",
        extras: ["README.md", "LICENSE"]
      ],
      test_coverage: [
        summary: [
          threshold: 100
        ]
      ]
    ]
  end

  def package do
    [
      name: "simple_feature_flags",
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
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.37", only: :dev, runtime: false}
    ]
  end
end
