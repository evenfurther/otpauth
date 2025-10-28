defmodule OTPAuthTest do
  use ExUnit.Case, async: true
  doctest OTPAuth

  describe "decompose_uri" do
    test "supports the absence of issuer" do
      uri = "otpauth://totp/alice?secret=MFRGGZA"
      assert {:ok, "abcd", "alice", %{}} == OTPAuth.decompose_uri(uri)
    end

    test "extracts the issuer from the prefix" do
      uri = "otpauth://totp/Acme:alice?secret=MFRGGZA"

      assert {:ok, "abcd", "alice", %{"issuer" => "Acme"}} ==
               OTPAuth.decompose_uri(uri)
    end

    test "extracts the issuer from the URI params" do
      uri = "otpauth://totp/alice?secret=MFRGGZA&issuer=Acme"

      assert {:ok, "abcd", "alice", %{"issuer" => "Acme"}} ==
               OTPAuth.decompose_uri(uri)
    end

    test "accepts identical issuers in prefix and URI params" do
      uri = "otpauth://totp/Acme:alice?secret=MFRGGZA&issuer=Acme"

      assert {:ok, "abcd", "alice", %{"issuer" => "Acme"}} ==
               OTPAuth.decompose_uri(uri)
    end

    test "preserves extra URI params" do
      uri = "otpauth://totp/Acme:alice?secret=MFRGGZA&issuer=Acme&extra=1"

      {:ok, "abcd", "alice", params} = OTPAuth.decompose_uri(uri)
      assert [{"extra", "1"}, {"issuer", "Acme"}] == Enum.sort(params)
    end

    test "rejects an empty label with no prefix issuer" do
      uri = "otpauth://totp/?secret=MFRGGZA"

      assert :error == OTPAuth.decompose_uri(uri)
    end

    test "rejects an empty label with a prefix issuer" do
      uri = "otpauth://totp/Acme:?secret=MFRGGZA"

      assert :error == OTPAuth.decompose_uri(uri)
    end

    test "rejects an empty prefix issuer" do
      uri = "otpauth://totp/:alice?secret=MFRGGZA"

      assert :error == OTPAuth.decompose_uri(uri)
    end

    test "rejects an empty issuer from URI params" do
      uri = "otpauth://totp/alice?secret=MFRGGZA&issuer="

      assert :error == OTPAuth.decompose_uri(uri)
    end

    test "rejects different issuers in prefix and URI params" do
      uri = "otpauth://totp/Acme:alice?secret=MFRGGZA&issuer=Corp"

      assert :error == OTPAuth.decompose_uri(uri)
    end

    test "rejects URI with wrong scheme or host" do
      uri = "otpauth://hotp/Acme:alice?secret=MFRGGZA&issuer=Corp"

      assert :error == OTPAuth.decompose_uri(uri)
    end

    test "rejects URI if issuer contains ':'" do
      uri = "otpauth://hotp/alice?secret=MFRGGZA&issuer=Acme:Corp"

      assert :error == OTPAuth.decompose_uri(uri)
    end

    test "rejects URI if label contains ':'" do
      uri = "otpauth://hotp/Acme:Corp:alice?secret=MFRGGZA"

      assert :error == OTPAuth.decompose_uri(uri)
    end

    test "decode an URI containing encoded label" do
      uri =
        "otpauth://totp/T%C3%A9l%C3%A9com%20Paris:user?secret=MFRGGZA&issuer=T%C3%A9l%C3%A9com%20Paris"

      assert {:ok, "abcd", "user", %{"issuer" => "Télécom Paris"}} ==
               OTPAuth.decompose_uri(uri)
    end
  end
end
