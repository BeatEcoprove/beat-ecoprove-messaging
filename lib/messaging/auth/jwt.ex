defmodule Messaging.Auth.Jwt do
  @moduledoc """
  JWT Authentication logic: Verifies token, extracts claims, and validates expiration.
  """
  alias Joken.Signer
  use Joken.Config

  @jwks_url "#{Application.compile_env(:messaging, Messaging.Auth.Jwt)[:identity_service_url]}/.well-known/jwks.json"

  def token_config() do
    default_claims(skip: [:aud, :iss])
    |> add_claim("role", nil, fn role ->
      role in ["client", "enterprise", "admin", "anonymous"]
    end)
  end

  defp fetch_jwks do
    case HTTPoison.get(@jwks_url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"keys" => keys}} -> {:ok, keys}
          {:error, decode_error} -> {:error, "Failed to decode JWKS: #{inspect(decode_error)}"}
        end

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Failed to fetch JWKS from #{@jwks_url} with status code: #{status_code}"}

      {:error, reason} ->
        {:error, "Failed to fetch JWKS: #{inspect(reason)}"}
    end
  end

  defp get_signer(token, type) when type in [:access, :refresh] do
    with {:ok, %{"kid" => kid, "alg" => alg, "typ" => typ}} <- Joken.peek_header(token),
         true <- typ == to_string(type) do
      case fetch_jwks() do
        {:ok, jwks} ->
          case Enum.find(jwks, &(&1["kid"] == kid)) do
            nil -> {:error, "JWK not found for given kid"}
            jwk -> {:ok, Signer.create(alg, jwk)}
          end

        {:error, reason} ->
          {:error, "Failed to get token header: #{inspect(reason)}"}
      end
    else
      {:error, reason} -> {:error, "Failed to get token header: #{inspect(reason)}"}
      false -> {:error, "Token type mismatch"}
    end
  end

  def verify_token(token, type \\ :access) do
    case get_signer(token, type) do
      {:ok, signer} ->
        verify_and_validate(token, signer)

      {:error, reason} ->
        {:error, "Token is not valid #{reason}"}
    end
  end
end
