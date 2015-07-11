defmodule PubSub.Mixfile do
  use Mix.Project

  def project do
    [app: :pubsub,
     version: "0.0.1",
     elixir: "~> 1.0",
     description: "Publish-Subscribe utility",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package,
     deps: []]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  defp package do
    [contributors: ["Simone Vittori"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/simonewebdesign/elixir_pubsub"}]
  end
end
