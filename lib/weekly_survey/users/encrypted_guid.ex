defmodule WeeklySurvey.Users.EncryptedGuid do
  import Joken

  def get_payload(user: %{guid: guid}) do
    token =
      %{guid: guid}
        |> token()
        |> with_signer(hs256(get_secret()))
        |> sign()
        |> get_compact()

    {:ok, token}
  end

  def get_user_information(token) do
    decrypted =
      token
        |> token()
        |> with_signer(hs256(get_secret()))
        |> verify()
        |> Map.get(:claims)

    {:ok, decrypted}
  end

  defp get_secret() do
    Application.get_env(:weekly_survey, __MODULE__)
      |> Keyword.get(:secret)
      |> get_secret()
  end

  defp get_secret(secret) when is_bitstring(secret), do: secret
  defp get_secret({:system, secret_env}), do: System.get_env(secret_env)
end
