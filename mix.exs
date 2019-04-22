defmodule DataGenerator.MixProject do
  use Mix.Project

  def project do
    [
      app: :data_generator,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {DataGenerator.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.3"},
      {:phoenix_pubsub, "~> 1.1"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:smart_city_registry, "~> 2.6", organization: "smartcolumbus_os"},
      {:smart_city_data, "~> 2.1", organization: "smartcolumbus_os"},
      {:smart_city_test, "~> 0.2.1", organization: "smartcolumbus_os"},
      {:csv, "~> 2.3"},
      {:distillery, "~> 2.0"},
      {:credo, "~> 1.0"}
    ]
  end
end