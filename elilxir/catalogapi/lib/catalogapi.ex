defmodule Catalogapi do
  @moduledoc """
  Documentation for Catalogapi.
  """
  use Tesla

  plug Tesla.Middleware.Logger
  plug Tesla.Middleware.JSON

  @api_version "v1"

  def catalog_breakdown(%{socket_id: _socket_id} = params, opts \\ []) when is_list(opts) do
    api_get(Map.merge(%{method: "catalog_breakdown"}, params), opts)
  end

  def list_available_catalogs(opts \\ []) when is_list(opts) do
    api_get(%{method: "list_available_catalogs"}, opts)
  end

  def redemption_active(opts \\ []) when is_list(opts) do
    api_get(%{method: "redemption_active"}, opts)
  end

  def redemption_active?(opts \\ []) when is_list(opts) do
    {:ok, %Tesla.Env{} = env} = Catalogapi.redemption_active(opts)
    env.body == "1"
  end

  def order_place(
    %{
      socket_id: _socket_id,
      items: _items,
      last_name: _last_name,
      postal_code: _postal_code,
      city: _city,
      first_name: _first_name,
      state_province: _state_province,
      country: _country,
      address_1: _address_1
    } = params,
    opts \\ []
  ) when is_list(opts) do
    method = "order_place"

    uri = "https://" <> endpoint(opts) <> "/" <> @api_version <> "/json/" <> method

    uuid = UUID.uuid1()
    datetime = DateTime.utc_now() |> DateTime.to_iso8601()
    checksum = :crypto.hmac(:sha, secret_key(opts), method <> uuid <> datetime ) |> Base.encode64
    # this is a little different than how its done in api_get, so we can't re-use generate_creds :(
    body = %{
      method => %{
        method <> "_request" => params |> Map.merge(
          %{
            credentials: %{
              method: method,
              uuid: uuid,
              checksum: checksum,
              datetime: datetime
            }
          }
        )
      }
    }

    post(uri, body, opts: [adapter: hackney_opts()] )
    |> unwrap_extra_maps(method: method)
  end

  def api_get(%{method: method} = params, opts \\ []) when is_list(opts) do

    query_string = params
                   |> Map.merge(generate_creds(%{method: method}, opts) )
                   |> URI.encode_query

    uri = "https://" <> endpoint(opts) <> "/" <> @api_version <> "/rest/" <> method <> "?" <> query_string

    get(uri, opts: [adapter: hackney_opts()])
    |> unwrap_extra_maps(method: method)
  end

  defp unwrap_extra_maps({:ok, %Tesla.Env{} = env}, method: method) do
    result = env.body[method <> "_response"][method <> "_result"]
    {:ok, Tesla.put_body(env, result) }
  end

  defp generate_creds(%{method: method}, opts) when is_list(opts) do
    uuid = UUID.uuid1()
    datetime = DateTime.utc_now() |> DateTime.to_iso8601()
    checksum = :crypto.hmac(:sha, secret_key(opts), method <> uuid <> datetime ) |> Base.encode64

    %{
      creds_datetime: datetime,
      creds_uuid: uuid,
      creds_checksum: checksum
    }
  end

  defp endpoint(opts) do
    endpoint = Keyword.get(opts, :endpoint) || runtime_endpoint()

    unless endpoint do
      raise RuntimeError, """
      No secret key is configured for Catalogapi. Update your config your pass in a
      key with `:endpoint` as an addional request option.

          Catalogapi.get("/catalog_breakdown", endpoint: "testco.dev.catalogapi.com")

          config :catalogapi,
            endpoint: "testco.dev.catalogapi.com"

          config :catalogapi,
            endpoint: {:system, "CATALOGAPI_KEY"}
      """
    end

    endpoint
  end

  # stolen from sendgrid
  # https://github.com/alexgaribay/sendgrid_elixir
  defp secret_key(opts) do
    secret_key = Keyword.get(opts, :secret_key) || runtime_key()

    unless secret_key do
      raise RuntimeError, """
      No secret key is configured for Catalogapi. Update your config your pass in a
      key with `:secret_key` as an addional request option.

          Catalogapi.get("/catalog_breakdown", secret_key: "SECRET_KEY")

          config :catalogapi,
            secret_key: "my_secret_key"

          config :catalogapi,
            secret_key: {:system, "CATALOGAPI_KEY"}
      """
    end

    secret_key
  end

  defp runtime_endpoint do
    case Application.get_env(:catalogapi, :endpoint) do
      {:system, env_key} -> System.get_env(env_key)
      key -> key
    end
  end

  defp runtime_key do
    case Application.get_env(:catalogapi, :secret_key) do
      {:system, env_key} -> System.get_env(env_key)
      key -> key
    end
  end

  defp hackney_opts do
    case System.get_env("PROXY_HOST") do
      nil -> []
      _ -> [
          proxy: {
            String.to_charlist(System.get_env("PROXY_HOST")),
            String.to_integer(System.get_env("PROXY_PORT"))
          }
        ]
    end
  end
end
