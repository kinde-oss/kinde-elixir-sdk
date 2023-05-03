defmodule ClientCredentialsTest do
  use ExUnit.Case

  alias ClientTestHelper
  alias KindeClientSDK

  @domain Application.get_env(:kinde_sdk, :domain)
  @grant_type :client_credentials

  setup_all do
    conn = Plug.Test.conn(:get, "/") |> Plug.Test.init_test_session(%{})
    {conn, client} = ClientTestHelper.initialize_valid_client(conn, @grant_type)
    {:ok, conn: conn, client: client}
  end

  test "initialize the client", %{conn: conn, client: client} do
    assert client.token_endpoint == @domain <> "/oauth2/token"
    refute is_nil(KindeClientSDK.get_cache_pid(conn))
  end

  test "get access token", %{conn: conn, client: client} do
    KindeClientSDK.save_kinde_client(conn, client)

    KindeClientSDK.login(conn, client)

    data = KindeClientSDK.get_all_data(conn)

    refute is_nil(data.access_token)
  end

  test "login with audience", %{conn: conn, client: client} do
    additional_params = %{
      audience: @domain <> "/api"
    }

    KindeClientSDK.save_kinde_client(conn, client)

    assert KindeClientSDK.login(conn, client, additional_params)
  end

  test "login with org_code", %{conn: conn, client: client} do
    additional_params = %{
      org_code: "org_123",
      org_name: "My Application"
    }

    KindeClientSDK.save_kinde_client(conn, client)

    KindeClientSDK.login(conn, client, additional_params)

    data = KindeClientSDK.get_all_data(conn)

    refute is_nil(data.access_token)
  end
end
