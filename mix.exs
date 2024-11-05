defmodule Lexdee.MixProject do
  use Mix.Project

  def project do
    [
      app: :lexdee,
      version: "2.6.1",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      package: package(),
      description: description(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    Client library for LXD
    """
  end

  defp package do
    [
      name: "lexdee",
      files: ["lib", "mix.exs", "README*", "LICENSE"],
      licenses: ["MIT"],
      maintainers: ["Zack Siri"],
      links: %{"GitHub" => "https://github.com/upmaru/lexdee"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # HTTP Client
      {:tesla, "~> 1.7.0"},
      {:jason, ">= 1.0.0"},

      # HTTP Adapter
      {:castore, "~> 1.0"},
      {:mint, "~> 1.6"},
      {:mint_web_socket, "~> 1.0.4"},

      # Certificate Management
      {:x509, "~> 0.8.1"},

      # SDK
      {:plug_cowboy, "~> 2.0", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:bypass, "~> 2.0", only: :test},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
