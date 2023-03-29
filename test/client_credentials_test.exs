defmodule ClientCredentialsTest do
  use ExUnit.Case

  alias ClientTestHelper
  alias KindeClientSDK
  alias Plug.Conn

  @domain Application.get_env(:kinde_management_api, :domain)
  @grant_type :client_credentials

  setup_all do
    conn = Plug.Test.conn(:get, "/") |> Plug.Test.init_test_session(%{})
    {conn, client} = ClientTestHelper.initialize_valid_client(conn, @grant_type)
    {:ok, conn: conn, client: client}
  end

  test "initialize the client", %{conn: conn, client: client} do
    assert client.token_endpoint == @domain <> "/oauth2/token"
    refute is_nil(Conn.get_session(conn, :kinde_cache_pid))
  end

  test "get access token", %{conn: conn, client: client} do
    pid = Conn.get_session(conn, :kinde_cache_pid)
    GenServer.cast(pid, {:add_kinde_data, {:kinde_client, client}})

    KindeClientSDK.login(conn, client)

    [kinde_token: token] = GenServer.call(pid, {:get_kinde_data, :kinde_token})

    refute is_nil(token["access_token"])
  end

  test "login with audience", %{conn: conn, client: client} do
    additional_params = %{
      audience: @domain <> "/api"
    }

    pid = Conn.get_session(conn, :kinde_cache_pid)
    GenServer.cast(pid, {:add_kinde_data, {:kinde_client, client}})

    assert KindeClientSDK.login(conn, client, additional_params)
  end

  test "login with org_code", %{conn: conn, client: client} do
    additional_params = %{
      org_code: "org_123",
      org_name: "My Application"
    }

    pid = Conn.get_session(conn, :kinde_cache_pid)
    GenServer.cast(pid, {:add_kinde_data, {:kinde_client, client}})

    KindeClientSDK.login(conn, client, additional_params)

    [kinde_token: token] = GenServer.call(pid, {:get_kinde_data, :kinde_token})

    refute is_nil(token["access_token"])
  end
end
