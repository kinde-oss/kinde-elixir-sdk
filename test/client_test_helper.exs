defmodule ClientTestHelper do
  alias KindeClientSDK
  alias KindeSDK.SDK.Utils

  @redirect_url Application.compile_env(:kinde_sdk, :redirect_url)
  @pkce_callback_url Application.compile_env(:kinde_sdk, :pkce_callback_url)
  @frontend_client_id Application.compile_env(:kinde_sdk, :frontend_client_id)
  @client_id Application.compile_env(:kinde_sdk, :backend_client_id)
  @client_secret Application.compile_env(:kinde_sdk, :client_secret)
  @logout_redirect_url Application.compile_env(:kinde_sdk, :logout_redirect_url)
  @valid_domain Application.compile_env(:kinde_sdk, :domain)
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

  def init_valid_pkce_client(conn, grant_type) do
    KindeClientSDK.init(
      conn,
      @valid_domain,
      @pkce_callback_url,
      @frontend_client_id,
      @client_secret,
      grant_type,
      @logout_redirect_url
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

  def mock_feature_flags(conn, pid) do
    token = %{
      "access_token" =>
        "eyJhbGciOiJSUzI1NiIsImtpZCI6IjdhOmYzOjZiOmE3OjVjOjI1OmE3OmY4OmMzOjA1OjYzOmNiOjRiOmYwOjMzOjhiIiwidHlwIjoiSldUIn0.eyJhdWQiOltdLCJhenAiOiIyZTQxZTllNzk4MDA0MTc3YjFiNDRhYTFlMWFkM2Q2MiIsImV4cCI6MTY4NDM5NjYzMCwiZmVhdHVyZV9mbGFncyI6eyJjb3VudGVyIjp7InQiOiJpIiwidiI6NTV9LCJpc19kYXJrX21vZGUiOnsidCI6ImIiLCJ2IjpmYWxzZX0sInRoZW1lIjp7InQiOiJzIiwidiI6ImdyYXlzY2FsZSJ9fSwiaWF0IjoxNjg0Mzk2NTY5LCJpc3MiOiJodHRwczovL2VsaXhpcnNkazIua2luZGUuY29tIiwianRpIjoiYzljOTM0YTctOGRmOC00OWFjLWFkZDctODRiNDMwODg3YWYyIiwib3JnX2NvZGUiOiJvcmdfOWRjMzNmMWQ2NDQiLCJwZXJtaXNzaW9ucyI6W10sInNjcCI6WyJvcGVuaWQiLCJwcm9maWxlIiwiZW1haWwiLCJvZmZsaW5lIl0sInN1YiI6ImtwOmEzNjgzMTJlM2Q4ODRlMTU4YmU0NzVjNjAyNWJiYmFkIn0.vM0s0KKp8Y_KcXgBtuIWlskcyiSyhBRBNV-7hOWUarUr9wu61P1L-pjYswdRj_0HKH7ZxaOydSl1Mq-6tf7R8uWryR-kLVVFRpCvCDP7y3CLsGkBlLsnxazwWuBmja0619oBTqjba7QAVE3rxlIuUYdNLjJrXbo0V0OAwErzlB8gGEJ5s2opvpWKtKjO027SNDEGSHbWJ3SGvMRYtZSRA9ku3Tcso3eqLH2cFT7tS0aYRWyPqvZe3k_st4T0qoRXGYgQI_XMTgw26ar2yvXp7Shvl3ib6oUndOr_ZQ5yT3orvvl8wyadgct3X-i8c379pn8kTvZ3kTN2r-jYLQVAEQ"
    }

    GenServer.cast(pid, {:add_kinde_data, {:kinde_access_token, token["access_token"]}})

    conn
  end
end
