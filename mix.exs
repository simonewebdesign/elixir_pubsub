defmodule PubSub.Mixfile do
  use Mix.Project

  def project do
    [app: :pubsub,
     version: "1.0.0",
     elixir: "~> 1.0",
     description: "Publish-Subscribe utility",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package(),
     deps: deps(),
     test_coverage: [tool: ExCoveralls],

     # Docs
     name: "PubSub",
     source_url: "https://github.com/simonewebdesign/elixir_pubsub",
     docs: [main: "PubSub", # The main page in the docs
            extras: ["README.md"]]
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  defp package do
    [maintainers: ["Simone Vittori"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/simonewebdesign/elixir_pubsub"}]
  end

  defp deps do
    [{:excoveralls, "> 0.0.0", only: :test},
     {:ex_doc, "~> 0.14", only: :dev, runtime: false},
    ]
  end
end
