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
      aliases: aliases(),
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
      {:httpoison, "~> 0.7"},
      {:envar, "~> 1.1.0"},
      {:mock, "~> 0.3.0", only: :test}
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

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      test: [&clean_project/1, "test"]
    ]
  end

  defp clean_project(_) do
    System.cmd("rm", ["-rf", "_build"])
  end
end
