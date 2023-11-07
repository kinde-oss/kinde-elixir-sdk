defmodule KindeClientSDKTest do
  use ExUnit.Case

  alias ClientTestHelper
  alias KindeClientSDK
  alias Plug.Conn

  @domain Application.compile_env(:kinde_sdk, :domain) |> String.replace("\"", "")
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
      audience: 12_345
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
      org_code: 12_345,
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

  test "get user for authenticated client", %{conn: conn} do
    {conn, client} = ClientTestHelper.initialize_valid_client(conn, :authorization_code)

    conn = ClientTestHelper.mock_token(conn, client.cache_pid)

    assert KindeClientSDK.get_user_detail(conn) == %{
             email: "user@kinde.com",
             family_name: "Doe",
             given_name: "John",
             id: "test@kinde.com"
           }
  end

  test "get user with picture_url", %{conn: conn} do
    {conn, client} = ClientTestHelper.initialize_valid_client(conn, :authorization_code)

    conn = ClientTestHelper.mock_picture_url(conn, client.cache_pid)

    user_details = KindeClientSDK.get_user_detail(conn)

    assert user_details.picture ==
             "https://lh3.googleusercontent.com/a/AAcHTtfwb8yG8xi8Z33LUCXmnx-40nEyPV61NAlTrDsd=s96-c"
  end

  test "get user for authenticated client_credentials grant", %{conn: conn} do
    {conn, client} = ClientTestHelper.initialize_valid_client(conn, @grant_type)

    KindeClientSDK.save_kinde_client(conn, client)

    conn = KindeClientSDK.login(conn, client)

    assert is_nil(KindeClientSDK.get_user_detail(conn))
  end

  test "permissions for unauthenticated client", %{conn: conn} do
    {conn, _} = ClientTestHelper.initialize_valid_client(conn, :authorization_code)

    assert catch_throw(KindeClientSDK.get_permissions(conn)) ==
             "Request is missing required authentication credential"
  end

  test "permissions for authenticated client", %{conn: conn} do
    {conn, client} = ClientTestHelper.initialize_valid_client(conn, :authorization_code)

    conn = ClientTestHelper.mock_token(conn, client.cache_pid)

    assert KindeClientSDK.get_permissions(conn, :id_token) ==
             %{org_code: "765546", permissions: nil}
  end

  test "permissions for authenticated client_credential client", %{conn: conn} do
    {conn, client} = ClientTestHelper.initialize_valid_client(conn, @grant_type)

    KindeClientSDK.save_kinde_client(conn, client)

    conn = KindeClientSDK.login(conn, client)

    assert KindeClientSDK.get_permissions(conn) == %{org_code: nil, permissions: nil}
  end

  test "save client", %{conn: conn} do
    {conn, client} = ClientTestHelper.initialize_valid_client(conn, :authorization_code)
    client = KindeClientSDK.save_kinde_client(conn, client)

    assert client == :ok
  end

  test "get client", %{conn: conn} do
    {conn, client} = ClientTestHelper.initialize_valid_client(conn, :authorization_code)
    KindeClientSDK.save_kinde_client(conn, client)

    get_client = KindeClientSDK.get_kinde_client(conn)

    assert client.domain == get_client.domain
  end

  test "get cache pid", %{conn: conn} do
    assert is_nil(KindeClientSDK.get_cache_pid(conn))

    {conn, _} = ClientTestHelper.initialize_valid_client(conn, :authorization_code)
    assert !is_nil(KindeClientSDK.get_cache_pid(conn))
  end

  test "get all data", %{conn: conn} do
    {conn, _} = ClientTestHelper.initialize_valid_client(conn, :authorization_code)
    data = KindeClientSDK.get_all_data(conn)

    assert is_nil(data.token)
  end

  describe "test get_claim/3 action" do
    test "return claim from access-token", %{conn: conn} do
      {conn, client} = ClientTestHelper.initialize_valid_client(conn, :client_credentials)
      conn = ClientTestHelper.mock_token(conn, client.cache_pid)
      conn = KindeClientSDK.login(conn, client)

      assert KindeClientSDK.get_claim(conn, "iss") == %{
               name: "iss",
               value: Application.get_env(:kinde_sdk, :domain) |> String.replace("\"", "")
             }
    end

    test "throws missing-required-auth-cred error when not called with proper creds", %{
      conn: conn
    } do
      {conn, client} =
        ClientTestHelper.init_valid_pkce_client(conn, :authorization_code_flow_pkce)

      conn = ClientTestHelper.mock_token(conn, client.cache_pid)

      conn = KindeClientSDK.login(conn, client)

      assert catch_throw(KindeClientSDK.get_permissions(conn)) ==
               "Request is missing required authentication credential"
    end
  end

  describe "get_flag/2 action" do
    test "returns detailed map for any certain code", %{conn: conn} do
      {conn, client} =
        ClientTestHelper.init_valid_pkce_client(conn, :authorization_code_flow_pkce)

      conn = ClientTestHelper.mock_feature_flags(conn, client.cache_pid)

      assert KindeClientSDK.get_flag(conn, "theme") == %{
               "code" => "theme",
               "is_default" => false,
               "type" => "string",
               "value" => "grayscale"
             }
    end

    test "returns error-message when unknown-code is passed", %{conn: conn} do
      {conn, client} =
        ClientTestHelper.init_valid_pkce_client(conn, :authorization_code_flow_pkce)

      conn = ClientTestHelper.mock_feature_flags(conn, client.cache_pid)

      assert KindeClientSDK.get_flag(conn, "unknown_flag_code") ==
               "This flag does not exist, and no default value provided"

      assert KindeClientSDK.get_flag(conn, "another_invalid_code") ==
               "This flag does not exist, and no default value provided"
    end
  end

  describe "get_flag/3 action" do
    test "returns detailed map for any certain code, despite of any default-value provided", %{
      conn: conn
    } do
      {conn, client} =
        ClientTestHelper.init_valid_pkce_client(conn, :authorization_code_flow_pkce)

      conn = ClientTestHelper.mock_feature_flags(conn, client.cache_pid)

      assert KindeClientSDK.get_flag(conn, "theme", "pink") == %{
               "code" => "theme",
               "is_default" => false,
               "type" => "string",
               "value" => "grayscale"
             }
    end

    test "returns customized-map for any certain code (which doesn't exists), but default-value provided",
         %{conn: conn} do
      {conn, client} =
        ClientTestHelper.init_valid_pkce_client(conn, :authorization_code_flow_pkce)

      conn = ClientTestHelper.mock_feature_flags(conn, client.cache_pid)

      assert KindeClientSDK.get_flag(conn, "unknown_flag_code", "pink") == %{
               "code" => "unknown_flag_code",
               "is_default" => true,
               "value" => "pink"
             }
    end
  end

  describe "get_flag/4 action" do
    test "returns detailed map for any certain code, when flag-type matches the type of code", %{
      conn: conn
    } do
      {conn, client} =
        ClientTestHelper.init_valid_pkce_client(conn, :authorization_code_flow_pkce)

      conn = ClientTestHelper.mock_feature_flags(conn, client.cache_pid)

      assert KindeClientSDK.get_flag(conn, "theme", "pink", "s") == %{
               "code" => "theme",
               "is_default" => false,
               "type" => "string",
               "value" => "grayscale"
             }
    end

    test "returns error-message when types are mis-matched", %{conn: conn} do
      {conn, client} =
        ClientTestHelper.init_valid_pkce_client(conn, :authorization_code_flow_pkce)

      conn = ClientTestHelper.mock_feature_flags(conn, client.cache_pid)

      assert KindeClientSDK.get_flag(conn, "theme", "pink", "i") ==
               "The flag type was provided as integer, but it is string"

      assert KindeClientSDK.get_flag(conn, "counter", 34, "s") ==
               "The flag type was provided as string, but it is integer"
    end
  end

  describe "get_boolean_flag/2 action" do
    test "returns true/false, when boolean-flag is fetched", %{conn: conn} do
      {conn, client} =
        ClientTestHelper.init_valid_pkce_client(conn, :authorization_code_flow_pkce)

      conn = ClientTestHelper.mock_feature_flags(conn, client.cache_pid)
      assert KindeClientSDK.get_boolean_flag(conn, "is_dark_mode") == false
    end

    test "returns error-message, if you try to fetch non-boolean flag from it", %{conn: conn} do
      {conn, client} =
        ClientTestHelper.init_valid_pkce_client(conn, :authorization_code_flow_pkce)

      conn = ClientTestHelper.mock_feature_flags(conn, client.cache_pid)

      assert KindeClientSDK.get_boolean_flag(conn, "theme") ==
               "Error - Flag theme is of type string not boolean"
    end

    test "returns error-message, if flag is invalid, and doesn't exists", %{conn: conn} do
      {conn, client} =
        ClientTestHelper.init_valid_pkce_client(conn, :authorization_code_flow_pkce)

      conn = ClientTestHelper.mock_feature_flags(conn, client.cache_pid)

      assert KindeClientSDK.get_boolean_flag(conn, "unknown_flag") ==
               "Error - flag does not exist and no default provided"
    end
  end

  describe "get_boolean_flag/3 action" do
    test "returns true/false, when boolean-flag is fetched, despite of what default-value is being passed",
         %{conn: conn} do
      {conn, client} =
        ClientTestHelper.init_valid_pkce_client(conn, :authorization_code_flow_pkce)

      conn = ClientTestHelper.mock_feature_flags(conn, client.cache_pid)
      assert KindeClientSDK.get_boolean_flag(conn, "is_dark_mode", false) == false
    end

    test "returns default-value, when unknown-flag is passed", %{conn: conn} do
      {conn, client} =
        ClientTestHelper.init_valid_pkce_client(conn, :authorization_code_flow_pkce)

      conn = ClientTestHelper.mock_feature_flags(conn, client.cache_pid)
      assert KindeClientSDK.get_boolean_flag(conn, "unknown_flag", false) == false
    end
  end

  describe "get_string_flag/2 action" do
    test "returns string-value, when string-flag is fetched", %{conn: conn} do
      {conn, client} =
        ClientTestHelper.init_valid_pkce_client(conn, :authorization_code_flow_pkce)

      conn = ClientTestHelper.mock_feature_flags(conn, client.cache_pid)
      assert KindeClientSDK.get_string_flag(conn, "theme") == "grayscale"
    end

    test "returns error-message, if you try to fetch non-string flag from it", %{conn: conn} do
      {conn, client} =
        ClientTestHelper.init_valid_pkce_client(conn, :authorization_code_flow_pkce)

      conn = ClientTestHelper.mock_feature_flags(conn, client.cache_pid)

      assert KindeClientSDK.get_string_flag(conn, "is_dark_mode") ==
               "Error - Flag is_dark_mode is of type boolean not string"
    end

    test "returns error-message, if flag is invalid, nor doesn't exists", %{conn: conn} do
      {conn, client} =
        ClientTestHelper.init_valid_pkce_client(conn, :authorization_code_flow_pkce)

      conn = ClientTestHelper.mock_feature_flags(conn, client.cache_pid)

      assert KindeClientSDK.get_string_flag(conn, "unknown_flag") ==
               "Error - flag does not exist and no default provided"
    end
  end

  describe "get_string_flag/3 action" do
    test "returns string-value, when string-flag is fetched, despite of what default-value is being passed",
         %{conn: conn} do
      {conn, client} =
        ClientTestHelper.init_valid_pkce_client(conn, :authorization_code_flow_pkce)

      conn = ClientTestHelper.mock_feature_flags(conn, client.cache_pid)
      assert KindeClientSDK.get_string_flag(conn, "theme", "pink") == "grayscale"
    end

    test "returns default-value, when unknown-flag is passed", %{conn: conn} do
      {conn, client} =
        ClientTestHelper.init_valid_pkce_client(conn, :authorization_code_flow_pkce)

      conn = ClientTestHelper.mock_feature_flags(conn, client.cache_pid)
      assert KindeClientSDK.get_string_flag(conn, "unknown_flag", "pink") == "pink"
    end
  end

  describe "get_integer_flag/2 action" do
    test "returns integer-value, when integer-flag is fetched", %{conn: conn} do
      {conn, client} =
        ClientTestHelper.init_valid_pkce_client(conn, :authorization_code_flow_pkce)

      conn = ClientTestHelper.mock_feature_flags(conn, client.cache_pid)
      assert KindeClientSDK.get_integer_flag(conn, "counter") == 55
    end

    test "returns error-message, if you try to fetch non-integer flag from it", %{conn: conn} do
      {conn, client} =
        ClientTestHelper.init_valid_pkce_client(conn, :authorization_code_flow_pkce)

      conn = ClientTestHelper.mock_feature_flags(conn, client.cache_pid)

      assert KindeClientSDK.get_integer_flag(conn, "is_dark_mode") ==
               "Error - Flag is_dark_mode is of type boolean not integer"
    end

    test "returns error-message, if flag is invalid + doesn't exists", %{conn: conn} do
      {conn, client} =
        ClientTestHelper.init_valid_pkce_client(conn, :authorization_code_flow_pkce)

      conn = ClientTestHelper.mock_feature_flags(conn, client.cache_pid)

      assert KindeClientSDK.get_integer_flag(conn, "unknown_flag") ==
               "Error - flag does not exist and no default provided"
    end
  end

  describe "get_integer_flag/3 action" do
    test "returns integer-value, when integer-flag is fetched, despite of what default-value is being passed",
         %{conn: conn} do
      {conn, client} =
        ClientTestHelper.init_valid_pkce_client(conn, :authorization_code_flow_pkce)

      conn = ClientTestHelper.mock_feature_flags(conn, client.cache_pid)
      assert KindeClientSDK.get_integer_flag(conn, "counter", 99) == 55
    end

    test "returns default-value, when unknown-flag is passed", %{conn: conn} do
      {conn, client} =
        ClientTestHelper.init_valid_pkce_client(conn, :authorization_code_flow_pkce)

      conn = ClientTestHelper.mock_feature_flags(conn, client.cache_pid)
      assert KindeClientSDK.get_integer_flag(conn, "unknown_flag", 99) == 99
    end
  end
end
