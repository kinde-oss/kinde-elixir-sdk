defmodule ClientTestHelper do
  alias KindeClientSDK
  alias KindeManagementAPI.SDK.Utils

  @redirect_url Application.get_env(:kinde_management_api, :redirect_url)
  @client_id Application.get_env(:kinde_management_api, :backend_client_id)
  @client_secret Application.get_env(:kinde_management_api, :client_secret)
  @logout_redirect_url Application.get_env(:kinde_management_api, :logout_redirect_url)
  @valid_domain Application.get_env(:kinde_management_api, :domain)
  @invalid_domain "test.c"

  def initialize_valid_client(conn, grant_type) do
    KindeClientSDK.init(
      conn,
      @valid_domain,
      @redirect_url,
      @client_id,
      @client_secret,
      grant_type,
      @logout_redirect_url
    )
  end

  def initialize_invalid_client(conn, grant_type) do
    KindeClientSDK.init(
      conn,
      @invalid_domain,
      @redirect_url,
      @client_id,
      @client_secret,
      grant_type,
      @logout_redirect_url
    )
  end

  def initialize_invalid_redirect_uri(conn, grant_type) do
    KindeClientSDK.init(
      conn,
      @valid_domain,
      "",
      @client_id,
      @client_secret,
      grant_type,
      @logout_redirect_url
    )
  end

  def initialize_valid_client_add_params(conn, grant_type, additional_params) do
    KindeClientSDK.init(
      conn,
      @valid_domain,
      @redirect_url,
      @client_id,
      @client_secret,
      grant_type,
      @logout_redirect_url,
      "openid profile email offline",
      additional_params
    )
  end

  def mock_token(conn, pid) do
    token = %{
      "id_token" =>
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJLaW5kZSBFbGl4aXIgVGVzdCIsImlhdCI6MTY4MDYwODY3NSwiZXhwIjoxNzEyMTQ0Njc1LCJhdWQiOiJ3d3cuZXhhbXBsZS5jb20iLCJzdWIiOiJ0ZXN0QGtpbmRlLmNvbSIsImdpdmVuX25hbWUiOiJKb2huIiwiZmFtaWx5X25hbWUiOiJEb2UiLCJlbWFpbCI6InVzZXJAa2luZGUuY29tIiwib3JnX2NvZGUiOiI3NjU1NDYifQ.7oLWhK6MhMdOWhExd7XTKUH-FvcfUBtBZQjvyKWmSyE",
      "access_token" => nil,
      "expires_in" => 99987
    }

    expires_in = if is_nil(token["expires_in"]), do: 0, else: token["expires_in"]

    GenServer.cast(pid, {:add_kinde_data, {:kinde_login_time_stamp, DateTime.utc_now()}})
    GenServer.cast(pid, {:add_kinde_data, {:kinde_access_token, token["access_token"]}})
    GenServer.cast(pid, {:add_kinde_data, {:kinde_id_token, token["id_token"]}})
    GenServer.cast(pid, {:add_kinde_data, {:kinde_expires_in, expires_in}})

    payload = Utils.parse_jwt(token["id_token"])

    if !is_nil(payload) do
      user = %{
        id: payload["sub"],
        given_name: payload["given_name"],
        family_name: payload["family_name"],
        email: payload["email"]
      }

      GenServer.cast(pid, {:add_kinde_data, {:kinde_user, user}})
    else
      GenServer.cast(pid, {:add_kinde_data, {:kinde_user, nil}})
    end

    conn
  end
end
