defmodule AuthorizationCodeTest do
  use ExUnit.Case

  alias ClientTestHelper
  alias KindeClientSDK
  alias Plug.Conn

  @domain Application.get_env(:kinde_management_api, :domain)
  @grant_type :authorization_code

  setup_all do
    conn = Plug.Test.conn(:get, "/") |> Plug.Test.init_test_session(%{})
    {conn, client} = ClientTestHelper.initialize_valid_client(conn, @grant_type)
    {:ok, conn: conn, client: client}
  end

  test "initialize the client", %{conn: conn, client: client} do
    assert client.token_endpoint == @domain <> "/oauth2/token"
    refute is_nil(Conn.get_session(conn, :kinde_cache_pid))
  end

  test "do login", %{conn: conn, client: client} do
    pid = Conn.get_session(conn, :kinde_cache_pid)
    GenServer.cast(pid, {:add_kinde_data, {:kinde_client, client}})

    conn = KindeClientSDK.login(conn, client)

    refute Enum.empty?(Conn.get_resp_header(conn, "location"))
  end

  test "do login with audience", %{conn: conn, client: _} do
    additional_params = %{
      audience: @domain <> "/api"
    }

    {conn, client} =
      ClientTestHelper.initialize_valid_client_add_params(conn, @grant_type, additional_params)

    pid = Conn.get_session(conn, :kinde_cache_pid)
    GenServer.cast(pid, {:add_kinde_data, {:kinde_client, client}})

    conn = KindeClientSDK.login(conn, client)

    refute Enum.empty?(Conn.get_resp_header(conn, "location"))
  end

  test "do login with additional", %{conn: conn, client: _} do
    additional_params = %{
      audience: @domain <> "/api"
    }

    {conn, client} =
      ClientTestHelper.initialize_valid_client_add_params(conn, @grant_type, additional_params)

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
