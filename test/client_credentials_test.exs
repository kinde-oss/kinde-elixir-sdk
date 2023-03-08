defmodule ClientCredentialsTest do
  use ExUnit.Case

  alias KindeClientSDK
  alias Plug.Conn

  @domain Application.get_env(:kinde_management_api, :domain)
  @redirect_url Application.get_env(:kinde_management_api, :redirect_url)
  @client_id Application.get_env(:kinde_management_api, :backend_client_id)
  @client_secret Application.get_env(:kinde_management_api, :client_secret)
  @grant_type :client_credentials
  @logout_redirect_url Application.get_env(:kinde_management_api, :logout_redirect_url)

  setup_all do
    {:ok, conn: Plug.Test.conn(:get, "/") |> Plug.Test.init_test_session(%{})}
  end

  test "initialize the client", %{conn: conn} do
    {conn, client} =
      KindeClientSDK.init(
        conn,
        @domain,
        @redirect_url,
        @client_id,
        @client_secret,
        @grant_type,
        @logout_redirect_url
      )

    assert client.token_endpoint == @domain <> "/oauth2/token"
    refute is_nil(Conn.get_session(conn, :kinde_cache_pid))
  end

  test "get access token", %{conn: conn} do
    {conn, client} =
      KindeClientSDK.init(
        conn,
        @domain,
        @redirect_url,
        @client_id,
        @client_secret,
        @grant_type,
        @logout_redirect_url
      )

    pid = Conn.get_session(conn, :kinde_cache_pid)
    GenServer.cast(pid, {:add_kinde_data, {:kinde_client, client}})

    KindeClientSDK.login(conn, client)

    [kinde_token: token] = GenServer.call(pid, {:get_kinde_data, :kinde_token})

    refute is_nil(token["access_token"])
  end

  test "login with audience", %{conn: conn} do
    additional_params = %{
      audience: @domain <> "/api"
    }

    {conn, client} =
      KindeClientSDK.init(
        conn,
        @domain,
        @redirect_url,
        @client_id,
        @client_secret,
        @grant_type,
        @logout_redirect_url
      )

    pid = Conn.get_session(conn, :kinde_cache_pid)
    GenServer.cast(pid, {:add_kinde_data, {:kinde_client, client}})

    assert KindeClientSDK.login(conn, client, additional_params)
  end

  test "login with org_code", %{conn: conn} do
    additional_params = %{
      org_code: "org_123",
      org_name: "My Application"
    }

    {conn, client} =
      KindeClientSDK.init(
        conn,
        @domain,
        @redirect_url,
        @client_id,
        @client_secret,
        @grant_type,
        @logout_redirect_url
      )

    pid = Conn.get_session(conn, :kinde_cache_pid)
    GenServer.cast(pid, {:add_kinde_data, {:kinde_client, client}})

    KindeClientSDK.login(conn, client, additional_params)

    [kinde_token: token] = GenServer.call(pid, {:get_kinde_data, :kinde_token})

    refute is_nil(token["access_token"])
  end
end
