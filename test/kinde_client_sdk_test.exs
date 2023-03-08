defmodule KindeClientSDKTest do
  use ExUnit.Case

  alias KindeClientSDK
  alias Plug.Conn

  @valid_domain "https://elixirsdk.kinde.com"
  @invalid_domain "test.c"
  @redirect_url "http://localhost:4000/callback"
  @client_id "48e3345e636c4e33a2fd44413d252138"
  @client_secret "dPEIzTGS8TNGPiH0HXOXuF9f7p8Pm6zV4VOjgZsFkiR5muN9m"
  @grant_type :client_credentials
  @logout_redirect_url "http://localhost:4000/logout"

  setup_all do
    {:ok, conn: Plug.Test.conn(:get, "/") |> Plug.Test.init_test_session(%{})}
  end

  test "invalid domain", %{conn: conn} do
    assert catch_throw(
             KindeClientSDK.init(
               conn,
               @invalid_domain,
               @redirect_url,
               @client_id,
               @client_secret,
               @grant_type,
               @logout_redirect_url
             )
           ) == "Please provide valid domain"
  end

  test "empty redirect_uri", %{conn: conn} do
    assert catch_throw(
             KindeClientSDK.init(
               conn,
               @valid_domain,
               "",
               @client_id,
               @client_secret,
               @grant_type,
               @logout_redirect_url
             )
           ) == "Please provide valid redirect_uri"
  end

  test "cache pid", %{conn: conn} do
    {conn, _client} =
      KindeClientSDK.init(
        conn,
        @valid_domain,
        @redirect_url,
        @client_id,
        @client_secret,
        @grant_type,
        @logout_redirect_url
      )

    refute is_nil(Conn.get_session(conn, :kinde_cache_pid))
  end

  test "init", %{conn: conn} do
    {_conn, client} =
      KindeClientSDK.init(
        conn,
        @valid_domain,
        @redirect_url,
        @client_id,
        @client_secret,
        @grant_type,
        @logout_redirect_url
      )

    assert client.token_endpoint == @valid_domain <> "/oauth2/token"
  end

  test "invalid grant type login", %{conn: conn} do
    {conn, client} =
      KindeClientSDK.init(
        conn,
        @valid_domain,
        @redirect_url,
        @client_id,
        @client_secret,
        :invalid_grant_type,
        @logout_redirect_url
      )

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
      audience: @valid_domain <> "/api"
    }

    {_conn, client} =
      KindeClientSDK.init(
        conn,
        @valid_domain,
        @redirect_url,
        @client_id,
        @client_secret,
        @grant_type,
        @logout_redirect_url,
        "openid profile email offline",
        additional_params
      )

    assert client.additional_params == additional_params
  end

  test "invalid audience", %{conn: conn} do
    additional_params = %{
      audience: 12345
    }

    assert catch_throw(
             KindeClientSDK.init(
               conn,
               @valid_domain,
               @redirect_url,
               @client_id,
               @client_secret,
               @grant_type,
               @logout_redirect_url,
               "openid profile email offline",
               additional_params
             )
           ) == "Please supply a valid audience. Expected: string"
  end

  test "is authenticated", %{conn: conn} do
    {conn, _client} =
      KindeClientSDK.init(
        conn,
        @valid_domain,
        @redirect_url,
        @client_id,
        @client_secret,
        @grant_type,
        @logout_redirect_url
      )

    refute KindeClientSDK.authenticated?(conn)
  end

  test "login invalid org code", %{conn: conn} do
    additional_params = %{
      org_code: 12345,
      org_name: "Test App"
    }

    {conn, client} =
      KindeClientSDK.init(
        conn,
        @valid_domain,
        @redirect_url,
        @client_id,
        @client_secret,
        @grant_type,
        @logout_redirect_url
      )

    assert catch_throw(KindeClientSDK.login(conn, client, additional_params)) ==
             "Please supply a valid org_code. Expected: string"
  end

  test "login invalid org name", %{conn: conn} do
    additional_params = %{
      org_code: "12345",
      org_name: 123
    }

    {conn, client} =
      KindeClientSDK.init(
        conn,
        @valid_domain,
        @redirect_url,
        @client_id,
        @client_secret,
        @grant_type,
        @logout_redirect_url
      )

    assert catch_throw(KindeClientSDK.login(conn, client, additional_params)) ==
             "Please supply a valid org_name. Expected: string"
  end

  test "login invalid additional org code", %{conn: conn} do
    additional_params = %{
      org_code: "12345",
      org_name_test: "Test App"
    }

    {conn, client} =
      KindeClientSDK.init(
        conn,
        @valid_domain,
        @redirect_url,
        @client_id,
        @client_secret,
        @grant_type,
        @logout_redirect_url
      )

    assert catch_throw(KindeClientSDK.login(conn, client, additional_params)) ==
             "Please provide correct additional, org_name_test"
  end

  test "login invalid additional org name", %{conn: conn} do
    additional_params = %{
      org_code_test: "12345",
      org_name: "123"
    }

    {conn, client} =
      KindeClientSDK.init(
        conn,
        @valid_domain,
        @redirect_url,
        @client_id,
        @client_secret,
        @grant_type,
        @logout_redirect_url
      )

    assert catch_throw(KindeClientSDK.login(conn, client, additional_params)) ==
             "Please provide correct additional, org_code_test"
  end
end
