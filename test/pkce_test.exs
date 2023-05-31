defmodule PkceTest do
  use ExUnit.Case

  alias ClientTestHelper
  alias KindeClientSDK
  alias Plug.Conn

  import Mock

  @domain Application.compile_env(:kinde_sdk, :domain) |> String.replace("\"", "")
  @grant_type :authorization_code_flow_pkce

  setup_all do
    conn = Plug.Test.conn(:get, "/") |> Plug.Test.init_test_session(%{})
    {conn, client} = ClientTestHelper.initialize_valid_client(conn, @grant_type)
    {:ok, conn: conn, client: client}
  end

  test "initialize the client", %{conn: conn, client: client} do
    assert client.token_endpoint == @domain <> "/oauth2/token"
    refute is_nil(Conn.get_session(conn, :kinde_cache_pid))
  end

  test "login", %{conn: conn, client: client} do
    KindeClientSDK.save_kinde_client(conn, client)

    conn = KindeClientSDK.login(conn, client)

    refute Enum.empty?(Conn.get_resp_header(conn, "location"))
  end

  test "login with audience", %{conn: conn, client: _} do
    additional_params = %{
      audience: @domain <> "/api"
    }

    {conn, client} =
      ClientTestHelper.initialize_valid_client_add_params(conn, @grant_type, additional_params)

    KindeClientSDK.save_kinde_client(conn, client)

    conn = KindeClientSDK.login(conn, client)

    refute Enum.empty?(Conn.get_resp_header(conn, "location"))
  end

  test "login with additional", %{conn: conn, client: _} do
    additional_params = %{
      audience: @domain <> "/api"
    }

    {conn, client} =
      ClientTestHelper.initialize_valid_client_add_params(conn, @grant_type, additional_params)

    KindeClientSDK.save_kinde_client(conn, client)

    additional_params_more = %{
      org_code: "org_123",
      org_name: "My Application"
    }

    conn = KindeClientSDK.login(conn, client, additional_params_more)

    refute Enum.empty?(Conn.get_resp_header(conn, "location"))
  end

  test "register with additional", %{conn: conn, client: _} do
    additional_params = %{
      audience: @domain <> "/api"
    }

    {conn, client} =
      ClientTestHelper.initialize_valid_client_add_params(conn, @grant_type, additional_params)

    KindeClientSDK.save_kinde_client(conn, client)

    additional_params_more = %{
      org_code: "org_123",
      org_name: "My Application"
    }

    conn = KindeClientSDK.register(conn, client, additional_params_more)

    refute Enum.empty?(Conn.get_resp_header(conn, "location"))
  end

  test "create org", %{conn: conn, client: _} do
    additional_params = %{
      audience: @domain <> "/api"
    }

    {conn, client} =
      ClientTestHelper.initialize_valid_client_add_params(conn, @grant_type, additional_params)

    KindeClientSDK.save_kinde_client(conn, client)

    conn = KindeClientSDK.create_org(conn, client)

    refute Enum.empty?(Conn.get_resp_header(conn, "location"))
  end

  test "create org with additional", %{conn: conn, client: _} do
    additional_params = %{
      audience: @domain <> "/api"
    }

    {conn, client} =
      ClientTestHelper.initialize_valid_client_add_params(conn, @grant_type, additional_params)

    KindeClientSDK.save_kinde_client(conn, client)

    additional_params_more = %{
      org_code: "org_123",
      org_name: "My Application"
    }

    conn = KindeClientSDK.create_org(conn, client, additional_params_more)

    refute Enum.empty?(Conn.get_resp_header(conn, "location"))
  end

  test "valid pkce login", %{conn: conn} do
    {conn, client} = ClientTestHelper.init_valid_pkce_client(conn, :authorization_code_flow_pkce)

    conn = ClientTestHelper.mock_pkce_token(conn, client.cache_pid)
    assert Map.get(KindeClientSDK.get_all_data(conn), :access_token) != nil
    assert Map.get(KindeClientSDK.get_all_data(conn), :expires_in) != nil
    assert Map.get(KindeClientSDK.get_all_data(conn), :id_token) != nil
    assert Map.get(KindeClientSDK.get_all_data(conn), :refresh_token) != nil
  end

  test "returns old token if not expired", %{conn: conn} do
    {conn, client} = ClientTestHelper.init_valid_pkce_client(conn, :authorization_code_flow_pkce)

    conn = ClientTestHelper.mock_pkce_token(conn, client.cache_pid)
    old_refresh_token = Map.get(KindeClientSDK.get_all_data(conn), :refresh_token)
    old_access_token = Map.get(KindeClientSDK.get_all_data(conn), :access_token)
    :timer.sleep(30)

    conn =
      with_mock KindeClientSDK,
        get_token: fn _ ->
          ClientTestHelper.mock_pkce_token(conn, client.cache_pid)
        end do
        KindeClientSDK.get_token(conn)
      end

    new_refresh_token = Map.get(KindeClientSDK.get_all_data(conn), :refresh_token)
    new_access_token = Map.get(KindeClientSDK.get_all_data(conn), :access_token)

    assert old_refresh_token == new_refresh_token
    assert old_access_token == new_access_token
  end

  test "use of refresh token to get new access-token", %{conn: conn} do
    {conn, client} = ClientTestHelper.init_valid_pkce_client(conn, :authorization_code_flow_pkce)

    conn = ClientTestHelper.mock_pkce_token(conn, client.cache_pid)
    old_refresh_token = Map.get(KindeClientSDK.get_all_data(conn), :refresh_token)
    old_access_token = Map.get(KindeClientSDK.get_all_data(conn), :access_token)
    :timer.sleep(70)

    conn =
      with_mock KindeClientSDK,
        get_token: fn _ ->
          ClientTestHelper.mock_result_for_refresh_token(conn, client.cache_pid)
        end do
        KindeClientSDK.get_token(conn)
      end

    new_refresh_token = Map.get(KindeClientSDK.get_all_data(conn), :refresh_token)
    new_access_token = Map.get(KindeClientSDK.get_all_data(conn), :access_token)

    assert old_refresh_token != new_refresh_token
    assert old_access_token != new_access_token
  end
end
