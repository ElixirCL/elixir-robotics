defmodule TagBoard.MixProject do
  use Mix.Project

  def project do
    [
      app: :tag_board,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      atomvm: [
        start: TagBoard,
        flash_offset: 0x250000
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:avm_scene, git: "https://github.com/atomvm/avm_scene/"},
      {:exatomvm, git: "https://github.com/atomvm/ExAtomVM/"},
      {:atomvm_lib, git: "https://github.com/atomvm/atomvm_lib/"},
      {:mjson, git: "https://github.com/mbj4668/mjson/"},
      {:mustache, "~> 0.5.0"}
    ]
  end
end
