defmodule KindeSDK.Mixfile do
  use Mix.Project

  def project do
    [
      app: :kinde_sdk,
      version: "1.2.0",
      elixir: "~> 1.10",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      description: "Provides endpoints to manage your Kinde Businesses",
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.3.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:tesla, "~> 1.4"},
      {:poison, "~> 3.0"},
      {:ex_doc, "~> 0.28", only: :dev, runtime: false},
      {:plug, "~> 1.13"},
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.3"},
      {:httpoison, "~> 0.7"}
    ]
  end

  defp package do
    [
      name: "kinde_sdk",
      files: ~w(config lib test .formatter.exs .gitignore LICENSE* mix.exs README*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/kinde-oss/kinde-elixir-sdk"}
    ]
  end
end
