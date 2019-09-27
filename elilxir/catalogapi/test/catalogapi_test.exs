defmodule CatalogapiTest do
  use ExUnit.Case
  doctest Catalogapi

  import Tesla.Mock
  import TestFixtures

  setup do
    Tesla.Mock.mock fn env ->
      # TODO refactor with macros?
      cond do
        Regex.match?(~r/catalog_breakdown/, env.url) -> %Tesla.Env{status: 200, headers: [{"content-type", "application/json"}], body: fixture("catalog_breakdown") }
        Regex.match?(~r/redemption_active/, env.url) -> %Tesla.Env{status: 200, headers: [{"content-type", "application/json"}],  body: fixture("redemption_active") }
        Regex.match?(~r/list_available_catalogs/, env.url) -> %Tesla.Env{status: 200, headers: [{"content-type", "application/json"}],  body: fixture("list_available_catalogs") }
        Regex.match?(~r/order_place/, env.url) -> %Tesla.Env{status: 200, headers: [{"content-type", "application/json"}],  body: fixture("order_place") }
        true -> %Tesla.Env{status: 404, body: ""}
      end
    end
    :ok
  end


  test "catalog breakdown" do
    {:ok, %Tesla.Env{} = env} = Catalogapi.catalog_breakdown(%{socket_id: 549})
    %{
      "categories" => %{"Category" => categories},
      "credentials" => credentials,
      "socket" => socket
    } = env.body

    %{
      "socket_name" => socket_name,
      "socket_id" => socket_id
    } = socket

    %{
      "method" => credentials_method
    } = credentials

    assert Enum.count(categories) == 2

    assert credentials_method == "catalog_breakdown"

    assert socket_name == "EUR Swift API Test"
    assert socket_id == 549
  end

  test "redemption_active" do
    {:ok, %Tesla.Env{} = env} = Catalogapi.redemption_active()
    assert env.body == "1"
  end

  test "redemption_active?" do
    assert Catalogapi.redemption_active?()
  end

  test "list_available_catalogs" do
    {:ok, %Tesla.Env{} = env} = Catalogapi.list_available_catalogs()
    %{"domain" =>
      %{"sockets" => %{"Socket" => sockets }}
    } = env.body
    assert Enum.count(sockets) == 75
    # TODO more assertions
  end

  test "order_place" do
    {:ok, %Tesla.Env{} = env } = Catalogapi.order_place(%{
      address_1: "123 Fake St",
      city: "Cincinnati",
      country: "US",
      first_name: "Dave",
      last_name: "Menninger",
      postal_code: "45202",
      socket_id: 549,
      state_province: "OH",
      items: [
        %{
          catalog_item_id: 3_661_975,
          catalog_price: 1,
          currency: "EUR",
          quantity: 1,
          metadata: []
        }
      ]
    })
    assert env.status == 200
    %{"order_number" => order_number} = env.body
    assert String.length(order_number) == 21
  end
end