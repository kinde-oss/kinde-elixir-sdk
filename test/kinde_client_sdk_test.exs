defmodule KindeClientSDKTest do
  use ExUnit.Case

  alias ClientTestHelper
  alias KindeClientSDK
  alias Plug.Conn

  @domain Application.get_env(:kinde_management_api, :domain)
  @grant_type :client_credentials

  setup_all do
    {:ok, conn: Plug.Test.conn(:get, "/") |> Plug.Test.init_test_session(%{})}
  end

  test "invalid domain", %{conn: conn} do
    assert catch_throw(ClientTestHelper.initialize_invalid_client(conn, @grant_type)) ==
             "Please provide valid domain"
  end

  test "empty redirect_uri", %{conn: conn} do
    assert catch_throw(ClientTestHelper.initialize_invalid_redirect_uri(conn, @grant_type)) ==
             "Please provide valid redirect_uri"
  end

  test "cache pid", %{conn: conn} do
    {conn, _client} = ClientTestHelper.initialize_valid_client(conn, @grant_type)

    refute is_nil(Conn.get_session(conn, :kinde_cache_pid))
  end

  test "init", %{conn: conn} do
    {_conn, client} = ClientTestHelper.initialize_valid_client(conn, @grant_type)

    assert client.token_endpoint == @domain <> "/oauth2/token"
  end

  test "invalid grant type login", %{conn: conn} do
    {conn, client} = ClientTestHelper.initialize_valid_client(conn, :invalid_grant_type)

    assert catch_throw(KindeClientSDK.login(conn, client)) == "Please provide correct grant_type"
  end

  test "get valid grant type" do
    assert KindeClientSDK.get_grant_type(:authorization_code_flow_pkce) == :authorization_code
  end

  test "get invalid grant type" do
    assert catch_throw(KindeClientSDK.get_grant_type(:invalid)) ==
             "Please provide correct grant_type"
  end

  test "valid audience", %{conn: conn} do
    additional_params = %{
      audience: @domain <> "/api"
    }

    {_conn, client} =
      ClientTestHelper.initialize_valid_client_add_params(conn, @grant_type, additional_params)

    assert client.additional_params == additional_params
  end

  test "invalid audience", %{conn: conn} do
    additional_params = %{
      audience: 12345
    }

    assert catch_throw(
             ClientTestHelper.initialize_valid_client_add_params(
               conn,
               @grant_type,
               additional_params
             )
           ) == "Please supply a valid audience. Expected: string"
  end

  test "is authenticated", %{conn: conn} do
    {conn, _client} = ClientTestHelper.initialize_valid_client(conn, @grant_type)

    refute KindeClientSDK.authenticated?(conn)
  end

  test "login invalid org code", %{conn: conn} do
    additional_params = %{
      org_code: 12345,
      org_name: "Test App"
    }

    {conn, client} = ClientTestHelper.initialize_valid_client(conn, @grant_type)

    assert catch_throw(KindeClientSDK.login(conn, client, additional_params)) ==
             "Please supply a valid org_code. Expected: string"
  end

  test "login invalid org name", %{conn: conn} do
    additional_params = %{
      org_code: "12345",
      org_name: 123
    }

    {conn, client} = ClientTestHelper.initialize_valid_client(conn, @grant_type)

    assert catch_throw(KindeClientSDK.login(conn, client, additional_params)) ==
             "Please supply a valid org_name. Expected: string"
  end

  test "login invalid additional org code", %{conn: conn} do
    additional_params = %{
      org_code: "12345",
      org_name_test: "Test App"
    }

    {conn, client} = ClientTestHelper.initialize_valid_client(conn, @grant_type)

    assert catch_throw(KindeClientSDK.login(conn, client, additional_params)) ==
             "Please provide correct additional, org_name_test"
  end

  test "login invalid additional org name", %{conn: conn} do
    additional_params = %{
      org_code_test: "12345",
      org_name: "123"
    }

    {conn, client} = ClientTestHelper.initialize_valid_client(conn, @grant_type)

    assert catch_throw(KindeClientSDK.login(conn, client, additional_params)) ==
             "Please provide correct additional, org_code_test"
  end

  test "get user for unauthenticated client", %{conn: conn} do
    {conn, _} = ClientTestHelper.initialize_valid_client(conn, :authorization_code)

    assert is_nil(KindeClientSDK.get_user_detail(conn))
  end

  test "get user for authenticated client_credentials grant", %{conn: conn} do
    {conn, client} = ClientTestHelper.initialize_valid_client(conn, @grant_type)

    pid = Conn.get_session(conn, :kinde_cache_pid)
    GenServer.cast(pid, {:add_kinde_data, {:kinde_client, client}})

    conn = KindeClientSDK.login(conn, client)

    assert is_nil(KindeClientSDK.get_user_detail(conn))
  end

  test "permissions for unauthenticated client", %{conn: conn} do
    {conn, _} = ClientTestHelper.initialize_valid_client(conn, :authorization_code)

    assert catch_throw(KindeClientSDK.get_permissions(conn)) ==
             "Request is missing required authentication credential"
  end

  test "permissions for authenticated client", %{conn: conn} do
    {conn, client} = ClientTestHelper.initialize_valid_client(conn, @grant_type)

    pid = Conn.get_session(conn, :kinde_cache_pid)
    GenServer.cast(pid, {:add_kinde_data, {:kinde_client, client}})

    conn = KindeClientSDK.login(conn, client)

    assert KindeClientSDK.get_permissions(conn) == %{org_code: nil, permissions: nil}
  end
end
