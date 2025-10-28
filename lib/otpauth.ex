defmodule OTPAuth do
  @moduledoc """
  This module decodes `otpauth://totp/…` URIs and extract the various fields.

  Once the secret is extracted, it can be used with the
  [NimbleTOTP](https://hex.pm/packages/nimble_totp) library to generate the current secret.
  """

  @doc """
  Extract the secret and label from an otpauth URI, as well as the extra properties.

  The issuer will be extracted either from the label prefix or from the extra URI parameter.
  If both are present, they have to be equal or an error will be returned.

  ## Examples

      iex> OTPAuth.decompose_uri("otpauth://totp/Acme:alice?secret=MFRGGZA&issuer=Acme")
      {:ok, "abcd", "alice", %{"issuer" => "Acme"}}

      iex> OTPAuth.decompose_uri("otpauth://totp/Acme:alice?secret=INVALID!&issuer=Acme")
      :error

  """
  @spec decompose_uri(String.t()) ::
          {:ok, binary(), String.t(), map()} | {:error, :invalid_uri}
  def decompose_uri(uri) when is_binary(uri) do
    with true <- uri =~ ~r"^otpauth://totp/",
         {:ok, uri} <- URI.new(uri),
         ["", label] <- String.split(uri.path, "/"),
         # Reject empty prefix issuer or empty labels (with or without prefix issuer)
         false <- label =~ ~r/^(:|$|.*:$)/,
         query = URI.decode_query(uri.query, %{}, :rfc3986),
         {secret, query} <- Map.pop(query, "secret"),
         {:ok, secret} <- Base.decode32(secret, padding: false),
         param_issuer <- Map.get(query, "issuer"),
         false <- (param_issuer || "") =~ ":" do
      case String.split(label |> URI.decode(), ":") do
        [label] when param_issuer != "" ->
          {:ok, secret, label, query}

        [^param_issuer, label] ->
          {:ok, secret, label, query}

        [issuer, label] when is_nil(param_issuer) ->
          {:ok, secret, label, Map.put(query, "issuer", issuer)}

        _ ->
          :error
      end
    else
      _ -> :error
    end
  end
end
