defmodule Auto1.MixProject do
  use Mix.Project

  def project do
    [
      app: :auto1,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      atomvm: [
        start: Auto1,
        wifi: [
          ssid: "mauricio",
          psk: "mauricapo123"
          ]
        ]
      ]

  end

  # ... código intermedio ...

  defp deps do
    [
      {:exatomvm, git: "https://github.com/atomvm/ExAtomVM"}
    ]
  end
end
