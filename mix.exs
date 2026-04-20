defmodule Membrane.MPEGTS.MixProject do
  use Mix.Project

  @version "0.6.0"
  @github_url "https://github.com/membraneframework/membrane_mpegts_plugin"

  def project do
    [
      app: :membrane_mpegts_plugin,
      version: @version,
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer(),

      # Hex
      description: "Membrane Multimedia Framework (MPEG-TS Plugin)",
      package: package(),

      # Docs
      name: "Membrane MPEG-TS Plugin",
      source_url: @github_url,
      docs: docs(),
      homepage_url: "https://membraneframework.org",
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  defp deps do
    [
      {:membrane_core, "~> 1.2.3"},
      {:membrane_aac_plugin, "~> 0.19.0"},
      {:membrane_h26x_plugin, "~> 0.10.6"},
      {:membrane_timestamp_queue, "~> 0.2.2"},
      {:membrane_file_plugin, "~> 0.17.2", only: :test},
      {:crc, "~> 0.10"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: :dev, runtime: false}
    ]
  end

  defp dialyzer() do
    opts = [
      flags: [:error_handling],
      plt_add_apps: [:syntax_tools]
    ]

    if System.get_env("CI") == "true" do
      # Store PLTs in cacheable directory for CI
      File.mkdir_p!(Path.join([__DIR__, "priv", "plts"]))
      [plt_local_path: "priv/plts", plt_core_path: "priv/plts"] ++ opts
    else
      opts
    end
  end

  defp package do
    [
      maintainers: ["Membrane Team"],
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => @github_url,
        "Membrane Framework Homepage" => "https://membraneframework.org"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      source_ref: "v#{@version}",
      nest_modules_by_prefix: [Membrane.MPEGTS]
    ]
  end
end
