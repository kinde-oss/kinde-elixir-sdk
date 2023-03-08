defmodule AuthorizationCodeTest do
  use ExUnit.Case

  alias KindeClientSDK
  alias Plug.Conn

  @domain Application.get_env(:kinde_management_api, :domain)
  @redirect_url Application.get_env(:kinde_management_api, :redirect_url)
  @client_id Application.get_env(:kinde_management_api, :backend_client_id)
  @client_secret Application.get_env(:kinde_management_api, :client_secret)
  @grant_type :authorization_code
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

  test "do login", %{conn: conn} do
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

    conn = KindeClientSDK.login(conn, client)

    refute Enum.empty?(Conn.get_resp_header(conn, "location"))
  end

  test "do login with audience", %{conn: conn} do
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
        @logout_redirect_url,
        "openid profile email offline",
        additional_params
      )

    pid = Conn.get_session(conn, :kinde_cache_pid)
    GenServer.cast(pid, {:add_kinde_data, {:kinde_client, client}})

    conn = KindeClientSDK.login(conn, client)

    refute Enum.empty?(Conn.get_resp_header(conn, "location"))
  end

  test "do login with additional", %{conn: conn} do
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
        @logout_redirect_url,
        "openid profile email offline",
        additional_params
      )

    pid = Conn.get_session(conn, :kinde_cache_pid)
    GenServer.cast(pid, {:add_kinde_data, {:kinde_client, client}})

    additional_params_more = %{
      org_code: "org_123",
      org_name: "My Application"
    }

    conn = KindeClientSDK.login(conn, client, additional_params_more)

    refute Enum.empty?(Conn.get_resp_header(conn, "location"))
  end
end
