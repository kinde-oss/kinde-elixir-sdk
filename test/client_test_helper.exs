defmodule ClientTestHelper do
  alias KindeClientSDK

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
end
