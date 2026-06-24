defmodule OTPAuth.MixProject do
  use Mix.Project

  def project do
    [
      app: :otpauth,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "OTPAuth",
      source_url: "https://github.com/evenfurther/otpauth",
      docs: &docs/0
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.40", only: :dev, runtime: false, warn_if_outdated: true}
    ]
  end

  defp docs do
    [
      main: "OTPAuth",
      extras: ["README.md"]
    ]
  end
end
